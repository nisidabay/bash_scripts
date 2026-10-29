#!/usr/bin/env bash
#
# LEGACY — preserved as example, requires local AI backend
# Yad script for AI
# Supports two modes:
#   1. REFERENCE MODE: Refactor existing Bash code from clipboard into a function.
#   2. GENERATE MODE: Create a new Bash function from a natural language description.

set -euo pipefail
export GTK_THEME=Adwaita:dark

OUTFILE="$(mktemp /tmp/ai_function.XXXXXX.txt)"
ERRFILE="$(mktemp /tmp/ai_function.err.XXXXXX.txt)"
PROMPTFILE="$(mktemp /tmp/ai_prompt.XXXXXX.txt)"
trap 'rm -f "$OUTFILE" "$ERRFILE" "$PROMPTFILE"' EXIT

# --- Dependencies ---
need_cmd() {
    command -v "$1" >/dev/null 2>&1
}

if ! need_cmd yad; then
    echo "❌ YAD not installed. Install with: sudo pacman -S yad" >&2
    exit 1
fi
# Clipboard: prefer wl-clipboard if available AND in Wayland, else xclip
CLIP_COPY=""
CLIP_PASTE=""
# Check for Wayland
if [[ -n "${WAYLAND_DISPLAY:-}" ]] && need_cmd wl-copy && need_cmd wl-paste; then
    CLIP_COPY="wl-copy"
    CLIP_PASTE="wl-paste -n"
# Check for X11
elif [[ -n "${DISPLAY:-}" ]] && need_cmd xclip; then
    CLIP_COPY="xclip -selection clipboard"
    CLIP_PASTE="xclip -o -selection clipboard"
# Fallback attempt if only one is installed (less robust)
elif need_cmd wl-copy && need_cmd wl-paste; then
    CLIP_COPY="wl-copy"
    CLIP_PASTE="wl-paste -n"
elif need_cmd xclip; then
    CLIP_COPY="xclip -selection clipboard"
    CLIP_PASTE="xclip -o -selection clipboard"
else
    echo "❌ Missing clipboard tool: install wl-clipboard (for Wayland) or xclip (for X11)" >&2
    exit 1
fi
# notify-send optional
HAS_NOTIFY=0
if need_cmd notify-send; then
    HAS_NOTIFY=1
fi

# --- Helper Functions ---

show_error() {
    local msg="${1:-Unknown error}"
    yad --center --title="Error" --text="$msg" --button="OK:1" >/dev/null 2>/dev/null || true
}

show_info() {
    local msg="${1:-Info}"
    yad --center --title="Information" --text="$msg" --button="OK:0" >/dev/null 2>/dev/null || true
}

notify_user() {
    local title="$1" body="${2:-}"
    if [[ $HAS_NOTIFY -eq 1 ]]; then
        notify-send "$title" "$body" || true
    fi
}

# Try to make sure the AI server is reachable. If AI_HOST is unset, try to start local server.
ensure_ai_connection() {
    if {{AI_PS}} >/dev/null 2>&1; then
        return 0
    fi

    if [[ -n "${AI_HOST:-}" ]]; then
        show_error "Cannot reach remote AI at AI_HOST='$AI_HOST'. Check network/server and try again."
        exit 1
    fi

    # Start local server
    nohup {{AI_SERVE}} >/dev/null 2>&1 &
    # Wait up to ~5s for it to come up
    for _ in {1..50}; do
        if {{AI_PS}} >/dev/null 2>&1; then
            return 0
        fi
        sleep 0.1
    done

    show_error "Failed to start local AI server. Try running: {{AI_SERVE}}"
    exit 1
}

# Get clean model list (first column only)
get_models() {
    { {{AI_LIST_MODELS}} 2>/dev/null || true; } |
        awk 'NR>1 && NF>0 {gsub(/^[ \t]+|[ \t]+$/, "", $1); print $1}'
}

# Sanitize model string: only trim surrounding whitespace (do NOT strip hyphens etc.)
# Aggressively sanitize model string to avoid hidden chars
sanitize_model() {
    # Allow only: alnum, dot, underscore, slash, colon, and hyphen
    # Hyphen MUST be at the end to be treated literally by tr.
    printf '%s' "$1" | tr -cd '[:alnum:]._/:-'
}

