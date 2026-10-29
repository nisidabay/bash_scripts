#!/usr/bin/env bash
#
# Open favorite links from a text file.
#
# Dependencies: firefox, google-chrome, safari

# Ansi color code variables for colored output
red="\e[0;91m"
green="\e[0;92m"
blue="\e[0;94m"
reset="\e[0m"

# Function to detect the default browser
detect_browser() {
    if command -v firefox >/dev/null 2>&1; then
        echo "firefox"
    elif command -v google-chrome >/dev/null 2>&1; then
        echo "google-chrome"
    elif command -v safari >/dev/null 2>&1; then
        echo "safari"
    else
        echo ""
    fi
}

# Main script starts here
BROWSER=$(detect_browser)

# Exit if no suitable browser is found
if [ -z "$BROWSER" ]; then
    echo -e "${red}[-] No suitable browser found. Please install Firefox, Google Chrome, or Safari.${reset}"
    exit 1
fi

# Check for the URLs file
url_file=$1
if [ -z "$url_file" ]; then
    echo -e "${red}Usage: $0 [path_to_urls_file]${reset}"
    exit 1
fi

# Check if the URL file exists
if [ ! -f "$url_file" ]; then
    echo -e "${red}[-] The file '$url_file' does not exist.${reset}"
    exit 1
fi

echo -e "${blue}[+] Opening web pages from $url_file ...${reset}"
max_parallel=5 # Limit the number of parallel browser instances
count=0

# Read and open URLs
while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines and comments
    [[ "$line" =~ ^\#.*$ ]] || [[ -z "$line" ]] && continue

    $BROWSER "$line" & # Open URL in the background
    ((count++))

    # Wait if the maximum number of parallel instances is reached
    if ((count >= max_parallel)); then
        wait -n
        ((count--))
    fi
done <"$url_file"

wait # Wait for all background processes to finish
echo -e "${green}[+] Completed opening all web pages.${reset}"
