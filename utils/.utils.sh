#!/bin/bash

# DESCRIPTION: This file, `utils.sh`, contains a collection of utility functions that I have found useful across various projects.
# I created this repository to consolidate these functions in one place and share them with others who might find them helpful.
# I plan to continue adding new functions as I discover or develop them.

# Color logging functions
function log() {
    local type=$1
    shift
    case $type in
        info)
            echo -e "\033[1;34m[INFO]\033[0m $@"
            ;;
        success)
            echo -e "\033[1;32m[SUCCESS]\033[0m $@"
            ;;
        warning)
            echo -e "\033[1;33m[WARNING]\033[0m $@"
            ;;
        error)
            echo -e "\033[1;31m[ERROR]\033[0m $@"
            ;;
        *)
            echo "$@"
            ;;
    esac
}

# Function: display_help
#
# Displays the usage information for various utility functions.
#
# Parameters:
#   - func: The name of the utility function to display help for.
#
# Usage:
#   display_help <func>
#
# Example:
#   display_help backup_file
#
#   This will display the usage information for the 'backup_file' utility function.
#
function display_help() {
    local func=$1
    shift
    case "$func" in
        backup_file)
            echo "Usage: backup_file <file>"
            echo "Creates a backup of the specified file with a timestamp."
            ;;
        download_file)
            echo "Usage: download_file <url> <destination>"
            echo "Downloads a file from the specified URL to the destination path."
            ;;
        check_port)
            echo "Usage: check_port <port>"
            echo "Checks if the specified port is in use."
            ;;
        compress_directory)
            echo "Usage: compress_directory <directory>"
            echo "Compresses the specified directory into a tar.gz file."
            ;;
        create_symlink)
            echo "Usage: create_symlink <target> <link_name>"
            echo "Creates a symbolic link from target to link_name."
            ;;
        monitor_disk_usage)
            echo "Usage: monitor_disk_usage"
            echo "Monitors disk usage in real-time."
            ;;
        generate_password)
            echo "Usage: generate_password [length]"
            echo "Generates a random password of the specified length (default: 16)."
            ;;
        top_memory_processes)
            echo "Usage: top_memory_processes"
            echo "Displays the top 10 memory-consuming processes."
            ;;
        check_website)
            echo "Usage: check_website <url>"
            echo "Checks if the specified website is reachable."
            ;;
        current_datetime)
            echo "Usage: current_datetime"
            echo "Displays the current date and time."
            ;;
        check_command)
            echo "Usage: check_command <command_name>"
            echo "Checks if a command is installed and displays its version."
            ;;
        mkcd)
            echo "Usage: mkcd <directory_name>"
            echo "Creates a directory and navigates to it."
            ;;
        ffind)
            echo "Usage: ffind <filename>"
            echo "Finds files by name in the current directory."
            ;;
        cloc)
            echo "Usage: cloc"
            echo "Counts the number of lines of code in the current directory."
            ;;
        extract)
            echo "Usage: extract <file_name>"
            echo "Extracts compressed files."
            ;;
        dusage)
            echo "Usage: dusage [directory]"
            echo "Displays disk usage in a readable format."
            ;;
        myip)
            echo "Usage: myip"
            echo "Gets your public IP address."
            ;;
        gentree)
            echo "Usage: gentree <application_type>"
            echo "Generates a directory tree and saves it in a Markdown file."
            ;;
        clean_temp)
            echo "Usage: clean_temp"
            echo "Deletes all temporary files in the current directory."
            ;;
        mktar)
            echo "Usage: mktar <directory_name>"
            echo "Creates a compressed tar file."
            ;;
        cdd)
            echo "Usage: cdd <directory_name>"
            echo "Navigates to a specific directory and lists its contents."
            ;;
        check_disk_space)
            echo "Usage: check_disk_space"
            echo "Checks disk space usage."
            ;;
        system_info)
            echo "Usage: system_info"
            echo "Displays system information."
            ;;
        *)
            echo "No help available for $func"
            ;;
    esac
}