# Validate model names (allow hyphens in both name and tag; optional owner/name form)
is_valid_model() {
    local m="$1"
    [[ -n "$m" ]] && [[ "$m" =~ ^[-A-Za-z0-9._]+(/[A-Za-z0-9._-]+)?(:[-A-Za-z0-9._]+)?$ ]]
}

# Check if model is available locally/remote
model_exists() {
    local m="$1"
    # Use '{{AI_SHOW_MODEL}}' to check presence
    {{AI_SHOW_MODEL}} "$m" >/dev/null 2>&1
}

# Pull model with pulsating progress
pull_model_with_progress() {
    local m="$1"
    local LOG
    LOG="$(mktemp /tmp/ai_pull.log.XXXXXX.txt)"

    # Start pulsating progress window
    yad --center --title="Pulling model…" \
        --progress --pulsate --no-cancel \
        --width=420 --height=140 \
        --text="Downloading: <b>$m</b>\nThis may take a while…" \
        >/dev/null 2>&1 &
    local YADPROG=$!

    # Run the pull
    if ! {{AI_PULL_MODEL}} "$m" >"$LOG" 2>&1; then
        kill "$YADPROG" 2>/dev/null || true
        wait "$YADPROG" 2>/dev/null || true
        show_error "Failed to pull model '$m':\n\n$(tail -n 25 "$LOG")"
        rm -f "$LOG"
        return 1
    fi

    kill "$YADPROG" 2>/dev/null || true
    wait "$YADPROG" 2>/dev/null || true
    rm -f "$LOG"
    return 0
}

# Ensure the selected/entered model is present, offer to pull if missing
ensure_model_present() {
    local m="$1"
    if model_exists "$m"; then
        return 0
    fi
    # Ask to pull
    yad --center --title="Model Not Found" \
        --text="Model <b>$m</b> is not available.\nWould you like to pull it now?" \
        --button="Pull:0" --button="Cancel:1" >/dev/null 2>&1 || return 1
    pull_model_with_progress "$m"
}

# Select model using YAD; if no local models, allow user to enter one
# Prints model name to stdout. Returns 1 on user cancellation.
select_model() {
    local models=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && models+=("$line")
    done < <(get_models)

    local selected=""
    local typed=""

    case ${#models[@]} in
    0)
        # No models listed: ask user to type one
        typed="$(yad --center --title="Enter Model Name" \
            --form --width=500 --height=140 \
            --field="Model (e.g. llama3.2:latest):" "" \
            --button="OK:0" --button="Cancel:1" 2>/dev/null)" || return 1 # User pressed Cancel

        typed="$(printf '%s' "$typed" | cut -d'|' -f1)"
        printf '%s\n' "$(sanitize_model "$typed")"
        ;;
    1)
        # Only one model, just use it
        printf '%s\n' "$(sanitize_model "${models[0]}")"
        ;;
    *)
        # Multiple models: show list
        selected="$(
            {
                printf '%s\n' "${models[@]}"
                echo "Other..."
            } |
                yad --center --title="Select AI Model" \
                    --list --no-headers --column="Model" \
                    --width=420 --height=280 --print-column=1 \
                    --button="OK:0" --button="Cancel:1" 2>/dev/null
        )" || return 1 # User pressed Cancel

        # Check if empty (should be caught by || return 1, but for safety)
        if [[ -z "$selected" ]]; then
            return 1
        fi

        # YAD list adds a newline, check for "Other..." robustly
        if [[ "$(printf '%s' "$selected" | tr -d '\n')" == "Other..." ]]; then
            typed="$(yad --center --title="Enter Model Name" \
                --form --width=500 --height=140 \
                --field="Model (e.g. llama3.2:latest):" "" \
                --button="OK:0" --button="Cancel:1" 2>/dev/null)" || return 1 # User pressed Cancel

            typed="$(printf '%s' "$typed" | cut -d'|' -f1)"
            printf '%s\n' "$(sanitize_model "$typed")"
        else
            printf '%s\n' "$(sanitize_model "$selected")"
        fi
        ;;
    esac
}

