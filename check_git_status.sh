#!/bin/bash
# 
# Verify the status of a git directory

# Creates a header for the log
header_separator(){
# Get the current date
_date=$(date)
header="Logging started at $_date"

# Check if an argument is provided
if [[ $# -gt 0 && $1  == "end" ]]; then
    # If provided argument: use "Logging ended"
    header="Logging ended at $_date" 
fi

# Get the length of the header
separator_length=${#header}

# Create a separator of the same length as the header
separator=$(printf '%*s' "$separator_length" | tr ' ' '-')

# Print the header and separator to the log file
printf "%s\n%s\n" "$header" "$separator" >> "$LOG_FILE" 
}

# Check the git status of every file in $OME
check_git_status() {
local repo_path="$HOME/$1"
if [ ! -d "$repo_path" ]; then
    echo -e "$(date) - $repo_path is not a directory\n" >> "$LOG_FILE"
    return
fi

cd "$repo_path" || return

local untracked_count=$(git status --porcelain 2>/dev/null | wc -l)
local staged_count=$(git diff --cached --name-only 2>/dev/null | wc -l)

if [ "$untracked_count" -gt 0 ] || [ "$staged_count" -gt 0 ]; then
    echo -e "Checking $repo_path" >> "$LOG_FILE"
    [ "$untracked_count" -gt 0 ] && echo -ne "\tUntracked Changes: $untracked_count" >> "$LOG_FILE"
    [ "$staged_count" -gt 0 ] && echo -ne "\tStaged Changes: $staged_count" >> "$LOG_FILE"
    echo  >> "$LOG_FILE"
fi

}

# Initialize log file
LOG_FILE="$HOME/git_status_log.txt"
echo  -n "" > "$LOG_FILE"

header_separator 
cd "$HOME" || exit

find . -type d -name .git | while read -r git_dir; do
    repo_dir=$(dirname "$git_dir")
    strip_dot_repo="${repo_dir#./}"
    check_git_status "$strip_dot_repo" 
done

header_separator "end"
echo
echo "Log generated in: $LOG_FILE"
