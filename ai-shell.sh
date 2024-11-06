#!/bin/bash

# Define colors
NC='\033[0m'        # No Color
BLUE='\033[34m'     # Blue
RED='\033[31m'      # Red
YELLOW='\033[33m'   # Yellow

# Function to display help message
display_help() {
    echo -e "${BLUE}AI-Shell - Natural Language to System Commands${NC}"
    echo -e "${BLUE}--------------------------------------------${NC}"
    echo -e "This script allows you to interact with your system using natural language commands."
    echo -e "It will attempt to convert your input into an executable system command and execute it."
    echo -e "If a command is not recognized, it will query Google Gemini to generate the appropriate command."
    echo -e ""
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  $0 [options]"
    echo -e ""
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  -h, --help         Show this help message and exit"
    echo -e "  -r, --recur        Run in interactive mode (multiple commands)"
    echo -e "  <command>          Enter your system task in natural language (e.g., 'list files')"
    echo -e ""
    echo -e "${YELLOW}Note:${NC}"
    echo -e "  - The script requires an API_KEY for Google Gemini, which should be set in the .env file."
    echo -e "  - You will be asked to confirm the execution of suggested commands, especially those involving 'sudo'."
    exit 0
}

# If --help or -h is passed, display the help message and exit
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    display_help
fi

# Check if --recur or -r is passed to enter interactive mode
INTERACTIVE_MODE=false
if [[ "$1" == "--recur" ]] || [[ "$1" == "-r" ]]; then
    INTERACTIVE_MODE=true
    shift  # Remove the flag to process any remaining arguments
fi

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
    query="Please provide me only the system command (do not start with 'bash') to perform the following task on a system with the following OS: $os_version, Shell version: $shell_version. Task: $query"
    response=$(curl -s -X POST "$GEMINI_API_ENDPOINT" -H "Content-Type: application/json" -d "{\"contents\":[{\"parts\":[{\"text\":\"$query\"}]}]}")
    command=$(echo "$response" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null)
    echo "$command"
}

# Function to clean the command
clean_command() {
    local command="$1"
    command=$(echo "$command" | tr -d '\n' | sed 's/^[ \t]*//;s/[ \t]*$//')
    command=$(echo "$command" | sed 's/`//g')
    echo "$command"
}

# Function to execute a system command
execute_command() {
    local command="$1"
    command=$(clean_command "$command")
    
    if [[ "$command" == *"sudo"* ]]; then
        echo -e "${RED}[**] Warning: The command includes 'sudo'. This tool is for educational purposes only.${NC}"
        read -p "Do you want to execute this command with 'sudo'? (yes/no): " confirm
        if [[ "$confirm" == "yes" ]]; then
            eval "$command"
        else
            echo -e "${YELLOW}[!] Command execution canceled.${NC}"
        fi
    else
        eval "$command"
    fi
}

# Run in Single Command Mode if no arguments passed (unless --recur flag is used)
if [ $# -ge 1 ] && ! $INTERACTIVE_MODE; then
    user_input="$*"
    echo -e "${BLUE}[+] Running a single command: $user_input${NC}"
    command=$(query_gemini "$user_input")
    command=$(clean_command "$command")
    
    if [[ -n "$command" && "$command" != "null" ]]; then
        echo -e "${BLUE}[+] Suggested command: $command${NC}"

        if [[ "$command" == *"sudo"* ]]; then
            echo -e "${RED}[**] Warning: The suggested command includes 'sudo'. This tool is for educational purposes only.${NC}"
        fi

        read -p "Do you want to execute this command? (yes/no): " confirm
        if [[ "$confirm" == "yes" ]]; then
            execute_command "$command"
        else
            echo -e "${YELLOW}[!] Command execution canceled.${NC}"
        fi
    else
        echo -e "${RED}[!] Could not interpret the task. Please try a different wording.${NC}"
    fi
    exit 0  # Exit after a single command execution
fi

# Main loop for Interactive Mode
if $INTERACTIVE_MODE; then
    echo -e "${BLUE}[+] Enter your command or task in natural language (or type 'exit' to quit):${NC}"
    
    while true; do
        read -p $'\e[34m[>>]\e[0m ' -r user_input

        if [[ "$user_input" == "exit" ]]; then
            echo -e "${BLUE}[+] Exiting program.${NC}"
            break
        fi

        if [[ -z "$user_input" ]]; then
            continue
        fi

        base_command=$(echo "$user_input" | awk '{print $1}')

        if command -v "$base_command" &> /dev/null; then
            execute_command "$user_input"
        else
            echo -e "${BLUE}[+] Interpreting natural language input through Google Gemini...${NC}"
            command=$(query_gemini "$user_input")
            if [[ -n "$command" && "$command" != "null" ]]; then
                command=$(clean_command "$command")
                echo -e "${BLUE}[+] Suggested command: $command${NC}"
                
                if [[ "$command" == *"sudo"* ]]; then
                    echo -e "${RED}[**] Warning: The suggested command includes 'sudo'. This tool is for educational purposes only.${NC}"
                fi

                read -p "Do you want to execute this command? (yes/no): " confirm
                if [[ "$confirm" == "yes" ]]; then
                    execute_command "$command"
                else
                    echo -e "${YELLOW}[!] Command execution canceled.${NC}"
                fi
            else
                echo -e "${RED}[!] Could not interpret the task. Please try a different wording.${NC}"
            fi
        fi
    done
fi