# Get clipboard content
get_clipboard() {
    # shellcheck disable=SC2086
    eval "$CLIP_PASTE" 2>/dev/null || true
}

# Copy content to clipboard
copy_to_clipboard() {
    # shellcheck disable=SC2086
    eval "$CLIP_COPY"
}

# Process function with AI
process_function() {
    local input_text="$1"
    local mode="$2"
    local model="$3"

    if [[ -z "$model" ]]; then
        echo "ERROR: Model name is empty!" >&2
        return 1
    fi

    : >"$OUTFILE"
    : >"$ERRFILE"
    : >"$PROMPTFILE"

    # Build prompt file to avoid escaping issues
    if [[ "$mode" == "refactor" ]]; then
        cat >"$PROMPTFILE" <<'PROMPT_END'
You are a Bash coding assistant. Your task is to refactor the provided code snippet into a robust, well-documented Bash function.

Your output MUST strictly adhere to the following format:

1. A descriptive function name.
2. Arguments for any hardcoded values ($1, $2, ...).
3. A docstring comment above the function explaining its purpose, arguments, and usage.
4. The complete, refactored function code.

Do NOT include conversational language, apologies, or any text beyond the required function and its documentation.

### Code to Refactor:
PROMPT_END
        echo "$input_text" >>"$PROMPTFILE"
    else
        cat >"$PROMPTFILE" <<'PROMPT_END'
You are a Bash coding assistant. Your task is to create a complete, robust, and well-documented Bash function based on the user's natural language description.

Your output MUST strictly adhere to the following format:

1. A descriptive, snake_case function name.
2. Arguments for any required inputs ($1, $2, ...).
3. A clear docstring comment above the function explaining:
    - Purpose
    - Required arguments
    - Expected behavior
    - Example usage
4. The complete, production-ready function code with error handling, validation, and comments.

Do NOT include conversational language, introductions, explanations, or markdown formatting outside the required format.

### Request:
PROMPT_END
        echo "$input_text" >>"$PROMPTFILE"
    fi

    # Run AI with file redirected as stdin
    if ! {{AI_COMMAND}} "$model" <"$PROMPTFILE" >"$OUTFILE" 2>"$ERRFILE"; then
        return 1
    fi

    return 0
}

# Run processing with message window
run_processing_with_message() {
    local input_text="$1"
    local mode="$2"
    local model="$3"

    # Start YAD info window in background
    yad --center \
        --title="Processing..." \
        --width=420 --height=150 \
        --on-top --no-buttons --skip-taskbar \
        --text="Processing with: <b>$model</b>\nMode: <b>$mode</b>\n\nPlease wait..." \
        --borders=12 --fontname="Sans 11" \
        --undecorated 2>/dev/null &
    local YAD_PID=$!

    # Give the window a moment to appear
    sleep 0.15

    # Run processing
    local status=0
    if ! process_function "$input_text" "$mode" "$model"; then
        status=1
    fi

    # Close the YAD window if still running
    kill -0 "$YAD_PID" 2>/dev/null && kill "$YAD_PID" 2>/dev/null || true
    wait "$YAD_PID" 2>/dev/null || true

    return $status
}

