#!/bin/bash

# --- Uninstallation Script for AI-Shell ---

# Define colors
NORMAL="\033[0;34m"   # Blue
WARNING="\033[0;33m"  # Yellow
ERROR="\033[0;31m"    # Red
RESET="\033[0m"       # Reset to default color

# Define the installation directory and symbolic link path
INSTALL_DIR="/usr/local/bin/ai-shell-install"
AI_SHELL_PATH="$INSTALL_DIR/ai-shell.sh"
SYMLINK_PATH="/usr/local/bin/ai-shell"

# Check if the script is running with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${ERROR}[!] This script requires root (sudo) privileges. Please run as root.${RESET}"
    exit 1
fi

# Remove the symbolic link
echo -e "${NORMAL}[+] Removing symbolic link at $SYMLINK_PATH${RESET}"
if [ -L "$SYMLINK_PATH" ]; then
    sudo rm "$SYMLINK_PATH"
    echo -e "${NORMAL}[+] Symbolic link removed.${RESET}"
else
    echo -e "${WARNING}[!] Symbolic link not found. Skipping removal.${RESET}"
fi

# Remove the AI-Shell script
echo -e "${NORMAL}[+] Removing ai-shell.sh from $INSTALL_DIR${RESET}"
if [ -f "$AI_SHELL_PATH" ]; then
    sudo rm "$AI_SHELL_PATH"
    echo -e "${NORMAL}[+] ai-shell.sh removed.${RESET}"
else
    echo -e "${WARNING}[!] ai-shell.sh not found. Skipping removal.${RESET}"
fi

# Remove the .env file
echo -e "${NORMAL}[+] Removing .env file from $INSTALL_DIR${RESET}"
if [ -f "$INSTALL_DIR/.env" ]; then
    sudo rm "$INSTALL_DIR/.env"
    echo -e "${NORMAL}[+] .env file removed.${RESET}"
else
    echo -e "${WARNING}[!] .env file not found. Skipping removal.${RESET}"
fi

# Optionally, clean up the installation directory
echo -e "${NORMAL}[+] Cleaning up the installation directory ${INSTALL_DIR}${RESET}"
if [ -d "$INSTALL_DIR" ]; then
    sudo rm -rf "$INSTALL_DIR"
    echo -e "${NORMAL}[+] Installation directory removed.${RESET}"
else
    echo -e "${WARNING}[!] Installation directory not found. Skipping cleanup.${RESET}"
fi

# Check if uninstallation was successful
if [ ! -f "$AI_SHELL_PATH" ] && [ ! -L "$SYMLINK_PATH" ] && [ ! -f "$INSTALL_DIR/.env" ]; then
    echo -e "${NORMAL}[+] Uninstallation complete.${RESET}"
else
    echo -e "${ERROR}[!] Uninstallation failed.${RESET}"
    exit 1
fi
