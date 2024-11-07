#!/bin/bash

# --- Installation Script for AI-Shell ---

# Define colors
NORMAL="\033[0;34m"   # Blue
WARNING="\033[0;33m"  # Yellow
ERROR="\033[0;31m"    # Red
RESET="\033[0m"       # Reset to default color

# Define the installation directory
INSTALL_DIR="/usr/local/bin/ai-shell-install"
AI_SHELL_PATH="$INSTALL_DIR/ai-shell.sh"
SYMLINK_PATH="/usr/local/bin/ai-shell"

# Check if the script is running with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${ERROR}[!] This script requires root (sudo) privileges. Please run as root.${RESET}"
    exit 1
fi

# Install dependencies: figlet, lolcat, and jq
echo -e "${NORMAL}[+] Installing dependencies: figlet, lolcat, jq${RESET}"

# Update package index and install the required packages based on the OS
if [ -f /etc/debian_version ]; then
    sudo apt update
    sudo apt install figlet lolcat jq -y
elif [ -f /etc/redhat-release ]; then
    sudo yum install figlet lolcat jq -y
elif command -v brew &> /dev/null; then
    # For macOS (using Homebrew)
    brew install figlet lolcat jq
else
    echo -e "${WARNING}[!] Unsupported OS. Please install figlet, lolcat, and jq manually.${RESET}"
    exit 1
fi

# Clone the repository into the installation directory
echo -e "${NORMAL}[+] Downloading ai-shell.sh${RESET}"
sudo git clone https://github.com/chaulagaisachin/ai-shell "$INSTALL_DIR"

# Copy ai-shell.sh to the specified location
echo -e "${NORMAL}[+] Installing ai-shell.sh in $INSTALL_DIR${RESET}"
sudo cp "$INSTALL_DIR/ai-shell/ai-shell.sh" "$AI_SHELL_PATH"

# Create an .env file to store the API_KEY
echo -e "${NORMAL}[+] Creating .env file for storing the API_KEY in $INSTALL_DIR${RESET}"
cat <<EOF | sudo tee "$INSTALL_DIR/.env" > /dev/null
# .env file for storing the Google Gemini API_KEY for AI-Shell
API_KEY=""
EOF

# Ensure ai-shell.sh is executable
echo -e "${NORMAL}[+] Making ai-shell.sh executable${RESET}"
sudo chmod +x "$AI_SHELL_PATH"

# Create a symbolic link to ai-shell.sh for easier access
echo -e "${NORMAL}[+] Creating symbolic link to ai-shell.sh at $SYMLINK_PATH${RESET}"
sudo ln -sf "$AI_SHELL_PATH" "$SYMLINK_PATH"

# Check if installation was successful
if [ -f "$AI_SHELL_PATH" ] && [ -f "$INSTALL_DIR/.env" ]; then
    echo -e "${NORMAL}[+] Installation complete. AI-Shell is now located at $AI_SHELL_PATH${RESET}"
    echo -e "${NORMAL}[+] You can run AI-Shell by simply typing 'ai-shell' in your terminal.${RESET}"
    echo -e "${NORMAL}[+] Please edit the .env file at $INSTALL_DIR/.env and add your Google Gemini API key.${RESET}"
    echo -e "${WARNING}[!] For security, after adding your API key, you may want to restrict access to the .env file by running: sudo chmod 600 $INSTALL_DIR/.env${RESET}"
else
    echo -e "${ERROR}[!] Installation failed.${RESET}"
    exit 1
fi
