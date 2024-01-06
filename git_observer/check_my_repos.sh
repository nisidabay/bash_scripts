#!/bin/bash
#
# Verify the status of local repositories

# Path to the file containing the list of repositories
SCRIPT_PATH="$HOME/bin/git_observer"
REPOS_FILE="$SCRIPT_PATH/repos.txt"
LOG_FILE="$HOME/git_status_log.txt"
echo  -n "" > "$LOG_FILE"
untracked_changes=0
#
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

# Function to check repository for changes
check_repo() {
    local repo_path=$1
    cd "$repo_path" || return

    local repo_untracked_changes
    repo_untracked_changes=$(git status --porcelain 2>/dev/null | wc -l)
    if [ "$repo_untracked_changes" -gt 0 ]; then
        echo "Checking $repo_path" >> "$LOG_FILE"
        echo "Untracked changes: $repo_untracked_changes" >> "$LOG_FILE"
        ((untracked_changes+=repo_untracked_changes))
    fi
}

# Read each line from the file as a repository path
header_separator
while IFS= read -r repo; do
    check_repo "$repo"
done < "$REPOS_FILE"
header_separator "end"

if [ "$untracked_changes" -gt 0 ];then
    # Using libnotify to send notification
    notify-send -i "$SCRIPT_PATH/git.png" "Changes detected" "$untracked_changes"
    notify-send -i "$SCRIPT_PATH/git.png" "Check log file" "$LOG_FILE"
fi