# --- Main GUI ---
main() {
    ensure_ai_connection

    # Preload model list (may be empty)
    local models=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && models+=("$line")
    done < <(get_models)

    while true; do
        # Mode selection dialog
        local mode_response
        mode_response=$(yad --center --title="Bash Function Generator" \
            --form --width=600 --height=300 \
            --field="Choose Mode:LBL" "" \
            --field="🔄 Refactor existing code from clipboard:CHK" "FALSE" \
            --field="✨ Generate new function from description:CHK" "FALSE" \
            --field="Input Method:LBL" "" \
            --field="📋 Load from clipboard:CHK" "FALSE" \
            --field="✏️ Manual input:CHK" "FALSE" \
            --button="Continue:0" \
            --button="Cancel:1" 2>/dev/null) || exit 0

        local mode_refactor
        local mode_generate
        local input_clipboard
        local input_manual
        mode_refactor=$(printf '%s' "$mode_response" | cut -d'|' -f2)
        mode_generate=$(printf '%s' "$mode_response" | cut -d'|' -f3)
        input_clipboard=$(printf '%s' "$mode_response" | cut -d'|' -f5)
        input_manual=$(printf '%s' "$mode_response" | cut -d'|' -f6)

        # Determine mode
        local mode=""
        if [[ "$mode_refactor" = "TRUE" && "$mode_generate" = "FALSE" ]]; then
            mode="refactor"
        elif [[ "$mode_generate" = "TRUE" && "$mode_refactor" = "FALSE" ]]; then
            mode="generate"
        else
            show_error "Please select exactly one mode (Refactor OR Generate)."
            continue
        fi

        # Get input text
        local input_text=""
        if [[ "$input_clipboard" = "TRUE" && "$input_manual" = "FALSE" ]]; then
            input_text=$(get_clipboard)
            if [[ -z "$input_text" ]]; then
                show_error "Clipboard is empty. Please copy some content first or use manual input."
                continue
            fi
        elif [[ "$input_manual" = "TRUE" && "$input_clipboard" = "FALSE" ]]; then
            # Show text input dialog
            local manual_response
            manual_response=$(yad --center --title="Enter Input" \
                --form --width=700 --height=500 \
                --field="Text to process:TXT" "" \
                --button="OK:0" --button="Cancel:1" 2>/dev/null) || continue
            input_text=$(printf '%s' "$manual_response" | cut -d'|' -f1)
        else
            show_error "Please select exactly one input method (Clipboard OR Manual)."
            continue
        fi

        if [[ -z "$input_text" ]]; then
            show_error "Input cannot be empty."
            continue
        fi

        # Select model (allow typing even if none are listed)
        local model=""
        local model_output=""

        # Call select_model and check its exit status
        model_output="$(select_model)"
        if [[ $? -ne 0 ]]; then
            # User cancelled model selection, just loop back
            continue
        fi

        model="$(sanitize_model "$model_output")"

        if [[ -z "$model" ]] || ! is_valid_model "$model"; then
            show_error "Failed to determine a valid model name. Please check '{{AI_LIST_MODELS}}' or enter a model like 'llama3.2:latest'."
            continue
        fi

        # Ensure server reachable (again, in case environment changed)
        ensure_ai_connection

        # Ensure model available (auto-pull if missing)
        if ! ensure_model_present "$model"; then
            # User canceled pull or it failed
            continue
        fi

        # Process the function with loading message
        run_processing_with_message "$input_text" "$mode" "$model"

        # Handle failures
        if [[ ! -s "$OUTFILE" ]]; then
            if [[ -s "$ERRFILE" ]]; then
                # Provide more helpful error messages
                if grep -Eqi 'invalid model path|no such model|not found|unknown model' "$ERRFILE"; then
                    show_error "Model '$model' could not be used.\n\n$(tail -n 20 "$ERRFILE")"
                    continue
                elif grep -Eqi 'connection refused|failed to connect|could not connect|dial tcp' "$ERRFILE"; then
                    show_error "Could not connect to AI server.\nIs it running? Try: {{AI_SERVE}}"
                    continue
                else
                    # Generic '{{AI_COMMAND}}' error
                    show_error "Processing failed:\n\n$(tail -n 20 "$ERRFILE")"
                    continue
                fi
            else
                # $OUTFILE is empty, $ERRFILE is also empty
                show_error "Processing failed: model returned no output."
                continue
            fi
        fi

        # --- Success: Show Results ---
        # This block only runs if the error checks above passed
        cat "$OUTFILE" | copy_to_clipboard || true # Added || true for safety
        notify_user "✅ Function Ready!" "Mode: $mode | Model: $model | Copied to clipboard"

        # Show result - wait until user presses "Close" (0) or ESC/close (1/252)
        yad --center --title="Generated Function (Copied to Clipboard)" \
            --text-info --wrap --width=700 --height=600 \
            --filename="$OUTFILE" \
            --button="Close:0" 2>/dev/null || true # Ignore exit code

        # Ask if user wants to process another
        yad --center --title="Process Another?" \
            --text="Would you like to process another function?" \
            --button="Yes:0" --button="No:1" 2>/dev/null

        if [[ $? -ne 0 ]]; then
            break
        fi
    done
}

main "$@"