# Function: backup_file
#
# Creates a backup of the specified file with a timestamp.
#
# Parameters:
#   - $1: The file to back up.
#
# Usage:
#   backup_file <file>
#
# Example:
#   backup_file myfile.txt
#
function backup_file() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help backup_file
        return 0
    fi

    if [ -f "$1" ]; then
        cp "$1" "$1.bak.$(date +%F_%T)"
        log success "Backup of '$1' created as '$1.bak.$(date +%F_%T)'"
    else
        log error "File '$1' does not exist"
    fi
}

# Function: download_file
#
# Downloads a file from the specified URL to the destination path.
#
# Parameters:
#   - $1: The URL of the file to download.
#   - $2: The destination path where the file should be saved.
#
# Usage:
#   download_file <url> <destination>
#
# Example:
#   download_file https://example.com/file.zip /path/to/save/file.zip
#
function download_file() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help download_file
        return 0
    fi

    if [ -z "$1" ] || [ -z "$2" ]; then
        log error "Usage: download_file <url> <destination>"
        return 1
    fi
    curl -o "$2" "$1" && log success "File downloaded from '$1' to '$2'" || log error "Failed to download file from '$1'"
}

# Function: check_port
#
# Checks if the specified port is in use.
#
# Parameters:
#   - $1: The port number to check.
#
# Usage:
#   check_port <port>
#
# Example:
#   check_port 8080
#
function check_port() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help check_port
        return 0
    fi

    if [ -z "$1" ]; then
        log error "Usage: check_port <port>"
        return 1
    fi
    if lsof -i:"$1" &> /dev/null; then
        log warning "Port $1 is in use"
    else
        log success "Port $1 is available"
    fi
}

# Function: compress_directory
#
# Compresses the specified directory into a tar.gz file.
#
# Parameters:
#   - $1: The directory to compress.
#
# Usage:
#   compress_directory <directory>
#
# Example:
#   compress_directory my_directory
#
function compress_directory() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help compress_directory
        return 0
    fi

    if [ -z "$1" ]; then
        log error "No directory name provided"
        return 1
    fi
    tar -czvf "$1.tar.gz" "$1"
    log success "Directory '$1' compressed into '$1.tar.gz'"
}

# Function: create_symlink
#
# Creates a symbolic link from target to link_name.
#
# Parameters:
#   - $1: The target file or directory.
#   - $2: The symbolic link name.
#
# Usage:
#   create_symlink <target> <link_name>
#
# Example:
#   create_symlink /path/to/target /path/to/symlink
#
function create_symlink() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help create_symlink
        return 0
    fi

    if [ -z "$1" ] || [ -z "$2" ]; then
        log error "Usage: create_symlink <target> <link_name>"
        return 1
    fi
    ln -s "$1" "$2" && log success "Symbolic link created from '$1' to '$2'" || log error "Failed to create symbolic link"
}

# Function: monitor_disk_usage
#
# Monitors disk usage in real-time.
#
# Usage:
#   monitor_disk_usage
#
# Example:
#   monitor_disk_usage
#
function monitor_disk_usage() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help monitor_disk_usage
        return 0
    fi

    watch -n 5 df -h
}

# Function: generate_password
#
# Generates a random password of the specified length (default: 16).
#
# Parameters:
#   - $1: (Optional) The length of the password to generate.
#
# Usage:
#   generate_password [length]
#
# Example:
#   generate_password 20
#
function generate_password() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help generate_password
        return 0
    fi

    local length=${1:-16}
    tr -dc A-Za-z0-9 </dev/urandom | head -c $length && echo
    log success "Random password of length $length generated"
}

