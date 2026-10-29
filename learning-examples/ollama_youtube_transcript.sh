#!/usr/bin/env bash

# LEGACY — preserved as example, requires local AI backend
# Extract YouTube transcripts (if link detected) and summarize them.

# --- Safety & Configuration ---
set -euo pipefail

# Directory where AI responses will be saved.
RESPONSES_DIR=~/temp/ai_responses/

# Strict System Prompt for YouTube Summarization
SYSTEM_PROMPT="You are an expert analyst of YouTube video transcripts. Summarize the content concisely and provide key takeaways. Your output must be a properly formatted markdown file, wrapped to 80 columns width."

# --- Helper Functions (Logging & Utils) ---

log_info() {
    echo "ℹ️  $1"
}

log_success() {
    echo "✅ $1"
}

log_error() {
    echo "❌ $1" >&2
}

log_warning() {
    echo "⚠️  $1"
}

# --- Core System Functions ---

check_dependencies() {
    local missing_deps=()
    local required_cmds=(ollama notify-send fzf)

    # Check basic commands
    for cmd in "${required_cmds[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing_deps+=("$cmd")
        fi
    done

    # Check clipboard tools
    if ! command -v "xclip" &>/dev/null && ! command -v "xsel" &>/dev/null; then
        missing_deps+=("xclip or xsel")
    fi

    # Check editor
    if ! command -v "nvim" &>/dev/null; then
        missing_deps+=("nvim")
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing required commands: ${missing_deps[*]}. Please install them to continue."
        exit 1
    fi
}

shutdown_ai() {
    if pgrep -x "ollama" &>/dev/null; then
        log_info "Shutting down AI server..."
        if sudo pkill ollama >/dev/null 2>&1; then
            log_success "AI server has been shut down."
        else
            log_error "Failed to shut down AI server. Check sudo permissions."
        fi
    fi
}

ensure_output_dir() {
    if ! mkdir -p "$RESPONSES_DIR"; then
        log_error "Cannot create directory: $RESPONSES_DIR"
        return 1
    fi
    return 0
}

# --- Interaction Functions ---

select_model() {
    local filter_models
    local selected_model

    # Get a list of available AI models, skipping the header.
    filter_models=$({{AI_LIST_MODELS}} | awk 'NR>1 {print $1}')

    if [[ -z "$filter_models" ]]; then
        log_error "No AI models found. Run '{{AI_PULL_MODEL}} <model>' first."
        exit 1
    fi

    selected_model=$(echo "$filter_models" | fzf --prompt="Select Model for Summary: ")

    if [[ -z "$selected_model" ]]; then
        log_error "No model selected. Exiting."
        exit 1
    fi

    echo "$selected_model"
}

get_clipboard_content() {
    local content=""
    if command -v "xclip" &>/dev/null; then
        content=$(xclip -o -selection clipboard 2>/dev/null || true)
        if [[ -z "$content" ]]; then
            content=$(xclip -o -selection primary 2>/dev/null || true)
        fi
    elif command -v "xsel" &>/dev/null; then
        content=$(xsel --clipboard --output 2>/dev/null || true)
        if [[ -z "$content" ]]; then
            content=$(xsel --primary --output 2>/dev/null || true)
        fi
    fi

    echo "$content"
}

open_in_nvim() {
    local outfile=$1
    if [[ ! -f "$outfile" ]]; then return; fi

    read -p "👀 Open summary in nvim? (y/N) " -n 1 -r </dev/tty
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        nvim "$outfile"
    fi
}

# --- Data Processing Functions ---

process_input_content() {
    local input_data="$1"

    # Regex check for YouTube video ID
    if [[ "$input_data" =~ v=([^&]+) ]]; then
        local video_id="${BASH_REMATCH[1]}"

        if [[ -z "$video_id" ]]; then
            log_error "Could not extract video ID from URL."
            echo "$input_data"
            return
        fi

        log_info "YouTube link detected. Extracting transcript for ID: $video_id" >&2

        if ! command -v "youtube_transcript_api" &>/dev/null; then
            log_error "youtube_transcript_api is not installed. Run 'pip install youtube-transcript-api'"
            exit 1
        fi

        local transcript_output
        if transcript_output=$(youtube_transcript_api "$video_id" --format text 2>&1); then
            echo "$transcript_output"
        else
            log_error "Failed to download transcript: $transcript_output"
            # Return original data so we don't pass an empty string if download fails
            echo "$input_data"
        fi
    else
        # Return original text (assumes user copied a transcript manually)
        echo "$input_data"
    fi
}

save_and_notify() {
    local outfile="$1"
    local response_content="$2"

    if [[ -z "$response_content" ]]; then
        log_warning "AI output is empty. No file saved."
        notify-send "AI Summary Failed" "No response generated."
        return 1
    fi

    echo "--- 📝 Summary ---"
    cat "$outfile"
    echo "------------------"

    cat "$outfile" | xclip -selection clipboard

    log_success "Summary saved to '$outfile'"
    log_success "Summary copied to clipboard."

    notify-send "AI Summary Complete" "Saved to '$outfile' & copied to clipboard."
}

help_message() {
    cat <<EOF
AI YouTube Summarizer

Usage:
  1. Copy a YouTube link to your clipboard.
  2. Run the script: ./$(basename "$0")

Description:
  Extracts the transcript using youtube_transcript_api and uses a local AI
  model to generate a concise, markdown-formatted summary.

Dependencies:
  - ollama (AI backend)
  - fzf
  - xclip or xsel
  - notify-send
  - nvim
  - youtube_transcript_api
EOF
}

# --- Main Execution Flow ---

main() {
    check_dependencies

    # Get Clipboard
    local user_clipboard
    user_clipboard=$(get_clipboard_content)

    if [[ -z "$user_clipboard" ]]; then
        help_message
        exit 1
    fi

    # Process (Extract Transcript)
    local final_prompt
    final_prompt=$(process_input_content "$user_clipboard")

    if [[ -z "$final_prompt" ]]; then
        log_error "No content available to summarize. Exiting."
        exit 1
    fi

    ensure_output_dir
    local model_name
    model_name=$(select_model)

    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local outfile="${RESPONSES_DIR}ai_summary_${model_name}_${timestamp}.txt"

    log_info "Summarizing with model '$model_name'..."
    log_info "Please wait..."

    local combined_user_prompt
    printf -v combined_user_prompt "%s\n\nTranscript to summarize: %s" "$SYSTEM_PROMPT" "$final_prompt"

    # Write Header
    {
        echo "--- YouTube Summary ---"
        echo "Model: $model_name"
        echo "Timestamp: $(date +"%Y-%m-%d %H:%M:%S")"
        echo "Source: $(echo "$user_clipboard" | head -n 1 | cut -c 1-60)..."
        echo "-----------------------"
        echo ""
    } >"$outfile"

    # Execute AI
    if ! {{AI_COMMAND}} "$model_name" "$combined_user_prompt" >>"$outfile"; then
        log_error "Failed to run AI command."
        rm -f "$outfile"
        exit 1
    fi

    save_and_notify "$outfile" "$final_prompt"
    open_in_nvim "$outfile"
    shutdown_ai
}

main "$@"
