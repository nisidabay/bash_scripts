#!/usr/bin/env bash
#
# Display DWM/sxhkd keybindings in dmenu.
#
# Dependencies: dmenu, notify-send
# Environment: $WAYLAND_DISPLAY, $HOME

# 1. Load Pywal colors if available
if [ -f "${HOME}/bin/dmenu_wal.sh" ]; then
    source "${HOME}/bin/dmenu_wal.sh"
else
    # Fallback aesthetics
    DMENU_APPEARANCE=(-nb "#222222" -nf "#bbbbbb" -sb "#005577" -sf "#eeeeee")
fi

# 2. The Master List (Updated with your sxhkd mappings)
declare -a dwm_keys=(
    "--- SYSTEM CONTROLS ---"
    "Reload sxhkd shortcuts           (Ctrl + q)"
    "Rofi (App Launcher)              (Super + Ctrl + m)"
    "Toggle Picom (Compositor)        (Super + Ctrl + p)"
    "Restart Picom                   (Super + Ctrl + r)"
    "Take Screenshot (Flameshot)      (Super + Ctrl + g)"
    "System Actions Menu              (Super + c + a)"
    "Edit Configs                     (Super + c + e)"
    "System Conversion                (Super + c + s)"

    "--- APPLICATIONS ---"
    "File Manager (lf)                (Super + c + l)"
    "Web Browser (Firefox)            (Super + w)"
    "Calculator                       (Super + c + q)"
    "Notes                            (Super + c + n)"
    "Tutorial Videos                  (Super + c + v)"
    "Ollama Translate                 (Super + c + t)"
    "Ollama Explain                   (Super + c + o)"
    "Record Screen                    (Super + c + r)"
    "Clipboard Manager                (Super + c + c)"
    "Set Wallpaper                    (Super + c + w)"

    "--- WINDOW MANAGEMENT ---"
    "Close Window                     (Super + q)"
    "Focus Next Window                (Super + j)"
    "Focus Previous Window            (Super + k)"
    "Move Window Down Stack           (Super + Shift + j)"
    "Move Window Up Stack             (Super + Shift + k)"
    "Promote to Master (Zoom)          (Super + m)"
    "Toggle Floating                  (Super + Shift + Space)"
    "Toggle Fullscreen                (Super + f)"

    "--- AUDIO & MEDIA ---"
    "Raise Volume                     (AudioRaise)"
    "Lower Volume                     (AudioLower)"
    "Mute Toggle                      (AudioMute)"
    "Play/Pause Media                 (AudioPlay)"
    "Next/Prev Track                  (AudioNext/Prev)"

    "--- LAYOUTS & GAPS ---"
    "Layout Help (HTML)               (Super + c + y)"
    "Tile Layout                      (Super + t)"
    "Monocle Layout                   (Super + Shift + u)"
    "Toggle Gaps                      (Super + a)"
    "Reset Gaps                       (Super + Shift + a)"
)

# 3. Execution
choice=$(printf '%s\n' "${dwm_keys[@]}" | dmenu -c -l 20 -i "${DMENU_APPEARANCE[@]}" -p "Sxhkd Keys: ")

# 4. Feedback
if [ -n "$choice" ]; then
    notify-send -u low "DWM/Sxhkd Keybinding" "You selected:\n$choice" --icon=input-keyboard
fi
