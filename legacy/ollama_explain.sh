#!/usr/bin/env bash

# LEGACY — preserved as example, requires local AI backend
#
# ollama_explain.sh
#
# Script to interact with Ollama, now fully compatible with both X11 and Wayland.
#
# Local models used:
#   {{MODEL_NAME}} (size 2GB)
#   {{MODEL_NAME}} (size 4.7GB)
#
# Install ollama via:
# curl -fsSL https://ollama.com/install.sh | sh
#
# To install the models run:
# {{AI_COMMAND}} {{MODEL_NAME}}
# {{AI_COMMAND}} {{MODEL_NAME}}

# --- Configuration ---
MODEL=""
EDITOR="${EDITOR:-nvim}"
PAGER="${EDITOR:-vim}"
VERSION='1.0.1'
# Where to save the chats
CHAT_HISTORY_FILE="$HOME/.ollama_explain_history.log"
touch "$CHAT_HISTORY_FILE" # Ensure file exists

# Checks for required command-line tools
check_dependencies() {
	local -a dependencies_array=("$@")
	local -a missing=()

	for program in "${dependencies_array[@]}"; do
		if ! command -v "$program" >/dev/null; then
			missing+=("$program")
		fi
	done

	if [[ "${#missing[@]}" -gt 0 ]]; then
		echo "❌Missing Dependencies: ${missing[*]}" >&2
		exit 1
	fi
}

# --- Environment Detection (Wayland vs X11) ---
if [[ -n "$WAYLAND_DISPLAY" ]]; then
	# === Wayland Setup ===
	check_dependencies "foot" "wl-copy"
	TERMINAL="foot"
	COPY_CMD="wl-copy"

	# Fuzzel wrapper for dmenu-like behavior — matches dmenu in UX and response format
	menu() {
		local prompt="$1"
		fuzzel --dmenu --match-mode=exact -p "$prompt" | tr -d '\r'
	}

else
	# === X11 Setup ===
	check_dependencies "st" "xsel"
	TERMINAL="st"
	COPY_CMD="xsel -ib"

	# Source wal theme if available (for dmenu visual style)
	if [[ -f "${HOME}/bin/dmenu_wal.sh" ]]; then
		source "${HOME}/bin/dmenu_wal.sh"
	fi

	# Wrapper for dmenu — supports custom appearance via DMENU_APPEARANCE
	menu() {
		local prompt="$1"
		dmenu -c -i -l 20 "${DMENU_APPEARANCE[@]:-}" -p "$prompt" | tr -d '\r'
	}
fi

# Run a command with sudo
run_as_sudo() {
	sudo "$@"
}

# Shut down the Ollama server process gracefully
kill_ollama_server() {
	if pgrep -x "ollama" &>/dev/null; then
		echo "🛑 Shutting down Ollama server..."
		if run_as_sudo pkill ollama; then
			echo "✅ Ollama server has been shut down."
		else
			echo "❌ Failed to shut down Ollama server. Check sudo permissions." >&2
		fi
	else
		echo "🔴 Ollama server is not running."
	fi
}

# Prompt user to select a model via dmenu or fuzzel (based on environment)
get_model() {
	local filter_models
	local selected_model

	# Get list of available models from {{AI_LIST_MODELS}}
	filter_models=$({{AI_LIST_MODELS}} | awk 'NR>1 {print $1}')

	if [[ -z "$filter_models" ]]; then
		echo "❌ Error: No models available." >&2
		exit 1
	fi

	# Use menu() to select model (fuzzel on Wayland, dmenu on X11)
	selected_model=$(echo "$filter_models" | menu "Select Ollama Model: ")

	if [[ -z "$selected_model" ]]; then
		echo "❌ Error: No model selected. Exiting." >&2
		exit 1
	fi

	echo "$selected_model"
}

# Display help menu (supports both terminals)
show_menu() {
	echo "---------------------------------------------------"
	echo "--- Ollama Explains Menu ---"
	echo "---------------------------------------------------"
	echo
	echo "Version: $VERSION"
	echo "Commands:"
	echo "  !clear      - Clear the chat history."
	echo "  !history    - View the chat history."
	echo "  !kill       - Stop the Ollama server and exit."
	echo "  !menu       - Show this help menu."
	echo "  !new_chat   - Start a new chat. Clear the history."
	echo "  !recover    - Select a line from history to copy."
	echo "  !switch     - Change current AI model on the fly."
	echo "  exit | quit - Quit the script."
	echo ""
	echo "Multi-line Input:"
	echo "  Paste a block of text and press Ctrl+D to submit."
	echo
	echo "---------------------------------------------------"
	echo
}

