#!/bin/bash

# Define colors
NC='\033[0m'        # No Color
BLUE='\033[34m'     # Blue
RED='\033[31m'      # Red
YELLOW='\033[33m'   # Yellow

# Load environment variables from .env file
if [ -f .env ]; then
    source .env
else
    echo -e "${RED}[!] .env file not found!${NC}"
    exit 1
fi

# Check if API_KEY is set
if [ -z "$API_KEY" ]; then
    echo -e "${RED}[!] API_KEY is not set. Please provide it in the .env file.${NC}"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}[+] jq is not installed. Installing...${NC}"
    sudo apt update && sudo apt install jq -y || {
        echo -e "${RED}[**] Failed to install jq. Please install it manually.${NC}"
        exit 1
    }
fi

# Check if figlet and lolcat are installed
if ! command -v figlet &> /dev/null; then
    echo -e "${YELLOW}[+] figlet is not installed. Would you like to install it? (yes/no)${NC}"
    read -r install_figlet
    if [[ "$install_figlet" == "yes" ]]; then
        sudo apt install figlet -y || {
            echo -e "${RED}[**] Failed to install figlet. Please install it manually.${NC}"
            exit 1
        }
    else
        echo -e "${RED}[**] figlet is required to display the banner. Exiting...${NC}"
        exit 1
    fi
fi

if ! command -v lolcat &> /dev/null; then
    echo -e "${YELLOW}[+] lolcat is not installed. Would you like to install it? (yes/no)${NC}"
    read -r install_lolcat
    if [[ "$install_lolcat" == "yes" ]]; then
        sudo apt install lolcat -y || {
            echo -e "${RED}[**] Failed to install lolcat. Please install it manually.${NC}"
            exit 1
        }
    else
        echo -e "${RED}[**] lolcat is required for the funny message. Exiting...${NC}"
        exit 1
    fi
fi

# Print banner using figlet and lolcat
echo -e "${BLUE}$(figlet 'AI-Shell')${NC}"
echo -e "${RED}$(lolcat <<< 'Automating your system commands, one joke at a time!')${NC}"

# Define Google Gemini API endpoint
GEMINI_API_ENDPOINT="https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$API_KEY"

# Get OS version and shell version
os_version=$(uname -a)
shell_version=$(bash --version | head -n 1)

# Function to query Gemini API
query_gemini() {
    local query="$1"
    # Adjust the query to ask for only the command to perform the task, ensuring it's precise and doesn't start with bash
    query="Please provide me only the system command (do not start with 'bash') to perform the following task on a system with the following OS: $os_version, Shell version: $shell_version. Task: $query"
    response=$(curl -s -X POST "$GEMINI_API_ENDPOINT" -H "Content-Type: application/json" -d "{\"contents\":[{\"parts\":[{\"text\":\"$query\"}]}]}")
    command=$(echo "$response" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null)
    echo "$command"
}

# Function to clean the command (remove unexpected characters and backticks)
clean_command() {
    local command="$1"
    # Remove backticks and any other unwanted characters like newlines or extra spaces
    command=$(echo "$command" | tr -d '\n' | sed 's/^[ \t]*//;s/[ \t]*$//')  # Trim spaces and newlines
    command=$(echo "$command" | sed 's/`//g')  # Remove backticks
    echo "$command"
}

# Function to execute a system command
execute_command() {
    local command="$1"
    # Clean the command before execution
    command=$(clean_command "$command")
    
    # Check if command contains 'sudo'
    if [[ "$command" == *"sudo"* ]]; then
        echo -e "${RED}[**] Warning: The command includes 'sudo'. This tool is for educational purposes only.${NC}"
        read -p "Do you want to execute this command with 'sudo'? (yes/no): " confirm
        if [[ "$confirm" == "yes" ]]; then
            eval "$command"  # Execute with sudo
        else
            echo -e "${YELLOW}[!] Command execution canceled.${NC}"  # Changed to yellow with [!]
        fi
    else
        eval "$command"  # Execute without sudo
    fi
}

# Print initial prompt once
echo -e "${BLUE}[+] Enter your command or task in natural language (or type 'exit' to quit):${NC}"

# Main loop
while true; do
    read -p $'\e[34m[>>]\e[0m ' -r user_input

    # Exit the loop if the user types 'exit'
    if [[ "$user_input" == "exit" ]]; then
        echo -e "${BLUE}[+] Exiting program.${NC}"
        break
    fi

    # If the user input is empty, continue to the next prompt
    if [[ -z "$user_input" ]]; then
        continue
    fi

    # Extract the base command (the first word) from user input
    base_command=$(echo "$user_input" | awk '{print $1}')

    # Check if the base command exists in the system
    if command -v "$base_command" &> /dev/null; then
        execute_command "$user_input"  # Execute the full input including options
    else
        # Query Gemini to generate the command for the task
        echo -e "${BLUE}[+] Interpreting natural language input through Google Gemini...${NC}"
        command=$(query_gemini "$user_input")

        # Clean the command before displaying it to the user
        command=$(clean_command "$command")

        if [[ -n "$command" && "$command" != "null" ]]; then
            echo -e "${BLUE}[+] Suggested command: $command${NC}"  # Display cleaned command without backticks

            # Only warn once if the command contains 'sudo'
            if [[ "$command" == *"sudo"* ]]; then
                echo -e "${RED}[**] Warning: The suggested command includes 'sudo'. This tool is for educational purposes only.${NC}"
            fi

            # Ask user for confirmation to execute the command
            read -p "Do you want to execute this command? (yes/no): " confirm
            if [[ "$confirm" == "yes" ]]; then
                execute_command "$command"
            else
                echo -e "${YELLOW}[!] Command execution canceled.${NC}"  # Changed to yellow with [!]
            fi
        else
            echo -e "${RED}[!] Could not interpret the task. Please try a different wording.${NC}"
        fi
    fi
done
