#!/bin/bash

# Start Emacs daemon if not already running
emacsclient -e "(emacs-pid)" &>/dev/null || emacs --daemon

# Wait until daemon is ready (check every second)
while ! emacsclient -e "(emacs-pid)" &>/dev/null; do
    sleep 0.5
done

# Start GUI client on workspace 2
hyprctl dispatch workspace 2
emacsclient -c
