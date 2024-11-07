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
    echo -e "  $0 [options] <command>"
    echo -e ""
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  -h, --help         Show this help message and exit"
    echo -e "  -r, --recur        Run in interactive mode (multiple commands)"
    echo -e "<command>            Enter your system task in natural language (e.g., 'list files')"
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

# If no arguments are passed, display usage instructions
if [ $# -eq 0 ]; then
    echo -e "${BLUE}AI-Shell: Please provide a task in natural language or use the ${YELLOW}--help${NC} option for more information.${NC}"
    exit 0
fi

# Check if --recur or -r is passed to enter interactive mode
INTERACTIVE_MODE=false
if [[ "$1" == "--recur" ]] || [[ "$1" == "-r" ]]; then
    INTERACTIVE_MODE=true
    shift  # Remove the flag to process any remaining arguments
fi

# Ensure that .env is sourced from the correct location
if [ -f /usr/local/bin/ai-shell-install/.env ]; then
    source /usr/local/bin/ai-shell-install/.env
else
    echo -e "${RED}[!] .env file not found in /usr/local/bin/ai-shell-install!${NC}"
    exit 1
fi

# Check if API_KEY is set
if [ -z "$API_KEY" ]; then
    echo -e "${RED}[!] API_KEY is not set. Please provide it in the .env file.${NC}"
    exit 1
fi

# Enable command history
HISTFILE=~/.ai_shell_history   # Define the history file
HISTSIZE=1000                  # Set the maximum number of commands to remember
HISTCONTROL=ignoredups         # Ignore duplicate commands

export HISTFILE
export HISTSIZE
export HISTCONTROL

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
        read -e -p $'\e[34m[>>]\e[0m ' -r user_input  # Use -e for readline support

        if [[ "$user_input" == "exit" ]]; then
            echo -e "${BLUE}[+] Exiting program.${NC}"
            break
        fi

        if [[ -z "$user_input" ]]; then
            continue
        fi

        base_command=$(echo "$user_input" | awk '{print $1}')

        if command -v "$base_command" &> /dev/null; then
            echo -e "${BLUE}[+] Executing system command directly: $base_command${NC}"
            execute_command "$user_input"
        else
            echo -e "${BLUE}[+] Querying Gemini for the command...${NC}"
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
        fi
    done
fi