# Function: top_memory_processes
#
# Displays the top 10 memory-consuming processes.
#
# Usage:
#   top_memory_processes
#
# Example:
#   top_memory_processes
#
function top_memory_processes() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help top_memory_processes
        return 0
    fi

    ps aux --sort=-%mem | awk 'NR<=10{print $0}'
    log success "Displayed top 10 memory-consuming processes"
}

# Function: check_website
#
# Checks if the specified website is reachable.
#
# Parameters:
#   - $1: The URL of the website to check.
#
# Usage:
#   check_website <url>
#
# Example:
#   check_website https://example.com
#
function check_website() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help check_website
        return 0
    fi

    if [ -z "$1" ]; then
        log error "Usage: check_website <url>"
        return 1
    fi
    if curl -s --head "$1" | grep "200 OK" > /dev/null; then
        log success "Website '$1' is reachable"
    else
        log error "Website '$1' is not reachable"
    fi
}

# Function: current_datetime
#
# Displays the current date and time.
#
# Usage:
#   current_datetime
#
# Example:
#   current_datetime
#
function current_datetime() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help current_datetime
        return 0
    fi

    date '+%Y-%m-%d %H:%M:%S'
    log success "Current date and time displayed"
}

# Function: check_command
#
# Checks if a command is installed and displays its version.
#
# Parameters:
#   - $1: The name of the command to check.
#
# Usage:
#   check_command <command_name>
#
# Example:
#   check_command git
#
function check_command() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help check_command
        return 0
    fi

    local cmd=$1
    if command -v "$cmd" &> /dev/null; then
        log success "$cmd is installed"
        "$cmd" --version
    else
        log error "$cmd is not installed"
    fi
}

# Function: mkcd
#
# Creates a directory and navigates to it.
#
# Parameters:
#   - $1: The name of the directory to create and navigate to.
#
# Usage:
#   mkcd <directory_name>
#
# Example:
#   mkcd new_directory
#
function mkcd() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help mkcd
        return 0
    fi

    if [ -z "$1" ]; then
        log error "No directory name provided"
        return 1
    fi
    mkdir -p "$1" && cd "$1" || return 1
    log success "Directory '$1' created and navigated to"
}

# Function: ffind
#
# Finds files by name in the current directory.
#
# Parameters:
#   - $1: The name of the file to find.
#
# Usage:
#   ffind <filename>
#
# Example:
#   ffind myfile.txt
#
function ffind() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help ffind
        return 0
    fi

    if [ -z "$1" ]; then
        log error "No filename provided"
        return 1
    fi
    find . -name "$1"
}

# Function: cloc
#
# Counts the number of lines of code in the current directory.
#
# Usage:
#   cloc
#
# Example:
#   cloc
#
function cloc() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help cloc
        return 0
    fi

    if ! command -v cloc &> /dev/null; then
        log warning "cloc could not be found, installing..."
        sudo apt-get install -y cloc
    fi
    cloc .
}

# Function: extract
#
# Extracts compressed files.
# Supports various archive formats such as .tar.bz2, .tar.gz, .bz2, .rar, .gz, .tar, .tbz2, .tgz, .zip, .Z, and .7z.
#
# Parameters:
#   - $1: The name of the file to extract.
#
# Usage:
#   extract <file_name>
#
# Example:
#   extract archive.tar.gz
#
function extract() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help extract
        return 0
    fi

    if [ ! -f "$1" ]; then
        log error "'$1' is not a valid file!"
        return 1
    fi

    case "$1" in
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.gz)  tar xzf "$1" ;;
        *.bz2)     bunzip2 "$1" ;;
        *.rar)     unrar e "$1" ;;
        *.gz)      gunzip "$1" ;;
        *.tar)     tar xf "$1" ;;
        *.tbz2)    tar xjf "$1" ;;
        *.tgz)     tar xzf "$1" ;;
        *.zip)     unzip "$1" ;;
        *.Z)       uncompress "$1" ;;
        *.7z)      7z x "$1" ;;
        *)         log error "Don't know how to extract '$1'..." ;;
    esac
}

