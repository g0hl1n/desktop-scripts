#!/usr/bin/env bash
#
# Tmux session creation/choosing helper
#
# Author: g0hl1n

set -e

# array defining the directories to be searched for the selector
SEARCH_DIRS=(
    "$HOME/"
    "$HOME/VCS"
)

# Get the selected session either as argument or from directories within
# the SEARCH_DIRS array
if [[ $# -eq 1 ]]; then
    selected=$1
else
    # shellcheck disable=SC2068
    selected=$(find ${SEARCH_DIRS[@]} -mindepth 1 -maxdepth 1 -type d -not -path '*/.*' | fzf)
fi

# ensure a directory is selected
if [[ ! -d "$selected" ]]; then
    exit 0
fi

session_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# Not in a tmux session and no tmux running
if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s "$session_name" -c "$selected"
    exit 0
fi

# create the requested session if it doesn't exist
if ! tmux has-session -t="$session_name" 2> /dev/null; then
    tmux new-session -ds "$session_name" -c "$selected"
fi

# Either attach or switch to the selected session
if [[ -z $TMUX ]] ; then
    tmux attach-session -t "$session_name"
else
    tmux switch-client -t "$session_name"
fi

