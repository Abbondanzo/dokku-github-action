#!/bin/sh
set -e

echo "Setting up SSH directory"
SSH_PATH="$HOME/.ssh"
mkdir -p "$SSH_PATH"
chmod 700 "$SSH_PATH"

echo "Saving SSH key"
echo "$PRIVATE_KEY" > "$SSH_PATH/deploy_key"
chmod 600 "$SSH_PATH/deploy_key"

GIT_LOG="git --no-pager log --decorate=short --pretty=oneline -n1"
GIT_REMOTE="git remote add dokku dokku@$HOST:$PROJECT"
GIT_COMMAND="git push -u dokku HEAD:master"
if [ -n "$FORCE_DEPLOY" ]; then
    echo "Enabling force deploy"
    GIT_COMMAND="$GIT_COMMAND --force"
fi

GIT_SSH_COMMAND="ssh -p ${PORT-22} -i $SSH_PATH/deploy_key"
if [ -n "$HOST_KEY" ]; then
    echo "Adding hosts key to known_hosts"
    echo "$HOST_KEY" >> "$SSH_PATH/known_hosts"
    chmod 600 "$SSH_PATH/known_hosts"
else
    echo "Disabling host key checking"
    GIT_SSH_COMMAND="$GIT_SSH_COMMAND -o StrictHostKeyChecking=no"
fi

echo "The deploy is starting"

GIT_SSH_COMMAND="$GIT_SSH_COMMAND" $GIT_LOG $GIT_REMOTE $GIT_COMMAND
