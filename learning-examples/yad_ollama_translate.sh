#!/usr/bin/env bash
#
# LEGACY — preserved as example, requires local AI backend
# GUI Translator (YAD + AI)
# - Shows a simple "Translating..." message instead of a progress bar.
# - Soft-wrap in viewer and hard-wrap output so it's not a single long line.
# - Set WRAP_COLS env var to change wrap width (default 80).

set -euo pipefail
export GTK_THEME=Adwaita:dark

OUTFILE="$(mktemp /tmp/ollama_translation.XXXXXX.txt)"
ERRFILE="$(mktemp /tmp/ollama_translation.err.XXXXXX.txt)"
WRAPFILE="$(mktemp /tmp/ollama_translation.wrap.XXXXXX.txt)"
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

translate_text() {
	local text="$1"
	local lang_code="$2"
	local model="$3"

	if [[ -z "$model" ]]; then
		echo "ERROR: Model name is empty!" >&2
		return 1
	fi

	# Validate model exists
	if ! validate_model "$model"; then
		echo "ERROR: Model '$model' not found in '{{AI_LIST_MODELS}}'" >&2
		return 1
	fi

	local prompt=""
	case "$lang_code" in
	EN)
		prompt="You are an expert translator. Your only task is to translate the user's text into English. Output only the translation, with no extra text, commentary, or apologies."
		;;
	ES)
		prompt="You are an expert translator. Your only task is to translate the user's text into Spanish. Output only the translation, with no extra text, commentary, or apologies."
		;;
	*)
		echo "ERROR: Unsupported language code: $lang_code" >&2
		return 1
		;;
	esac

	local full_prompt="${prompt}

# Translate the following sentence:
${text}"

	: >"$OUTFILE"
	: >"$ERRFILE"

	# Use stdin piping with explicit model validation
	if ! printf '%s' "$full_prompt" | {{AI_COMMAND}} "$model" >"$OUTFILE" 2>"$ERRFILE"; then
		return 1
	fi

	return 0
}

# Show a non-interactive "Translating..." message window while the translation runs
run_translation_with_message() {
	local text="$1"
	local lang_code="$2"
	local model="$3"

	# Start YAD info window in background
	yad --center \
		--title="Translating..." \
		--width=420 --height=150 \
		--on-top --no-buttons --skip-taskbar \
		--text="Translating with: <b>$model</b>\nTarget: <b>$lang_code</b>\n\nPlease wait..." \
		--borders=12 --fontname="Sans 11" \
		--undecorated 2>/dev/null &
	local YAD_PID=$!

	# Give the window a moment to appear
	sleep 0.15

	# Run translation
	local status=0
	if ! translate_text "$text" "$lang_code" "$model"; then
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
	local en_selected="FALSE"
	local es_selected="FALSE"

	# Loop form to support clipboard paste
	local response exit_code
	while true; do
		response=$(yad --center --title="AI Translator" \
			--form --width=700 --height=420 \
			--field="Text to translate:TXT" "$user_text" \
			--field="🇬🇧 Translate to English:CHK" "$en_selected" \
			--field="🇪🇸 Translate to Spanish:CHK" "$es_selected" \
			--button="Translate:0" \
			--button="Paste from clipboard:2" \
			--button="Cancel:1" \
			--image-on-top --image="/usr/share/backgrounds/gnome/adwaita.jpg") || true

		exit_code=$?
		case "$exit_code" in
		0) # Translate
			user_text=$(printf '%s' "$response" | cut -d'|' -f1)
			en_selected=$(printf '%s' "$response" | cut -d'|' -f2)
			es_selected=$(printf '%s' "$response" | cut -d'|' -f3)
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

		# Validate language
		local target_lang=""
		if [[ "$en_selected" = "TRUE" && "$es_selected" = "FALSE" ]]; then
			target_lang="EN"
		elif [[ "$es_selected" = "TRUE" && "$en_selected" = "FALSE" ]]; then
			target_lang="ES"
		else
			show_error "Please select exactly one language to translate into."
			continue
		fi

		if [[ -z "$user_text" ]]; then
			show_error "Please enter text to translate."
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

		# Translate (show simple message instead of progress bar)
		run_translation_with_message "$user_text" "$target_lang" "$model"

		# Handle failures
		if [[ ! -s "$OUTFILE" ]]; then
			if [[ -s "$ERRFILE" ]]; then
				show_error "Translation failed:\n\n$(cat "$ERRFILE")"
				exit 1
			else
				show_error "Translation failed: model returned no output."
				exit 1
			fi
		fi

		# Hard wrap output so it's not a single long line
		fold -s -w "$WRAP_COLS" "$OUTFILE" >"$WRAPFILE"

		# Copy to clipboard and notify (use wrapped text)
		xclip -selection clipboard <"$WRAPFILE"
		notify-send "✅ Translation Complete" "Wrapped at ${WRAP_COLS} columns and copied to clipboard."

		# Show result (soft wrap in viewer)
		yad --center --title="Translation Result" \
			--text-info --wrap --width=600 --height=380 \
			--filename="$WRAPFILE" \
			--button="Close:0" >/dev/null

		exit 0
	done
}

main "$@"
