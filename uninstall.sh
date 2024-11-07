#!/bin/bash

# --- Uninstallation Script for AI-Shell ---

# Define colors
NORMAL="\033[0;34m"   # Blue
WARNING="\033[0;33m"  # Yellow
ERROR="\033[0;31m"    # Red
RESET="\033[0m"       # Reset to default color

# Define the installation directory
INSTALL_DIR="/usr/local/bin/ai-shell-install"
AI_SHELL_PATH="$INSTALL_DIR/ai-shell.sh"

# Check if the script is running with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${ERROR}[!] This script requires root (sudo) privileges. Please run as root.${RESET}"
    exit 1
fi

# Check if AI-Shell is installed
if [ -f "$AI_SHELL_PATH" ]; then
    # Remove the AI-Shell installation
    echo -e "${NORMAL}[+] Removing AI-Shell from $INSTALL_DIR${RESET}"

    # Remove ai-shell script and associated files
    sudo rm -rf "$INSTALL_DIR"

    echo -e "${NORMAL}[+] Uninstallation complete.${RESET}"
else
    echo -e "${ERROR}[!] AI-Shell is not installed or already uninstalled.${RESET}"
    exit 1
fi
