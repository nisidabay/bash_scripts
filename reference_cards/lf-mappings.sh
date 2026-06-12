#!/usr/bin/env bash
#
# Show lf file manager mappings in dmenu.
#
# Dependencies: dmenu
# Environment: $WAYLAND_DISPLAY, $HOME

declare -a mappings

mappings=(
    ".: set hidden!"
    "/: search"
    "<enter>: open"
    "C: clear"
    "DD: delete"
    "E: edit-config"
    "H: top"
    "L: bottom"
    "R: reload"
    "U: unselect"
    "V: open file in nvim"
    "W: open terminal"
    "ZP: trash-put"
    "ZR: restore_trash"
    "ZS: cd ~/.local/share/Trash/files"
    "ZZ: empty-trash"
    "_um: umountusbs"
    "ab: targz"
    "ag :targz"
    "at: tar"
    "au :unarchive"
    "az: zip"
    "ch: chmod"
    "e: open"
    "ee: open"
    "f: push :fzf"
    "gD: cd ~/Downloads"
    "gM: cd ~/Music"
    "gb: cd ~/bin"
    "gc: cd ~/.config"
    "gd: cd ~/Documents"
    "gh: cd ~"
    "gl: cd ~/.config/lf"
    "gm: cd ~/Movies"
    "gp: cd ~/Pictures"
    "gps: cd ~/Pictures/screenshots"
    "gpw: cd ~/Pictures/wallpapers"
    "gr: cd ~/Downloads/Refactor"
    "gs: fzf_search"
    "gt: fzf_jump"
    "map \;j cd ~"
    "md: mkdir"
    "mf: mkfile"
    "mm: cd /media"
    "msf: sudomkfile"
    "mu: mountusbs"
    "ob: open Browser"
    "op: cd ~/proyectos_git"
    "os: open terminal"
    "p: paste"
    "r: rename"
    "sp: scratchpad"
    "ss: stripspace"
    "sw: setwallpaper"
    "w: open"
    "x: cut"
    "y: copy"
    "zp: toggle_preview"
)

# Use dmenu to display the list of vim mappings
printf '%s\n' "${mappings[@]}" | dmenu -i -p "lf (file manager) mappings" -l 20 -fn Monospace-14
