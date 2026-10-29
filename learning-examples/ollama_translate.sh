#!/usr/bin/env bash
#
# LEGACY — preserved as example, requires local AI backend
# Translate text in Spanish/English using local AI models

set -euo pipefail

# --- Configuration ---
OUTFILE=$(mktemp /tmp/ollama_translation.XXXXXX.txt)

# --- Global State ---
# This variable will be set by the -q flag in main().
QUIET_MODE=false

# Clean up the temp file on exit
trap 'rm -f "$OUTFILE"' EXIT

##
# Displays usage information for the script.
##
show_usage() {
    echo "Usage: $(basename "$0") [-i LANG] [-q] [-p] [-h] [text to translate]"
    echo "Translates text to a specified language using a local AI model."
    echo
    echo "Input Methods (in order of precedence):"
    echo "  1. Direct Argument:   Provide text directly after all options."
    echo "  2. Piped Input:       Pipe text from another command (e.g., echo \"text\" | $(basename "$0"))."
    echo "  3. Clipboard (-p):    Use text from the system clipboard."
    echo "  4. Interactive:       If no other input is provided, the script will prompt you."
    echo
    echo "Options:"
    echo "  -i LANG               Specify the target language. Supported: EN (English), ES (Spanish)."
    echo "  -p, --paste           Use text from the clipboard as input (if not using a pipe)."
    echo "  -q, --quiet           Enable quiet mode. Outputs only the final translation."
    echo "  -h, --help            Show this help message and exit."
    echo
    echo "Examples:"
    echo "  Pipe:                echo \"Me encanta Madrid.\" | $(basename "$0") -i EN"
    echo "  Direct Argument:     $(basename "$0") -i EN \"Me encanta programar en Bash.\""
    echo "  From Clipboard:      $(basename "$0") -p -i EN"
}

##
# Prints a message to the console unless quiet mode is enabled.
##
log_message() {
    if [ "$QUIET_MODE" = false ]; then
        echo "$@" >&2 # Print logs to stderr to not interfere with stdout
    fi
}
##
# Checks for required command-line tools.
##
check_dependencies() {
    local missing_deps=()
    for cmd in ollama xclip notify-send fzf; do
        if ! command -v "$cmd" &>/dev/null; then
            missing_deps+=("$cmd")
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_message "❌ Error: Missing required commands: ${missing_deps[*]}. Please install them to continue."
        log_message "    Installation: sudo pacman -S ollama xclip libnotify-bin fzf"
        exit 1
    fi
}

##
# Interactively select a local AI model using fzf.
##
get_model() {
    local filter_models
    # Get models, remove HEADER
    filter_models=$({{AI_LIST_MODELS}} | awk 'NR>1 {print $1}')

    if [[ -z "$filter_models" ]]; then
        log_message "❌ Error: No AI models found. Please run '{{AI_PULL_MODEL}} <model_name>'."
        exit 1
    fi

    local selected_model
    selected_model=$(echo "$filter_models" | fzf --prompt="Select AI Model > ")

    if [[ -z "$selected_model" ]]; then
        log_message "❌ Error: No model selected. Exiting."
        exit 1
    fi

    echo "$selected_model"
}


##
# Prompts the user to enter their question.
# $1: The name of the target language (e.g., "English", "Spanish")
##
get_prompt() {
    local lang_name="$1"
    local prompt
    read -rp "Enter the sentence to translate to ${lang_name}: " prompt
    echo "$prompt"
}

##
# Shuts down the AI server process if it's running.
##
shutdown_ai() {
    if pgrep -x "ollama" &>/dev/null; then
        log_message "Shutting down AI server..."
        if sudo pkill ollama >/dev/null 2>&1; then
            log_message "✅ AI server has been shut down."
        else
            log_message "❌ Failed to shut down AI server. Check sudo permissions."
        fi
    fi
}

##
# Main function to control the script's execution flow.
##
main() {
    local TARGET_LANG="EN" # Default language
    local USE_CLIPBOARD=false

    # --- Step 1: Parse flags ---
    while getopts ":i:qph" opt; do
      case ${opt} in
        i)
          TARGET_LANG=$(echo "$OPTARG" | tr 'a-z' 'A-Z')
          ;;
        q)
          QUIET_MODE=true
          ;;
        p)
          USE_CLIPBOARD=true
          ;;
        h)
          show_usage
          exit 0
          ;;
        \?)
          echo "Invalid option: -$OPTARG" >&2
          show_usage
          exit 1
          ;;
        :)
          echo "Option -$OPTARG requires an argument." >&2
          show_usage
          exit 1
          ;;
      esac
    done
    shift $((OPTIND -1))

    # --- Step 2: Check for all dependencies ---
    check_dependencies

    # --- Step 3: Set language-specific prompts ---
    local SYSTEM_PROMPT
    local TARGET_LANG_NAME

    case "$TARGET_LANG" in
        "ES")
            SYSTEM_PROMPT="You are an expert translator. Your only task is to
            translate the user's text into Spanish. Output only the
            translation, with no extra text, commentary, or apologies."
            TARGET_LANG_NAME="Spanish"
            ;;
        "EN")
            SYSTEM_PROMPT="You are an expert translator. Your only task is to
            translate the user's text into English. Output only the
            translation, with no extra text, commentary, or apologies."
            TARGET_LANG_NAME="English"
            ;;
        *)
            log_message "❌ Error: Unsupported language '$TARGET_LANG'. Use 'EN' or 'ES'."
            show_usage
            exit 1
            ;;
    esac

    # --- Step 4: Get user input with smart, automatic detection ---
    local user_ask
    if [ $# -gt 0 ]; then
        # 1. Highest precedence: Direct arguments
        user_ask="$*"
    elif ! [ -t 0 ]; then
        # 2. Second precedence: Piped input from stdin
        user_ask=$(cat)
    elif [ "$USE_CLIPBOARD" = true ]; then
        # 3. Third precedence: Paste from clipboard flag
        user_ask=$(xclip -o -selection clipboard)
    else
        # 4. Fallback: Interactive prompt
        user_ask=$(get_prompt "$TARGET_LANG_NAME")
    fi

    # Exit if no input was provided in any mode
    if [[ -z "$user_ask" ]]; then
        log_message "❌ Error: No text provided for translation. Exiting."
        exit 1
    fi

    # --- Step 5: Interactively select the model ---
    local MODEL
    MODEL=$(get_model)

    # --- Step 6: Run AI ---
    log_message "🧠 Running AI with model '$MODEL' to translate to $TARGET_LANG_NAME..."
    log_message "⌚ Please wait for the response..."

    local full_prompt="${SYSTEM_PROMPT}

# Translate the following sentence: \"$user_ask\""

    if ! echo "$full_prompt" | {{AI_COMMAND}} "$MODEL" >"$OUTFILE"; then
        log_message "❌ Error: Failed to run the AI command."
        exit 1
    fi

    # --- Step 7: Display output and notify ---
    if [[ -s "$OUTFILE" ]]; then
        # Action: Copy to clipboard (always happens)
        <"$OUTFILE" xclip -selection clipboard

        # Action: Send desktop notification (always happens)
        notify-send "AI Translation Complete" "Translation copied to clipboard."

        # The final translation is sent to standard output (stdout)
        cat "$OUTFILE"
    fi

    # --- Step 8: Optional shutdown ---
    shutdown_ai
}

# --- Script Entry Point ---
main "$@"
