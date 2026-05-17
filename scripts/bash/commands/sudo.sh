#!/bin/bash

echo "$1" | sudo -S -p '' true >/dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "access granted"
else
    echo "access denied"
fi