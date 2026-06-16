# r_bash_scripts — Index

198 Bash scripts across 10 directories. Personal collection for Arch Linux + dwm/niri. Dead scripts pruned — platform-mismatched, stubs, one-liners.

| Dir | Count | Purpose |
|-----|-------|---------|
| [desktop](#desktop) | 26 | TUI toys, dmenu tools, wallpaper, color pickers |
| [dev](#dev) | 7 | Templates, bash library, git checker, getopts |
| [files](#files) | 17 | File operations, text processing, string splitting |
| [learning](#learning) | 12 | Educational: pure bash, concepts, loggers, progress bars |
| [media](#media) | 4 | Audio/video format converters |
| [reference_cards](#reference_cards) | 36 | dmenu/fuzzel-launched interactive cheat sheets |
| [statusbar](#statusbar) | 33 | dwmblocks status bar modules (`sb-*`) |
| [system](#system) | 36 | Network, security, sysadmin, system management |
| [util](#util) | 8 | Toys, git observers, random generators |
| [legacy](#legacy) | 9 | Archived Ollama scripts (obfuscated for public repo) |

---

## desktop/

TUI interface scripts, wallpaper changers, dmenu/Fuzzel tools, color pickers. Most are Wayland-capable or dual X11/Wayland.

| Script | Lines | Dependencies | Purpose |
|--------|-------|-------------|---------|
| `banner.sh` | 32 | — | Display a colored banner |
| `change_bg_lnx_feh.sh` | 39 | feh, shuf | Change background image using feh |
| `change_bg_nitrogen.sh` | 32 | nitrogen | Change background image using nitrogen |
| `change_dwm_colors.sh` | 38 | sed, grep, cut | Change dwm colors from pywal |
| `colors_bash.sh` | 58 | — | Demonstrate ANSI color codes |
| `color_test.sh` | 20 | — | Display color combinations table |
| `create_list.sh` | 11 | file | List ASCII files in current directory |
| `help_and_menu.sh` | 53 | — | Help and menu template |
| `menu.sh` | 92 | — | Menu template using case statements |
| `menu_univ.sh` | 62 | — | Universal menu with getopts |
| `printTable.sh` | 85 | column, awk, sed | Print a formatted table |
| `prompt_continue.sh` | 13 | — | Prompt to continue inside a loop |
| `select-menu.sh` | 35 | — | Throw-away select menu |
| `show_colors.sh` | 17 | tput | Show available terminal colors |
| `spinner_log.sh` | 82 | stat, tail | Spinner with log file monitoring |
| `spinner.sh` | 28 | — | Spinner progress indicator |
| `status_indicator.sh` | 28 | — | Show a loading status indicator |
| `stty_hide_input.sh` | 20 | stty | Hide input with stty for password entry |
| `tkinter_color.sh` | 566 | dmenu, xclip, notify-send | Select and copy Tkinter color codes via dmenu |
| `tput_clock.sh` | 100 | tput, banner | Display a terminal clock |
| `tput_colors.sh` | 15 | tput | Display available terminal colors |
| `tput_menu.sh` | 67 | tput | Menu-driven system information program |
| `universal_notifications.sh` | 28 | notify-send, osascript | Display desktop notifications |
| `urlmanager.sh` | 340 | dmenu, xclip/wl-copy, notify-send, browser | URL manager with dmenu and ROT13 encoding |
| `user_confirm.sh` | 55 | — | Ask user for confirmation |
| `vifm-mappings.sh` | 103 | dmenu/fuzzel, notify-send | Show Vifm custom keys and commands via dmenu/fuzzel |

---

## dev/

Templates, the bash library, git tools, and development helpers.

| Script | Lines | Dependencies | Purpose |
|--------|-------|-------------|---------|
| `bash_library.sh` | 2,086 | bash, curl, jq, python, sed, awk, tar, unzip, lsof, iptables, dd, git, md5sum | Collection of bash utility functions |
| `check_git_status.sh` | 66 | git | Verify the status of git directories |
| `getopts_skeleton.sh` | 72 | — | Skeleton demonstrating getopts usage |
| `getopts_template.sh` | 73 | — | Template for processing command-line options with getopts |
| `script_index.sh` | 27 | column, grep, sed | Generate an index of scripts in the current directory |
| `sourcing_example.sh` | 17 | — | Demonstrate sourcing a script in Bash |
| `valid_command.sh` | 18 | — | Check if provided arguments are valid shell commands |

---

## files/

File operations, text processing, string manipulation. Educational + practical.

| Script | Lines | Dependencies | Purpose |
|--------|-------|-------------|---------|
| `change_extension.sh` | 126 | bash | Change file extensions in the current directory |
| `change_permissions.sh` | 26 | chmod | Change permissions for files and directories |
| `chk_file.sh` | 20 | tput | Check if a file exists |
| `command_in_path.sh` | 48 | bash | Find commands or executable scripts in PATH |
| `convert_lowercase_files.sh` | 14 | tr, mv | Convert upper-case file names to lower-case |
| `count_words_in_file.sh` | 18 | wc | Count the words in a file |
| `create_files.sh` | 16 | touch, seq | Create a number of files specified by the user |
| `get_specific_files.sh` | 26 | bash | Get specific files from a directory |
| `list_unhidden_dirs.sh` | 8 | find, tee | Create a list of unhidden folders in HOME |
| `openFileDmenu.sh` | 12 | dmenu, find, xdg-open | Open file with dmenu |
| `read_file.sh` | 9 | bash | Read file or stdin line by line |
| `read_from_file.sh` | 13 | bash | Read and display a file line by line |
| `repeat_string.sh` | 16 | printf | Print a string a number of times |
| `rm_empty_lines.sh` | 39 | cp, mv | Remove empty lines from a file and make a backup |
| `split_string.sh` | 120 | bash, tr | Reference: split a string into an array — 5 methods |
| `string_to_lower.sh` | 23 | tr | Convert string to lowercase |

---

## learning/

Educational scripts: pure Bash examples, concepts, loggers, progress bars. Reference material — not daily drivers.

| Script | Lines | Dependencies | Purpose |
|--------|-------|-------------|---------|
| `backup_helper.sh` | 271 | — | Create file backups with timestamps |
| `error_loggin.sh` | 92 | — | Demonstrate temporary SIGINT ignore during critical operations |
| `file_operations.sh` | 273 | — | Perform common file operations |
| `log_analyzer.sh` | 244 | — | Parse and analyze log files |
| `nameref_indirect_var-1.sh` | 63 | — | Demonstrate nameref and indirect variable expansion for pass-by-reference |
| `nameref_indirect_var-2.sh` | 97 | — | Demonstrate nameref and indirect array modification |
| `network_info.sh` | 180 | — | Display network interface information |
| `process_manager.sh` | 173 | — | Manage system processes |
| `progresbar_1.sh` | 23 | — | Simple terminal progress bar example |
| `progressbar_2.sh` | 46 | — | Visual terminal progress bar |
| `service_checker.sh` | 266 | — | Check systemd service status |
| `system_info.sh` | 123 | — | Display system information |

---

## media/

Audio/video format converters. Some are platform-specific (tagged below).

| Script | Lines | Dependencies | Purpose |
|--------|-------|-------------|---------|
| `aac2mp3_clm.sh` | 185 | lame, mplayer | Convert one or more aac/m4a files to mp3 |
| `avi2mp4.sh` | 182 | ffmpeg, mencoder, gdialog, zenity, file | Convert FLV/RM/MPEG/AVI to AVI/MP4 |
| `flac2mp3.sh` | 11 | ffmpeg | Convert FLAC files to MP3 |
| `txt2mp3.sh` | 174 | pico, lame, mpg123, aplay | **Linux** — Text to MP3 |

---

## reference_cards/

dmenu/Fuzzel-launched interactive cheat sheets. Consistent template: declare data array → pipe to launcher → copy result to clipboard. Dual X11/Wayland support. These are daily-use tools, not archival.

| Script | Lines | Platform | Purpose |
|--------|-------|----------|---------|
| `acronyms.sh` | 119 | dual | Quick access to common acronyms |
| `arch_pacman.sh` | 100 | dual | Quick access to common Pacman and BlackArch commands |
| `dmenu_vim_mappings.sh` | 27 | X11 | Open vim mappings file in terminal editor |
| `dwm_keybindings.sh` | 71 | X11 | Display DWM/sxhkd keybindings in dmenu |
| `fd-commands.sh` | 124 | dual | Show and insert common fd commands |
| `fd_find_notes.sh` | 122 | dual | Show and insert fd/find comparison commands |
| `fuzzel-ai-prompts.sh` | 175 | Wayland | Manage AI prompts using Fuzzel and kitty |
| `git_commands.sh` | 128 | dual | Show and insert common git commands |
| `git_commits.sh` | 100 | dual | Quick access to Conventional Commit message prefixes |
| `info-redshift-temp.sh` | 20 | X11 | Display redshift color temperature |
| `lf-mappings.sh` | 71 | X11 | Show lf file manager mappings in dmenu |
| `prompt_sequences.sh` | 112 | dual | Show and insert shell prompt variables |
| `shell_arrays.sh` | 117 | dual | Select and copy common Bash array operations |
| `shell_awk.sh` | 114 | dual | Show and insert common awk patterns |
| `shell_bash_help.sh` | 51 | X11 | Open Bash help page in dmenu |
| `shell_bash_variables.sh` | 120 | dual | Copy common Bash special and built-in variables |
| `shell_character_classes.sh` | 97 | dual | Copy POSIX character classes |
| `shell_curl.sh` | 113 | dual | Show and insert common curl patterns |
| `shell_cut.sh` | 110 | dual | Show and insert common cut patterns |
| `shell_dd.sh` | 110 | dual | Show and insert common dd patterns |
| `shell_declare.sh` | 111 | dual | Select and copy Bash declare statements |
| `shell_extended_patterns.sh` | 100 | dual | Copy shell extended globbing patterns |
| `shell_find_notes.sh` | 101 | dual | Quick access to common find commands |
| `shell_grep_flags.sh` | 126 | dual | Show and insert common grep flags and patterns |
| `shell_helper.sh` | 103 | dual | Select Bash test expressions and flags |
| `shell_jq.sh` | 115 | dual | Show and insert common jq patterns |
| `shell_loops.sh` | 29 | dual | Show and insert shell loop templates |
| `shell_parameter_expansion.sh` | 119 | dual | Show and insert shell parameter expansions |
| `shell_redirection.sh` | 137 | dual | Show and insert shell redirection patterns |
| `shell_sed.sh` | 116 | dual | Show and insert common sed patterns |
| `shell_shopt.sh` | 112 | dual | Quick access to common Bash shopt options |
| `shell_sort.sh` | 112 | dual | Show and insert common sort patterns |
| `shell_system_fonts.sh` | 32 | X11 | Display system fonts via dmenu |
| `shell_tr.sh` | 111 | dual | Show and insert common tr patterns |
| `shell_watch_files.sh` | 124 | dual | Show and insert watch commands |
| `shell_wget.sh` | 113 | dual | Show and insert common wget patterns |

---

## statusbar/

dwmblocks status bar modules. Active set defined in `~/r_suckless/dwmblocks/config.h`. Old `dwm_*` variants archived in `statusbar/archive/`.

### Active modules

| Script | Lines | Dependencies | Purpose |
|--------|-------|-------------|---------|
| `sb-alarm.sh` | 23 | alarm | Display upcoming alarms |
| `sb-backlight.sh` | 11 | xbacklight | Display backlight brightness |
| `sb-battery.sh` | 40 | notify-send | Display battery status with emoji |
| `sb-bluetooth.sh` | 61 | bluetoothctl, notify-send | Display Bluetooth status |
| `sb-ccurse.sh` | 22 | calcurse | Show closest calcurse appointment |
| `sb-cpubars.sh` | 45 | — | Display CPU load as bars |
| `sb-cpu.sh` | 17 | sensors, notify-send | Display CPU temperature and hogs |
| `sb-doppler.sh` | 289 | curl, notify-send | Show Doppler radar image |
| `sb-forecast.sh` | 50 | curl, jq | Display weather forecast |
| `sb-internet.sh` | 48 | nmcli, notify-send | Display internet connection status |
| `sb-ipaddress.sh` | 123 | curl, geoiplookup, notify-send | Display public IP address and geo-location |
| `sb-iplocate.sh` | 43 | curl, geoiplookup | Display public IP and country flag |
| `sb-kbselect.sh` | 40 | dmenu, setxkbmap | Change keyboard layout via dmenu |
| `sb-loadavg.sh` | 25 | — | Show average system load |
| `sb-mailbox.sh` | 44 | offlineimap, notmuch, notify-send | Display unread mail count |
| `sb-mailbox.chatty.sh` | 47 | offlineimap, notify-send | Display unread mail count with sync |
| `sb-moonphase.sh` | 40 | curl | Display current moon phase |
| `sb-mpc.sh` | 46 | mpc | Show mpc playback status |
| `sb-music.sh` | 22 | cmus, notify-send | Display music status |
| `sb-nettraf.sh` | 30 | bmon, notify-send | Display network traffic |
| `sb-networkmanager.sh` | 28 | NetworkManager, curl | Show network connection info |
| `sb-ollama.sh` | 27 | ollama, notify-send | Run Ollama from dwmblocks |
| `sb-packages.sh` | 36 | checkupdates, notify-send | Display available package updates |
| `sb-price.sh` | 56 | curl | Display cryptocurrency price |
| `sb-pulse.sh` | 36 | pamixer | Show PulseAudio master volume |
| `sb-resources.sh` | 34 | — | Show memory, CPU, and storage info |
| `sb-spotify.sh` | 37 | playerctl, notify-send | Display Spotify song info |
| `sb-tasks.sh` | 19 | tsp, notify-send | Display running/queued task count |
| `sb-torrent.sh` | 29 | transmission-remote, notify-send | Display transmission torrent status |
| `sb-udiskie.sh` | 61 | udiskie, dmenu, lsblk, notify-send | Mount USB drives with udiskie |
| `sb-vifm.sh` | 18 | terminal, vifm/lf/yazi | Launch file managers from dwmblocks |
| `sb-vpn.sh` | 25 | NetworkManager | Show active VPN connections |
| `sb-wpa.sh` | 84 | wpa_cli | Show Wi-Fi connection status |

### Archived (`statusbar/archive/`)

Old `dwm_*` naming convention. Same purpose as active `sb-*` equivalents above.
11 scripts — see the active `sb-*` counterparts for current versions.

---

## system/

Network tools, security (LUKS, passwords, USB encryption), system management, sysadmin scripts.

| Script | Lines | Dependencies | Purpose |
|--------|-------|-------------|---------|
| `add-local-user.sh` | 55 | useradd, chpasswd, passwd | Create a new local user account |
| `backup.sh` | 19 | — | Backup a file with timestamp |
| `backup_file.sh` | 153 | — | Safely back up and process a file |
| `change_terminal.sh` | 49 | zenity, sed | Change the terminal in i3 config |
| `check_dependencies.sh` | 48 | tput | Check if specified programs are installed |
| `check_internet.sh` | 31 | curl | Check if an internet connection exists |
| `check_size.sh` | 18 | — | Check the size of a file |
| `close_crypto_vault.sh` | 57 | cryptsetup, losetup, umount, rm | Close and clean up an encrypted image |
| `connected_devices.sh` | 24 | ping | Find connected devices on the local network |
| `connectivity.sh` | 21 | nslookup, awk | Check network connectivity |
| `crypto_image_lnx.sh` | 596 | truncate, losetup, cryptsetup, mkfs.ext4, chattr | Create a LUKS encrypted image |
| `detect_connections.sh` | 19 | netstat, awk, grep, sort, uniq, cut | List established external connections |
| `devs_local_network.sh` | 28 | arp, sed, awk, ping | Find connected devices on local network |
| `folder_size.sh` | 47 | du, awk | Check if folder size exceeds a limit |
| `genpasswd.sh` | 123 | tr, tee | Generate random passwords |
| `genpasswd_sha.sh` | 74 | date, sha256sum, fold, shuf | Generate a random password |
| `harmful_http_post.sh` | 29 | tcpdump, sudo | Monitor HTTP POST requests for suspicious commands |
| `infoSystema.sh` | 21 | — | Display system information |
| `inmutable_usb.sh` | 26 | chattr, find, sudo | Apply immutable attribute to USB files |
| `install_dmenu_scripts.sh` | 29 | file, ln | Symlink dmenu scripts to ~/bin |
| `install_font.sh` | 17 | wget, unzip, fc-cache | Download and install Source Code Pro fonts |
| `lib_validation.sh` | 66 | — | Reusable Bash validation functions |
| `make_iso.sh` | 48 | mkisofs | Create a bootable ISO image |
| `man2pdf.sh` | 11 | man, ps2pdf | Convert man page to PDF |
| `OpenWebPages.sh` | 68 | firefox, google-chrome, safari | Open favorite links from a text file |
| `pingLocal.sh` | 24 | ping | Control local network online PCs |
| `raspiarch.sh` | 50 | parted, mkfs.vfat, mkfs.ext4, bsdtar, wget | Install Arch Linux ARM on Raspberry Pi SD card |
| `raspi_change_wm.sh` | 65 | sed | Change window manager on Raspberry Pi |
| `remote_transfer.sh` | 298 | sshpass, scp, nslookup | Send files/folders over SCP |
| `remove_caches.sh` | 8 | find | Remove Python cache directories |
| `search_web_requests.sh` | 13 | tcpdump, sudo | Monitor HTTP web traffic on port 80 |
| `setup_environment.sh` | 96 | python3, pip, sed, find | Set up Python virtual environments |
| `sudo_privileges.sh` | 40 | apt-get | Update system packages with sudo |
| `suspicious_network_activity.sh` | 29 | netstat, sudo | Check for suspicious established TCP connections |
| `usb_encrypt.sh` | 220 | lsblk, cryptsetup, notify-send, dunst | Encrypt, mount, and unmount a USB drive |
| `user_info.sh` | 28 | — | Find user information on the system |

---

## util/

Toys, git observer, random generators. Lightweight.

| Script | Lines | Dependencies | Purpose |
|--------|-------|-------------|---------|
| `book_search.sh` | 98 | dmenu, zathura, notify-send | Select and display books from a USB drive |
| `check_my_repos.sh` | 69 | git, notify-send | Track the status of local git repositories |
| `dummy_files.sh` | 25 | touch, date | Create dummy files and add information to them |
| `lottery.sh` | 24 | awk, date | Generate random numbers with awk |
| `multiplication_table.sh` | 30 | bash | Generate a multiplication table |
| `random_errors.sh` | 36 | date | Generate random error log entries |
| `random_ips.sh` | 20 | bash | Generate random IP numbers |
| `ternary_operator.sh` | 14 | bash | Demonstrate ternary operator usage |

---

## Platform notes

- **X11-only**: scripts that use xdotool, xclip, dmenu (without fuzzel fallback), setxkbmap, xbacklight, or redshift. These work when running dwm but not under Wayland/niri.
- **Wayland-only**: `fuzzel-ai-prompts.sh`.
- **Dual**: all other dmenu/fuzzel scripts auto-detect the active display server.
- **macOS** reference scripts removed. `txt2mp3.sh` (Linux) kept.

## Active vs. archival

The key distinction: scripts you actually reach for vs. scripts you wrote once and kept.

- **Active daily drivers**: `statusbar/sb-*`, `reference_cards/shell_*.sh`, `reference_cards/acronyms.sh`, `reference_cards/git_*.sh`, `desktop/urlmanager.sh`.
- **Solid when needed**: `system/crypto_image_lnx.sh`, `system/usb_encrypt.sh`, `system/remote_transfer.sh`, `system/genpasswd.sh`.
- **Learning/reference**: Everything in `learning/`, small educational snippets in `files/`.
- **Toys**: `util/lottery.sh`, `util/multiplication_table.sh`, `util/random_*.sh`.

---

## legacy/

Archived AI scripts from the Ollama era. Obfuscated for public repo — replace `{{PLACEHOLDERS}}` with your local AI backend commands.

| Script | Lines | Dependencies | Purpose |
|--------|-------|-------------|---------|
| `ollama_patterns.sh` | 149 | fzf, xsel/xclip, notify-send, nvim | Pattern-based AI with fzf, clipboard, YouTube transcript |
| `ollama_run.sh` | 6 | fzf | Simple fzf model selector + run |
| `ollama_translate.sh` | 239 | xclip, notify-send, fzf | CLI translator with clipboard/pipe/args input |
| `ollama_youtube_transcript.sh` | 272 | fzf, xclip/xsel, notify-send, nvim, youtube_transcript_api | YouTube transcript summarizer |
| `ollama_explain.sh` | ~305 | fzf/fuzzel, xsel/wl-copy | Interactive chat TUI with dmenu/fuzzel |
| `yad_ollama_translate.sh` | ~288 | yad, xclip, notify-send | GUI translator (YAD) |
| `yad_ollama_explain.sh` | ~255 | yad, xclip, notify-send | GUI explainer (YAD) |
| `yad_ollama_bash_coder.sh` | ~476 | yad, wl-clipboard/xclip, notify-send | GUI bash function generator (YAD) |
| `kill_ollama.sh` | ~72 | sudo | Kill AI backend process |
