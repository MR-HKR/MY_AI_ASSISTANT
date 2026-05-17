#!/bin/bash

PROJECT_DIR="$1"
SCRIPT="$2"

gnome-terminal --geometry=30x10+800+100 -- bash -c "
cd '$PROJECT_DIR'
source '$PROJECT_DIR/.venv/bin/activate' 2>/dev/null || true

PYTHONPATH='$PROJECT_DIR' python3 '$SCRIPT'
echo 'Terminal will close in 10 seconds...'
sleep 10
"