# Function: dusage
#
# Displays disk usage in a readable format.
#
# Parameters:
#   - $1: (Optional) The directory to check disk usage for. Defaults to the current directory if not provided.
#
# Usage:
#   dusage [directory]
#
# Example:
#   dusage /path/to/directory
#
function dusage() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help dusage
        return 0
    fi

    du -sh "${1:-.}"/* 2>/dev/null | sort -h
}

# Function: myip
#
# Gets your public IP address.
#
# Usage:
#   myip
#
# Example:
#   myip
#
function myip() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help myip
        return 0
    fi

    curl -s https://api.ipify.org || log error "Failed to retrieve IP address"
}

# Function: gentree
#
# Generates a directory tree and saves it in a Markdown file.
# Supports ignoring specific directories based on application type: python, node, rails, or shell.
#
# Parameters:
#   - $1: The type of application (e.g., python, node, rails, shell).
#
# Usage:
#   gentree <application_type>
#
# Example:
#   gentree python
#
function gentree() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help gentree
        return 0
    fi

    if ! command -v tree &> /dev/null; then
        log warning "tree could not be found, installing..."
        sudo apt-get install -y tree
    fi

    local apptype=$1
    local ignores
    local patterns="*.yml,*.yaml,*.md"

    function ignores_per_app() {
        local apptype=$1
        case $apptype in
            python)
                ignores=".git,__pycache__,.vscode,.idea,.venv"
                patterns="$patterns,*.py"
                ;;
            node)
                ignores=".git,node_modules"
                patterns="$patterns,*.js,*.json"
                ;;
            rails)
                ignores=".git,log,tmp"
                patterns="$patterns,*.rb"
                ;;
            shell)
                ignores=".git"
                patterns="$patterns,*.sh"
                ;;
            *)
                log error "Invalid application type"
                return 1
                ;;
        esac
    }

    if [ -z "$apptype" ]; then
        log error "No application type supplied"
        return 1
    fi

    ignores_per_app "$apptype"
    tree -I "$ignores" -P "$patterns" -L 4 -a --noreport | sed 's/^/    /' | sed '1s/^    /# Project Tree\n\n    /' > project_tree.md
    log success "Directory tree has been saved to project_tree.md"
}

# Function: clean_temp
#
# Deletes all temporary files in the current directory.
#
# Usage:
#   clean_temp
#
# Example:
#   clean_temp
#
function clean_temp() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help clean_temp
        return 0
    fi

    find . -name '*~' -delete
    log success "Temporary files deleted"
}

# Function: mktar
#
# Creates a compressed tar file.
#
# Parameters:
#   - $1: The name of the directory to compress.
#
# Usage:
#   mktar <directory_name>
#
# Example:
#   mktar my_directory
#
function mktar() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help mktar
        return 0
    fi

    if [ -z "$1" ]; then
        log error "No directory name provided"
        return 1
    fi
    tar czf "$1".tar.gz "$1"
    log success "Tar file '$1.tar.gz' created"
}

# Function: cdd
#
# Navigates to a specific directory and lists its contents.
#
# Parameters:
#   - $1: The directory to navigate to.
#
# Usage:
#   cdd <directory_name>
#
# Example:
#   cdd /path/to/directory
#
function cdd() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help cdd
        return 0
    fi

    if [ -z "$1" ]; then
        log error "No directory name provided"
        return 1
    fi
    cd "$1" && ls || log error "Failed to navigate to '$1'"
}

# Function: check_disk_space
#
# Checks disk space usage.
#
# Usage:
#   check_disk_space
#
# Example:
#   check_disk_space
#
function check_disk_space() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help check_disk_space
        return 0
    fi

    df -h
}

# Function: system_info
#
# Displays system information.
#
# Usage:
#   system_info
#
# Example:
#   system_info
#
function system_info() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help system_info
        return 0
    fi

    uname -a
    log success "System information displayed"
}
