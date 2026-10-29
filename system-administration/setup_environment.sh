#!/usr/bin/env bash
#
# Set up Python virtual environments.
#
# Dependencies: python3, pip, sed, find

set -euo pipefail # Exit on error, treat unset variables as an error, and fail on pipe errors

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

trap 'echo -e "${RED}Error on line $LINENO${NC}"' ERR

PROJECT_ROOT=$(pwd)
LOG_FILE="$PROJECT_ROOT/setup.log"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure required commands are available
for cmd in python3 pip sed find; do
    if ! command_exists "$cmd"; then
        echo -e "${RED}Error: $cmd is not installed.${NC}" >&2
        exit 1
    fi
done

# Function to setup a specific component
create_venv() {
    local component=$1
    local requirements=$2

    # Redirect log messages to stderr to prevent capture in command substitution
    echo -e "${YELLOW}Setting up $component...${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >>"$LOG_FILE") >&2

    # Create new venv
    (python3 -m venv "$component") || {
        echo "Failed to create venv" >&2
        exit 1
    }

    # Upgrade pip first to avoid the notice
    echo -e "${YELLOW}Upgrading pip...${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >>"$LOG_FILE") >&2
    "$component/bin/python3" -m pip install --upgrade pip >/dev/null

    # Install requirements
    echo -e "${YELLOW}Installing requirements...${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >>"$LOG_FILE") >&2
    if ! "$component/bin/pip" install -r "$PROJECT_ROOT/requirements/$requirements" >/dev/null; then
        echo -e "${RED}Error installing requirements for $component, but continuing...${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >>"$LOG_FILE") >&2
    fi

    # Return the shebang path (only this goes to stdout)
    echo "$PROJECT_ROOT/$component/bin/python3"
}

# Main execution
echo -e "${YELLOW}Starting setup process${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >>"$LOG_FILE") >&2

# Setup component and capture shebang path (only stdout is captured)
echo -e "${YELLOW}Creating virtual environment and installing dependencies...${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >>"$LOG_FILE") >&2
env_shebang=$(create_venv "env" "requirements.txt") || {
    echo -e "${RED}Error in setup_component, but continuing...${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >>"$LOG_FILE") >&2
}

# Update shebang in project Python files (excluding env/)
echo -e "${YELLOW}Updating shebangs in project files...${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >>"$LOG_FILE") >&2
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS version (BSD sed)
    find "$PROJECT_ROOT" -path "$PROJECT_ROOT/env" -prune -o -name "*.py" -type f -exec sed -i '' "1s|^#!.*|#!$env_shebang|" {} +
else
    # Linux version (GNU sed)
    find "$PROJECT_ROOT" -path "$PROJECT_ROOT/env" -prune -o -name "*.py" -type f -exec sed -i "1s|^#!.*|#!$env_shebang|" {} +
fi

# Verify shebang update
echo -e "${YELLOW}Verifying shebang updates...${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >>"$LOG_FILE") >&2
if find "$PROJECT_ROOT" -path "$PROJECT_ROOT/env" -prune -o -name "*.py" -type f -exec grep -q "^#!$env_shebang" {} +; then
    echo -e "${GREEN}Shebang modified to: $env_shebang${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >>"$LOG_FILE") >&2
else
    echo -e "${RED}Failed to update shebang in some files. Please check manually.${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >>"$LOG_FILE") >&2
fi

# Make all Python files executable
echo -e "${YELLOW}Making Python files executable...${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >>"$LOG_FILE") >&2
find "$PROJECT_ROOT" -path "$PROJECT_ROOT/env" -prune -o -name "*.py" -type f -exec chmod +x {} +

echo -e "${YELLOW}Activating the virtual environment...${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >>"$LOG_FILE") >&2
source "$PROJECT_ROOT/env/bin/activate"

echo -e "${GREEN}Setup process complete!${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >>"$LOG_FILE") >&2
exit 0
