#!/usr/bin/env bash
#
# Manage AI prompts using Fuzzel and kitty on Wayland.
#
# Dependencies: fuzzel, kitty, wl-copy, notify-send, nvim, fzf
# Environment: $WAYLAND_DISPLAY, $HOME

PROMPTS_DIR="$HOME/ai_prompts/"
TERMINAL="kitty"

menu() {
    local prompt="$1"
    # --dmenu tells Fuzzel to act like dmenu (read from standard input)
    # --lines 20 sets the height
    fuzzel --dmenu --lines 20 -p "$prompt"
}

show_help() {
    cat <<'EOF' | menu 'Help - Press Enter to Close'
ai-prompts.sh v.1.0.0 - Wayland Edition
=======================================
Create markdown AI-Prompts in ~/ai_prompts

Actions on AI-Prompts:
  Add        →New AI-Prompt for name. Blank datetime AI-Prompt.
  Copy       →Copy AI-Prompt contents to the clipboard.
  Delete     →Delete selected AI-Prompt.
  Edit       →Edit AI-Prompt for modifications.
  List       →List available AI-Prompts. 
  Help       →Show this help
Configuration: 
  PROMPT_DIR="$HOME/ai_prompts/"
  TERMINAL="kitty"
EOF
}

check_dependencies() {
    local -a dependencies_array=("$@")
    local -a missing=()

    for program in "${dependencies_array[@]}"; do
        if ! command -v "$program" >/dev/null; then
            missing+=("$program")
        fi
    done

    if [[ "${#missing[@]}" -gt 0 ]]; then
        local missing_programs="${missing[*]}"
        notify_user "Missing Dependencies" "$missing_programs" "critical"
        exit 1
    fi
}

get_ai_prompt() {
    cd "$PROMPTS_DIR" || exit 1
    command ls -t1 | menu "Select an ai-prompt:"
}

is_ai_prompts_dir() {
    if ! [[ -d "$PROMPTS_DIR" ]]; then
        if ! mkdir -p "$PROMPTS_DIR"; then
            notify_user "Error" "Failed to create PROMPTS_DIR" "critical"
            return 1
        fi
    fi
    return 0
}

notify_user() {
    local title="$1"
    local message="$2"
    local severity="$3"

    case "$severity" in
    "normal")
        notify-send -u normal "$title" "$message" --icon=dialog-information
        ;;
    "critical")
        notify-send -u critical "$title" "$message" --icon=dialog-error
        ;;
    *)
        notify-send -u normal "$title" "$message" --icon=dialog-information
        ;;
    esac
}

open_ai_prompt_in_terminal() {
    local ai_prompt="$1"
    if [[ -z "$ai_prompt" ]]; then
        notify_user "PROMPT" "No ai-prompt selected" "critical"
        return 1
    fi
    # -w wait for the process to finish
    setsid -fw "$TERMINAL" -e nvim "$PROMPTS_DIR$ai_prompt" &>/dev/null
    if [[ -e "$PROMPTS_DIR$ai_prompt" ]]; then
        notify_user "AI-Prompt" "New AI-Prompt created!" "normal"
    else
        notify_user "AI-Prompt" "No AI-Prompt created!" "critical"
    fi
}

new_ai_prompt() {
    local name
    name=$(printf "" | menu "AI-Prompt name:")
    if [[ -z "$name" ]]; then
        name=$(date +'%F_%T' | tr ':' '-')
        name="${name//:/-}"
    fi
    notify_user "AI-Prompt" "New draft AI-Prompt" "normal"
    open_ai_prompt_in_terminal "$name.md"
}

select_action() {
    local -a actions=("Add" "Copy" "Delete" "Edit" "List" "Help")
    local choice
    choice=$(printf "%s\n" "${actions[@]}" | menu "AI-Prompts menu:")

    case $choice in
    "Add")
        new_ai_prompt
        ;;

    "Copy")
        local selected_ai_prompt
        selected_ai_prompt=$(get_ai_prompt)
        if [[ -n "$selected_ai_prompt" ]]; then
            cat "$PROMPTS_DIR$selected_ai_prompt" | wl-copy
            notify_user "AI-Prompt" "AI-Prompt copied to clipboard" "normal"
        else
            notify_user "AI-Prompt" "No AI-Prompt selected" "critical"
        fi
        ;;

    "Delete")
        local selected_ai_prompt confirm_delete
        selected_ai_prompt=$(get_ai_prompt)
        if [[ -n "$selected_ai_prompt" ]]; then
            confirm_delete=$(printf "Yes\nNo" | menu "Delete '$selected_ai_prompt'? (Yes/No)")
            if [[ "$confirm_delete" == "Yes" ]]; then
                rm -f "$PROMPTS_DIR$selected_ai_prompt"
                notify_user "AI-Prompt" "AI-Prompt deleted" "normal"
            else
                notify_user "AI-Prompt" "Deletion cancelled" "normal"
            fi
        else
            notify_user "AI-Prompt" "No AI-Prompt selected" "critical"
        fi
        ;;

    "Edit")
        local selected_ai_prompt
        selected_ai_prompt=$(get_ai_prompt)
        open_ai_prompt_in_terminal "$selected_ai_prompt"
        notify_user "AI-Prompt" "AI-Prompt edited" "normal"
        ;;

    "List")
        # Chains commands: Enter Dir -> List Files -> FZF -> Open NVIM if file chosen
        # Using Alacritty -e to execute bash
        setsid -f "$TERMINAL" -e bash -c "cd \"$PROMPTS_DIR\" && selected=\$(ls -t1 | fzf --preview 'cat {}') && [ -n \"\$selected\" ] && nvim \"\$selected\"" &>/dev/null
        ;;

    "Help")
        show_help
        ;;
    esac
}

main() {
    check_dependencies "wl-copy" "notify-send" "fuzzel" "nvim" "fzf" "kitty"
    if is_ai_prompts_dir; then
        select_action
    fi
}
main "$@"
