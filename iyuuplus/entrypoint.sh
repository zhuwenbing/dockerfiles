#!/bin/sh

# Define default values for environment variables
REPO_DIR="/app/iyuuplus"
DEFAULT_GIT_REPO="https://github.com/ledccn/iyuuplus-dev.git"
BRANCH="master"

# Reference to https://get.casaos.io/update
# Use https://ipconfig.io/country and https://ifconfig.io/country_code to get the country code
REGION=$(curl --connect-timeout 2 -s https://ipconfig.io/country || echo "")
if [ "${REGION}" = "" ]; then
  REGION=$(curl --connect-timeout 2 -s https://ifconfig.io/country_code || echo "")
fi
if [[ "${REGION}" = "China" ]] || [[ "${REGION}" = "CN" ]]; then
  GIT_REPO="https://gitee.com/ledc/iyuuplus-dev.git"
else
  GIT_REPO=$DEFAULT_GIT_REPO
fi

# Ensure the target directory exists
mkdir -p $REPO_DIR

# Configure git to allow this directory
git config --global --add safe.directory $REPO_DIR

# Function to handle errors and exit
handle_error() {
  echo "An error occurred. Exiting."
  exit 1
}

# Check if the repository is cloned
if [ ! -d "$REPO_DIR/.git" ]; then
  echo "Cloning repository..."
  git clone --branch $BRANCH $GIT_REPO $REPO_DIR || handle_error
else
  echo "Repository exists. Pulling latest changes..."
  cd $REPO_DIR
  git pull origin $BRANCH || handle_error
fi

# Execute the PHP script
exec php $REPO_DIR/start.php start
