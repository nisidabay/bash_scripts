#!/usr/bin/env bash
#
# Script to add header files to C files
set -uo pipefail

echo "Processing all C files in the directory structure..."

# Counters
declare -g has_header=0
declare -g header_added=0

# Process each C file found
while IFS= read -r file; do
    echo "Processing: $file"

    # Check if file is already processed (has our standard header comment line)
    if grep -qE '^\s*\* Name: .*\.c' "$file" 2> /dev/null; then
        echo "  Already processed, skipping..."
        ((has_header++))
        continue
    fi

    # Add basic template to the beginning of each file.
    # Temp file lives in the same directory so mv preserves permissions/ownership.
    temp_file=$(mktemp "$(dirname -- "$file")/.XXXXXX.c.tmp") || exit 1

    {
        cat << EOF
/*
 * Name: $(basename "$file")
 * Purpose: [Description of what this program does]
 * Author: [Author Name]
 * Description: This program [brief description of functionality].
 */

EOF
        cat -- "$file"
    } > "$temp_file" && chmod --reference="$file" "$temp_file" && mv -- "$temp_file" "$file"

    echo "  Updated: $file"
    ((header_added++))
done < <(find . -name "*.c" -type f | sort)

echo "Processing complete."
echo "  Files with headers: $has_header"
echo "  Headers added: $header_added"
