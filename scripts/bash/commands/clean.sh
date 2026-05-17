#!/bin/bash

PING_TARGET="8.8.8.8"
ONLINE=false

echo "Checking internet connection..."
if ping -c 1 -W 2 $PING_TARGET >/dev/null 2>&1; then
    ONLINE=true
    echo "Internet: online"
else
    echo "Internet: offline"
fi

if [ "$ONLINE" = true ]; then
    echo "Updating system..."
    sudo -S apt update && sudo apt upgrade -y

    echo "Removing unused packages..."
    sudo apt autoremove -y
    sudo apt autoclean -y

    echo "Clearing APT cache (old packages only)..."
    sudo apt clean
else
    echo "Skipping network-related commands."
fi

# User cache cleanup (only files, keep folder structure)
echo "Cleaning user cache..."
find ~/.cache -type f -exec rm -f {} \;

# Flatpak cleanup (if installed)
if command -v flatpak >/dev/null 2>&1; then
    echo "Cleaning unused Flatpak runtimes..."
    flatpak uninstall --unused -y
else
    echo "Flatpak not installed. Skipping."
fi

# System logs cleanup
echo "Cleaning old logs (keep 7 days)..."
sudo journalctl --vacuum-time=7d
clear
echo "Cleanup finished."