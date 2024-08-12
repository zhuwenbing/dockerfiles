#!/bin/bash

REPO_DIR="/app/iyuuplus"
GIT_REPO="https://github.com/ledccn/iyuuplus-dev.git"
BRANCH="master"

# Ensure the target directory exists
mkdir -p $REPO_DIR

# fatal: detected dubious ownership in repository at '/app/iyuuplus'
# To add an exception for this directory, call:
git config --global --add safe.directory $REPO_DIR

# Check if the repository is cloned
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "Cloning repository..."
    git clone --branch $BRANCH $GIT_REPO $REPO_DIR
else
    echo "Repository exists. Pulling latest changes..."
    cd $REPO_DIR
    git pull origin $BRANCH
fi

exec "$@"
