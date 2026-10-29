#!/usr/bin/env bash
#
# LEGACY — preserved as example, requires local AI backend
# GUI Explain concepts (YAD + AI)
# - Soft-wrap in viewer and hard-wrap output so it's not a single long line.
# - Set WRAP_COLS env var to change wrap width (default 80).

set -euo pipefail
export GTK_THEME=Adwaita:dark

OUTFILE="$(mktemp /tmp/ollama_explanation.XXXXXX.txt)"
ERRFILE="$(mktemp /tmp/ollama_explanation.err.XXXXXX.txt)"
WRAPFILE="$(mktemp /tmp/ollama_explanation.wrap.XXXXXX.txt)"
trap 'rm -f "$OUTFILE" "$ERRFILE" "$WRAPFILE"' EXIT

# Number of columns to wrap at (hard wrap)
WRAP_COLS="${WRAP_COLS:-80}"

# --- Dependencies ---
if ! command -v yad &>/dev/null; then
	echo "❌ YAD not installed. Install with: sudo pacman -S yad" >&2
	exit 1
fi

for cmd in ollama xclip notify-send; do
	if ! command -v "$cmd" &>/dev/null; then
		echo "❌ Missing dependency: $cmd" >&2
		exit 1
	fi
done

# --- Helper Functions ---

show_error() {
	local msg="${1:-Unknown error}"
	yad --center --title="Error" --text="$msg" --button="OK:1" >/dev/null
}

# Get clean model list (first column, skip header)
get_models() {
	{{AI_LIST_MODELS}} 2>/dev/null | awk 'NR>1 && NF>0 {print $1}' | grep -v '^$'
}

# Clean up model name - strip whitespace and pipes
clean_model_name() {
	local name="$1"
	# Remove trailing pipe (from YAD)
	name="${name%|}"
	# Remove leading/trailing whitespace
	name="$(echo "$name" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
	echo "$name"
}

# Validate that the model actually exists locally
validate_model() {
	local model="$1"
	{{AI_LIST_MODELS}} 2>/dev/null | awk 'NR>1 {print $1}' | grep -Fx "$model" >/dev/null
}

select_model() {
	local models=()
	while IFS= read -r line; do
		[[ -n "$line" ]] && models+=("$line")
	done < <(get_models)

	case ${#models[@]} in
	0)
		show_error "❌ No AI models found.\n\nTry:\n  {{AI_PULL_MODEL}} llama3\n  {{AI_PULL_MODEL}} mistral\n  etc."
		exit 1
		;;
	1)
		clean_model_name "${models[0]}"
		;;
	*)
		local selected=""
		selected="$(
			printf '%s\n' "${models[@]}" | yad --center --title="Select Model" \
				--list --no-headers --column="Model" \
				--width=420 --height=280 \
				--button="OK:0" --button="Cancel:1" 2>/dev/null || true
		)"

		if [[ -z "${selected:-}" ]]; then
			exit 1
		fi

		clean_model_name "$selected"
		;;
	esac
}

explain_text() {
	local text="$1"
	local model="$2"

	if [[ -z "$model" ]]; then
		echo "ERROR: Model name is empty!" >&2
		return 1
	fi

	# Validate model exists
	if ! validate_model "$model"; then
		echo "ERROR: Model '$model' not found in '{{AI_LIST_MODELS}}'" >&2
		return 1
	fi

	local prompt="You are a knowledgeable assistant. Your task is to provide clear, concise, and helpful explanations. Explain the following concept or answer the following question in a way that is easy to understand."

	local full_prompt="${prompt}

# Explain or answer this:
${text}"

	: >"$OUTFILE"
	: >"$ERRFILE"

	# Use stdin piping with explicit model validation
	if ! printf '%s' "$full_prompt" | {{AI_COMMAND}} "$model" >"$OUTFILE" 2>"$ERRFILE"; then
		return 1
	fi

	return 0
}

run_explanation_with_message() {
	local text="$1"
	local model="$2"

	# Start YAD info window in background
	yad --center \
		--title="Generating Explanation..." \
		--width=420 --height=150 \
		--on-top --no-buttons --skip-taskbar \
		--text="Processing with: <b>$model</b>\n\nPlease wait..." \
		--borders=12 --fontname="Sans 11" \
		--undecorated 2>/dev/null &
	local YAD_PID=$!

	# Give the window a moment to appear
	sleep 0.15

	# Run explanation
	local status=0
	if ! explain_text "$text" "$model"; then
		status=1
	fi

	# Close the YAD window if still running
	kill -0 "$YAD_PID" 2>/dev/null && kill "$YAD_PID" 2>/dev/null || true
	wait "$YAD_PID" 2>/dev/null || true

	return $status
}

# --- Main GUI ---
main() {
	# Preload model list
	local models=()
	while IFS= read -r line; do
		[[ -n "$line" ]] && models+=("$line")
	done < <(get_models)

	if [ ${#models[@]} -eq 0 ]; then
		show_error "No AI models found. Pull one first."
		exit 1
	fi

	# Form state
	local user_text=""

	# Loop form to support clipboard paste
	local response exit_code
	while true; do
		response=$(yad --center --title="AI Explain" \
			--form --width=700 --height=420 \
			--field="Concept to explain:TXT" "$user_text" \
			--button="Explain:0" \
			--button="Paste from clipboard:2" \
			--button="Cancel:1" \
			--image-on-top --image="/usr/share/backgrounds/gnome/adwaita.jpg") || true

		exit_code=$?
		case "$exit_code" in
		0) # Explain
			user_text=$(printf '%s' "$response" | cut -d'|' -f1)
			;;
		2) # Paste from clipboard
			if ! user_text=$(xclip -selection clipboard -o 2>/dev/null); then
				show_error "Clipboard is empty or inaccessible."
				continue
			fi
			continue
			;;
		*) # Cancel/close
			exit 0
			;;
		esac

		if [[ -z "$user_text" ]]; then
			show_error "Please enter a concept or question to explain."
			continue
		fi

		# Select model
		local model=""
		if [ ${#models[@]} -eq 1 ]; then
			model="$(clean_model_name "${models[0]}")"
		else
			model="$(select_model)"
		fi

		model="$(clean_model_name "$model")"

		if [[ -z "$model" ]]; then
			show_error "No model selected."
			continue
		fi

		# Validate model exists before using it
		if ! validate_model "$model"; then
			show_error "Model '$model' not found.\n\nAvailable models:\n$(get_models | paste -sd, -)"
			continue
		fi

		# Generate explanation
		run_explanation_with_message "$user_text" "$model"

		# Handle failures
		if [[ ! -s "$OUTFILE" ]]; then
			if [[ -s "$ERRFILE" ]]; then
				show_error "Explanation failed:\n\n$(cat "$ERRFILE")"
				exit 1
			else
				show_error "Explanation failed: model returned no output."
				exit 1
			fi
		fi

		# Hard wrap output so it's not a single long line
		fold -s -w "$WRAP_COLS" "$OUTFILE" >"$WRAPFILE"

		# Copy to clipboard and notify (use wrapped text)
		xclip -selection clipboard <"$WRAPFILE"
		notify-send "✅ Explanation Complete" "Wrapped at ${WRAP_COLS} columns and copied to clipboard."

		# Show result (soft wrap in viewer)
		yad --center --title="Explanation Result" \
			--text-info --wrap --width=600 --height=380 \
			--filename="$WRAPFILE" \
			--button="Close:0" >/dev/null

		exit 0
	done
}

main "$@"
