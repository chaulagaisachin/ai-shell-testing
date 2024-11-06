#!/bin/bash

# --- Installation Script for AI-Shell ---

# Define the installation directory
INSTALL_DIR="/usr/local/bin"
AI_SHELL_PATH="$INSTALL_DIR/ai-shell.sh"

# Check if the script is running with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo -e "[!] This script requires root (sudo) privileges. Please run as root."
    exit 1
fi

# Install dependencies: figlet, lolcat, and jq
echo -e "[+] Installing dependencies: figlet, lolcat, jq"

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
    echo -e "[!] Unsupported OS. Please install figlet, lolcat, and jq manually."
    exit 1
fi

# Clone or download ai-shell.sh into the installation directory
echo -e "[+] Downloading ai-shell.sh"
sudo git clone https://your-repository-url.git "$INSTALL_DIR/ai-shell"

# Copy ai-shell.sh to the specified location
echo -e "[+] Installing ai-shell.sh in $INSTALL_DIR"
sudo cp "$INSTALL_DIR/ai-shell/ai-shell.sh" "$AI_SHELL_PATH"

# Create an .env file to store the API_KEY
echo -e "[+] Creating .env file for storing the API_KEY"
cat <<EOF | sudo tee "$INSTALL_DIR/.env" > /dev/null
# .env file for storing the Google Gemini API_KEY for AI-Shell
API_KEY=""
EOF

# Set permissions to secure the .env file
echo -e "[+] Securing the .env file"
sudo chmod 600 "$INSTALL_DIR/.env"

# Ensure ai-shell.sh is executable
echo -e "[+] Making ai-shell.sh executable"
sudo chmod +x "$AI_SHELL_PATH"

# Check if installation was successful
if [ -f "$AI_SHELL_PATH" ] && [ -f "$INSTALL_DIR/.env" ]; then
    echo -e "[+] Installation complete. AI-Shell is now located at $AI_SHELL_PATH"
    echo -e "[+] Please edit the .env file at $INSTALL_DIR/.env and add your Google Gemini API key."
else
    echo -e "[!] Installation failed."
    exit 1
fi