# View chat history (piped through pager)
handle_history() {
	if [[ -s "$CHAT_HISTORY_FILE" ]]; then
		cat "$CHAT_HISTORY_FILE" | "$PAGER"
	else
		echo "📜 History is empty."
	fi
}

# Recover a line from history and copy to clipboard
handle_recover() {
	if [[ -s "$CHAT_HISTORY_FILE" ]]; then
		cat "$CHAT_HISTORY_FILE" | menu "Select line to copy: " | $COPY_CMD
		echo "📋 Selected line copied to clipboard."
	else
		echo "📜 History is empty."
	fi
}

# Clear the chat history file
handle_clear() {
	: >"$CHAT_HISTORY_FILE"
	echo "📜 History has been cleared."
}

# Handle the main chat interaction with Ollama
handle_chat() {
	local user_ask="$1"
	local full_prompt
	local conversation_history
	local response
	local formatted_response

	# Read existing conversation from history file (safe, non-destructive)
	if [[ -s "$CHAT_HISTORY_FILE" ]]; then
		conversation_history=$(<"$CHAT_HISTORY_FILE")
	fi

	# Build prompt: history + current input
	full_prompt="$conversation_history\n\nUser request: $user_ask"

	echo "🧠 Thinking..."

	# Run AI and strip ANSI/escape codes
	response=$({{AI_COMMAND}} "$MODEL" "$full_prompt" | sed 's/.*\r//; s/\x1b$[0-9;]*[mGKH]//g')

	if [[ -n "$response" ]]; then
		# Trim leading newlines
		while [[ "$response" == $'\n'* ]]; do
			response="${response:1}"
		done

		# Format and display output
		formatted_response="🤖 AI: $response"
		echo -e "\n$formatted_response"

		# Copy response to clipboard (uses COPY_CMD from environment)
		echo "$response" | $COPY_CMD

		echo
		echo "-----------------------------------------------"
		echo -e "📋 Response copied to clipboard."
		echo -e "📜 The whole chat is available with !history"
		echo "-----------------------------------------------"

		# Append new turn to history file
		printf "👦 You: %s\n\n%s\n\n" "$user_ask" "$formatted_response" >>"$CHAT_HISTORY_FILE"
	else
		echo "⚠️ Warning: Ollama returned an empty or filtered-out response."
	fi
}

# --- Main Execution ---

main() {
	local rest_of_input
	local full_prompt

	check_dependencies "ollama" "nvim"

	MODEL=$(get_model)
	if [[ -z "$MODEL" ]]; then
		exit 1
	fi

	echo "-------------------------------------"
	echo "🦙 Ollama explains. Local chat 🦙"
	echo "🧠 Using model: '$MODEL'"
	echo "⌨  Type '!menu' for commands."
	echo "-------------------------------------"
	echo ""

	# Start interactive loop
	while true; do
		read -rp "👦 You: " chat_line

		# Check if there's more input (e.g., pasted text)
		if read -t 0 -r pasted_text; then
			# Multi-line mode — combine all input
			rest_of_input=$(cat)

			full_prompt="$chat_line"$'\n'"$pasted_text"
			[[ -n "$rest_of_input" ]] && full_prompt+=$'\n'"$rest_of_input"

			handle_chat "$full_prompt"
		else
			# Single-line input handling
			case "$chat_line" in
			"exit" | "quit")
				{{AI_STOP_MODEL}} "$OLD_MODEL" &>/dev/null
				echo "👋 Goodbye!"
				break
				;;
			"!menu")
				show_menu
				;;
			"!history")
				handle_history
				;;
			"!recover")
				handle_recover
				;;
			"!clear")
				handle_clear
				;;
			"!new_chat")
				handle_clear
				clear
				;;
			"!kill")
				kill_ollama_server
				break
				;;
			"!switch")
				# Save old model to clean up memory
				OLD_MODEL="$MODEL"
				MODEL=$(get_model)

				echo "🧹 Cleaning up memory..."
				{{AI_STOP_MODEL}} "$OLD_MODEL" &>/dev/null

				echo "🧠 Switched to '$MODEL'."
				;;
			"")
				continue
				;;
			*)
				# Treat as a prompt
				handle_chat "$chat_line"
				;;
			esac
		fi
	done
}

# Entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
