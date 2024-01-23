#!/bin/bash

# Extract file paths
file_paths=$(grep "Checking " git_status_log.txt | sed 's/^Checking //')
# Extract untracked changes
untracked_changes=$(grep "Untracked changes" git_status_log.txt |  awk -F': ' '{print $2}')

# Combine and sort results
paste  <(echo -n "$untracked_changes") <(echo -n "$file_paths") | sort -nr -k1 


# This is the log to considered
# Logging started at dom 07 ene 2024 22:03:05 CET
# -----------------------------------------------
# Checking /home/nisidabay/proyectos_git/chat_cht
# Untracked changes: 6
# Checking /home/nisidabay/proyectos_git/config_files
# Untracked changes: 51
# Checking /home/nisidabay/proyectos_git/crops
# Untracked changes: 5
# Checking /home/nisidabay/proyectos_git/encrypt_file_univ
# Untracked changes: 7
# Checking /home/nisidabay/proyectos_git/observer
# Untracked changes: 4
# Checking /home/nisidabay/proyectos_git/organizer
# Untracked changes: 9
# Checking /home/nisidabay/proyectos_git/py_sync
# Untracked changes: 3
# Checking /home/nisidabay/proyectos_git/pyadventure/pyadventure
# Untracked changes: 11
# Checking /home/nisidabay/proyectos_git/python_scripts
# Untracked changes: 101
# Checking /home/nisidabay/proyectos_git/sql_class
# Untracked changes: 6
# Checking /home/nisidabay/proyectos_git/sync_hosts
# Untracked changes: 2
# Checking /home/nisidabay/proyectos_git/text_2_mp3
# Untracked changes: 2
# Checking /home/nisidabay/proyectos_git/todo_univ
# Untracked changes: 6
# Logging ended at dom 07 ene 2024 22:03:06 CET
# ---------------------------------------------
