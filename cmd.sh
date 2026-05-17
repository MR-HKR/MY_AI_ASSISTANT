#!/bin/bash

# Project folder
PROJECT_DIR="/home/kingrain/Documents/scripts/python/MY_AI_ASSISTANT"

# Python interpreter in virtualenv
PYTHON="$PROJECT_DIR/.venv/bin/python"

# Script to run
SCRIPT="$PROJECT_DIR/main.py"

# Open a new terminal, cd into project folder, run the script, keep terminal open
gnome-terminal -- bash -c "cd \"$PROJECT_DIR\" && \"$PYTHON\" \"$SCRIPT\"; exec bash"