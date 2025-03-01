#!/usr/bin/env bash

# setup_environments.sh
# This script sets up the new environments for the project, installs the
# requirements, and makes the script executable

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
for cmd in python3 pip sed; do
	if ! command_exists "$cmd"; then
		echo -e "${RED}Error: $cmd is not installed.${NC}" >&2
		exit 1
	fi
done

# Function to setup a specific component
create_venv() {
	local component=$1
	local requirements=$2

	echo -e "${YELLOW}Setting up $component...${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE")

	# Create new venv
	python3 -m venv "$component"

	# Upgrade pip first to avoid the notice
	echo -e "${YELLOW}Upgrading pip...${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE")
	"$component/bin/python3" -m pip install --upgrade pip

	# Install requirements
	echo -e "${YELLOW}Installing requirements...${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE")
	if ! "$component/bin/pip" install -r "$PROJECT_ROOT/requirements/$requirements"; then
		echo -e "${RED}Error installing requirements for $component, but continuing...${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE")
	fi

	# Env shebang
	local env_shebang
	env_shebang="$PROJECT_ROOT/$component/bin/python3"

	# Update shebang in python files
	echo -e "${YELLOW}Updating shebangs...${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE")
	if [[ "$OSTYPE" == "darwin"* ]]; then
		# macOS version (BSD sed)
		find "$component" -name "*.py" -type f -exec sed -i '' "1s|#!.*|#!$env_shebang|" {} \;
	else
		# Linux version (GNU sed)
		find "$component" -name "*.py" -type f -exec sed -i "1s|#!.*|#!$env_shebang|" {} \;
	fi

	echo -e "${GREEN}Shebang modified to: $env_shebang${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE")
}

# Main execution
echo -e "${YELLOW}Starting setup process${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE")

# Setup component
create_venv "env" "requirements.txt" || {
	echo -e "${RED}Error in setup_component, but continuing...${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE")
}

# Make all Python files executable
echo -e "${YELLOW}Making Python files executable...${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE")
find . -name "*.py" -type f -exec chmod +x {} \;

echo -e "${GREEN}Setup process complete!${NC}" | tee -a >(sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE")
exit 0
