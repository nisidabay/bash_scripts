#!/usr/bin/env bash
#
# LEGACY — preserved as example, requires local AI backend
# Pattern-based AI with fzf, clipboard, YouTube transcript

# --- Configuration ---
RESPONSES_DIR=~/temp/ai_responses/
PATTERNS_DIR=~/patterns
TEMP_INPUT_FILE="/tmp/ollama_manual_input.txt"

# --- Cleanup Trap ---
# Runs automatically on exit (Success, Error, or Ctrl+C)
cleanup() {
    # 1. Remove temp input file
    [[ -f "$TEMP_INPUT_FILE" ]] && rm "$TEMP_INPUT_FILE"

    # 2. Clear xsel (Clipboard & Primary)
    if command -v xsel >/dev/null; then
        xsel --clipboard --clear 2>/dev/null
        xsel --primary --clear 2>/dev/null
    fi

    # 3. Clear xclip (Clipboard & Primary)
    if command -v xclip >/dev/null; then
        echo -n "" | xclip -selection clipboard 2>/dev/null
        echo -n "" | xclip -selection primary 2>/dev/null
    fi
}
trap cleanup EXIT

# --- Functions ---

# 1. Try to get data silently from Pipe/Clipboard
get_initial_source() {
    if [[ ! -t 0 ]]; then
        cat # Read from pipe
    else
        # Try xsel first, fallback to xclip
        xsel --clipboard --output 2>/dev/null || xclip -o -selection clipboard 2>/dev/null
    fi
}

# 2. Check for YouTube links and convert if needed
process_content() {
    local input_data="$1"

    # regex to find youtube video ids
    if [[ "$input_data" =~ v=([^&]+) ]]; then
        local video_id="${bash_rematch[1]}"
        echo "🎥 youtube link detected. extracting transcript for id: $video_id" >&2

        # replace url with transcript
        if ! youtube_transcript_api "$video_id" --format text; then
            echo "❌ failed to download transcript." >&2
            exit 1
        fi
    else
        # return original text
        echo "$input_data"
    fi
}

# --- Main Execution ---

main() {
    # 1. Dependency Check
    for cmd in fzf ollama youtube_transcript_api xsel notify-send nvim; do
        if ! command -v "$cmd" >/dev/null; then
            echo "❌ Missing dependency: $cmd" >&2
            exit 1
        fi
    done

    # 2. Setup
    mkdir -p "$RESPONSES_DIR"

    # 3. Check Clipboard/Pipe
    USER_INPUT=$(get_initial_source)
    INPUT_SOURCE="clipboard"

    if [[ -z "$USER_INPUT" ]]; then
        INPUT_SOURCE="manual"
    fi

    # 4. Select Model
    MODEL=$({{AI_LIST_MODELS}} | tail -n +2 | awk '{print $1}' | fzf --prompt="🤖 Select Model: " --height=40% --reverse)
    [[ -z "$MODEL" ]] && exit 1

    # 5. Select Pattern
    PATTERN=$(ls "$PATTERNS_DIR" | fzf --prompt="qm Select Pattern: " --height=40% --reverse)
    [[ -z "$PATTERN" ]] && exit 1

    SYSTEM_PROMPT_FILE="$PATTERNS_DIR/$PATTERN/system.md"
    [[ ! -f "$SYSTEM_PROMPT_FILE" ]] && {
        echo "❌ Pattern file missing."
        exit 1
    }

    # 6. IF Clipboard was empty, NOW ask for input
    if [[ "$INPUT_SOURCE" == "manual" ]]; then
        echo "⚠️  No input detected in clipboard." >&2
        echo "⌨️  Opening nvim. Paste your content, Save, and Quit." >&2

        read -n 1 -s -r -p "Press any key to open editor..." >&2

        >"$TEMP_INPUT_FILE"
        nvim "$TEMP_INPUT_FILE"

        USER_INPUT=$(cat "$TEMP_INPUT_FILE")

        if [[ -z "$USER_INPUT" ]]; then
            echo "❌ No input provided. Aborting." >&2
            exit 1
        fi
    fi

    # 7. Process Input (YouTube check)
    FINAL_CONTENT=$(process_content "$USER_INPUT")

    # 8. Execution
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local OUTFILE="${RESPONSES_DIR}ai_resp_${timestamp}.md"

    echo -e "\n🧠 Model: $MODEL | Pattern: $PATTERN\n⏳ Processing..."

    # Direct Pattern + Input
    (
        cat "$SYSTEM_PROMPT_FILE"
        echo ""
        echo "$FINAL_CONTENT"
    ) | {{AI_COMMAND}} "$MODEL" | tee "$OUTFILE"

    # 9. Finish
    # We still copy to clipboard temporarily, just in case you want to paste inside nvim below.
    cat "$OUTFILE" | (xsel --clipboard --input 2>/dev/null || xclip -selection clipboard)
    notify-send "AI Finished" "Saved to $OUTFILE"

    echo -e "\n📝 Response Ready: $OUTFILE"
    read -p "👀 Open in nvim? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        nvim "$OUTFILE"
    fi

    # Script exits -> trap cleanup runs -> Clipboard cleared.
}

main "$@"
