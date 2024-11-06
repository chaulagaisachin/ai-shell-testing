#!/bin/bash

# --- Uninstallation Script for AI-Shell ---

# Define colors
NORMAL="\033[0;34m"   # Blue
WARNING="\033[0;33m"  # Yellow
ERROR="\033[0;31m"    # Red
RESET="\033[0m"       # Reset to default color

# Define the installation directory
INSTALL_DIR="/usr/local/bin/ai-shell"
AI_SHELL_PATH="$INSTALL_DIR/ai-shell.sh"

# Check if the script is running with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${ERROR}[!] This script requires root (sudo) privileges. Please run as root.${RESET}"
    exit 1
fi

# Remove AI-Shell script
if [ -f "$AI_SHELL_PATH" ]; then
    echo -e "${NORMAL}[+] Removing ai-shell.sh from $INSTALL_DIR${RESET}"
    sudo rm -f "$AI_SHELL_PATH"
else
    echo -e "${WARNING}[!] ai-shell.sh not found. It may have already been removed.${RESET}"
fi

# Remove the installation directory
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${NORMAL}[+] Removing the installation directory: $INSTALL_DIR${RESET}"
    sudo rm -rf "$INSTALL_DIR"
else
    echo -e "${WARNING}[!] Installation directory not found. It may have already been removed.${RESET}"
fi

# Remove the .env file
if [ -f "$INSTALL_DIR/.env" ]; then
    echo -e "${NORMAL}[+] Removing .env file from $INSTALL_DIR${RESET}"
    sudo rm -f "$INSTALL_DIR/.env"
else
    echo -e "${WARNING}[!] .env file not found. It may have already been removed.${RESET}"
fi

# Check if uninstallation was successful
if [ ! -f "$AI_SHELL_PATH" ] && [ ! -f "$INSTALL_DIR/.env" ] && [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${NORMAL}[+] Uninstallation complete. AI-Shell has been removed.${RESET}"
else
    echo -e "${ERROR}[!] Uninstallation failed. Some files may not have been removed properly.${RESET}"
    exit 1
fi
