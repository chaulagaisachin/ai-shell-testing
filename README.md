# AI-Shell

**AI-Shell** is an interactive shell script that uses Google Gemini's API to interpret natural language commands and convert them into system commands. With this tool, you can automate system tasks by simply typing them in plain English. The script will analyze the task, generate the corresponding system command, and execute it. It also offers safety features, asking for user confirmation before executing commands that require `sudo`, and provides humorous output using `figlet` and `lolcat`.

## Features

- **Natural Language Processing**: Type system tasks in natural language, and AI-Shell will convert them into system commands.
- **Dependency Management**: Installs and checks for required dependencies (`jq`, `figlet`, `lolcat`).
- **Safety**: Asks for confirmation before executing any commands containing `sudo`.
- **Humor**: Displays fun output using `figlet` and `lolcat`.
- **Easy to Use**: Just run the script and start interacting with your system in plain language.

## Installation

To install **AI-Shell**, follow these steps:

1. **Clone the Repository**  
   Clone the repository to your local machine:

   ```
   git clone https://github.com/chaulagaisachin/ai-shell.git
   cd ai-shell
   ```
2. **Run the Installer**
The install.sh script will handle the installation of dependencies and setup:


```
chmod +x install.sh
sudo ./install.sh
```

3. **API Key Setup**
During installation, a .env file will be created in the installation folder (/usr/local/bin/ai-shell). Add your Google Gemini API key there by editing the file:

```
sudo nano /usr/local/bin/ai-shell/.env
```
Add the following line, replacing <your_api_key> with your actual API key:
```
API_KEY=<your_api_key>
```
Run AI-Shell
After installation, you can run AI-Shell from anywhere on your system by simply typing:

ai-shell
Start entering tasks in natural language, and AI-Shell will process them.

**Dependencies:**
jq: A lightweight and flexible command-line JSON processor.
figlet: A program for generating text banners.
lolcat: A humorous text generator to add funny output.
The install.sh script will automatically attempt to install these dependencies, but if it encounters an error, it will prompt you to install them manually.

**Usage**
After running ai-shell, you'll be prompted to enter your task in natural language. For example:

```
[>>] What is the status of Docker?
AI-Shell will interpret the task, generate the command, and ask for confirmation before executing it:
```

```
[+] Suggested command: docker ps
Do you want to execute this command? (yes/no):
```
Type yes to execute the command, or no to cancel.

**Example Commands**
Task: "Check the disk usage"
AI-Shell Suggests: df -h
Task: "List all running processes"
AI-Shell Suggests: ps aux

**Troubleshooting**
Missing Dependencies: If any dependencies like jq, figlet, or lolcat fail to install, you can install them manually based on your operating system.
Google Gemini API Key: Make sure to properly set the API key in the .env file. Without it, AI-Shell will not function correctly.

**License**
This project is licensed under the MIT License - see the LICENSE file for details.

Enjoy automating your system commands with AI-Shell! 🚀



### Key Sections of the `README.md`:
- **Description**: Overview of what the project is and its features.
- **Installation**: Step-by-step guide for users to get started with the tool.
- **Dependencies**: Information on what dependencies are required and how they are handled.
- **Usage**: A basic walkthrough of how to use the tool once it's installed.
- **Troubleshooting**: Instructions for what to do in case the tool doesn't work as expected.
-

