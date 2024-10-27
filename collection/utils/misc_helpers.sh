#!/bin/bash
# DESCRIPTION:
# This file, `utils.sh`, contains a collection of utility functions that are useful across various projects.
# The aim is to consolidate these functions in one place for easy access and sharing.
# The script is intended to be sourced in your `.zshrc` or `.bashrc` file.

# Color definitions
COLOR_RESET="\033[0m"
COLOR_INFO="\033[1;34m"
COLOR_SUCCESS="\033[1;32m"
COLOR_WARNING="\033[1;33m"
COLOR_ERROR="\033[1;31m"

# Function: log
#
# Logs messages with different levels and colors.
#
# Usage:
#   log <level> <message>
#
# Levels:
#   info, success, warning, error
#
# Example:
#   log info "This is an informational message."
#
function log() {
    local type=$1
    shift
    local message="$@"
    case $type in
        info)
            printf "%b[INFO]%b %s\n" "${COLOR_INFO}" "${COLOR_RESET}" "$message"
            ;;
        success)
            printf "%b[SUCCESS]%b %s\n" "${COLOR_SUCCESS}" "${COLOR_RESET}" "$message"
            ;;
        warning)
            printf "%b[WARNING]%b %s\n" "${COLOR_WARNING}" "${COLOR_RESET}" "$message"
            ;;
        error)
            printf "%b[ERROR]%b %s\n" "${COLOR_ERROR}" "${COLOR_RESET}" "$message" >&2
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# Function: display_help
#
# Displays the usage information for various utility functions.
#
# Parameters:
#   - func: The name of the utility function to display help for. If omitted, displays help for all functions.
#
# Usage:
#   display_help [func]
#
# Example:
#   display_help backup_file
#
function display_help() {
    local func=$1
    case "$func" in
        backup_file)
            cat << EOF
Usage: backup_file <file>
Creates a backup of the specified file with a timestamp.
EOF
            ;;
        download_file)
            cat << EOF
Usage: download_file <url> [destination]
Downloads a file from the specified URL to the destination path.
If no destination is provided, saves to the current directory with the original filename.
EOF
            ;;
        check_port)
            cat << EOF
Usage: check_port <port>
Checks if the specified port is in use.
EOF
            ;;
        compress_directory)
            cat << EOF
Usage: compress_directory <directory> [output_file]
Compresses the specified directory into a tar.gz file.
If output_file is not specified, uses <directory>.tar.gz.
EOF
            ;;
        create_symlink)
            cat << EOF
Usage: create_symlink <target> <link_name>
Creates a symbolic link from target to link_name.
EOF
            ;;
        monitor_disk_usage)
            cat << EOF
Usage: monitor_disk_usage [interval]
Monitors disk usage in real-time at specified intervals (default: 5 seconds).
EOF
            ;;
        generate_password)
            cat << EOF
Usage: generate_password [length]
Generates a random password of the specified length (default: 16).
EOF
            ;;
        top_memory_processes)
            cat << EOF
Usage: top_memory_processes [count]
Displays the top 'count' memory-consuming processes (default: 10).
EOF
            ;;
        check_website)
            cat << EOF
Usage: check_website <url>
Checks if the specified website is reachable.
EOF
            ;;
        current_datetime)
            cat << EOF
Usage: current_datetime
Displays the current date and time.
EOF
            ;;
        check_command)
            cat << EOF
Usage: check_command <command_name>
Checks if a command is installed and displays its version.
EOF
            ;;
        mkcd)
            cat << EOF
Usage: mkcd <directory_name>
Creates a directory and navigates to it.
EOF
            ;;
        ffind)
            cat << EOF
Usage: ffind <filename>
Finds files by name in the current directory.
EOF
            ;;
        cloc)
            cat << EOF
Usage: cloc
Counts the number of lines of code in the current directory.
EOF
            ;;
        extract)
            cat << EOF
Usage: extract <file_name>
Extracts compressed files of various formats.
EOF
            ;;
        dusage)
            cat << EOF
Usage: dusage [directory]
Displays disk usage in a readable format for the specified directory (default: current directory).
EOF
            ;;
        myip)
            cat << EOF
Usage: myip
Gets your public IP address.
EOF
            ;;
        gentree)
            cat << EOF
Usage: gentree <application_type>
Generates a directory tree and saves it in a Markdown file.
Supports ignoring specific directories based on application type: python, node, rails, or shell.
EOF
            ;;
        clean_temp)
            cat << EOF
Usage: clean_temp
Deletes all temporary files in the current directory.
EOF
            ;;
        mktar)
            cat << EOF
Usage: mktar <directory_name> [output_file]
Creates a compressed tar.gz file of the specified directory.
If output_file is not specified, uses <directory_name>.tar.gz.
EOF
            ;;
        cdd)
            cat << EOF
Usage: cdd <directory_name>
Navigates to a specific directory and lists its contents.
EOF
            ;;
        check_disk_space)
            cat << EOF
Usage: check_disk_space
Checks disk space usage.
EOF
            ;;
        system_info)
            cat << EOF
Usage: system_info
Displays detailed system information.
EOF
            ;;
        uptime_info)
            cat << EOF
Usage: uptime_info
Displays system uptime and load averages.
EOF
            ;;
        memory_usage)
            cat << EOF
Usage: memory_usage
Displays memory usage statistics.
EOF
            ;;
        *)
            cat << EOF
Available functions:
  backup_file          - Creates a backup of the specified file with a timestamp.
  download_file        - Downloads a file from the specified URL to the destination path.
  check_port           - Checks if the specified port is in use.
  compress_directory   - Compresses the specified directory into a tar.gz file.
  create_symlink       - Creates a symbolic link from target to link_name.
  monitor_disk_usage   - Monitors disk usage in real-time.
  generate_password    - Generates a random password of the specified length.
  top_memory_processes - Displays the top memory-consuming processes.
  check_website        - Checks if the specified website is reachable.
  current_datetime     - Displays the current date and time.
  check_command        - Checks if a command is installed and displays its version.
  mkcd                 - Creates a directory and navigates to it.
  ffind                - Finds files by name in the current directory.
  cloc                 - Counts the number of lines of code in the current directory.
  extract              - Extracts compressed files.
  dusage               - Displays disk usage in a readable format.
  myip                 - Gets your public IP address.
  gentree              - Generates a directory tree and saves it in a Markdown file.
  clean_temp           - Deletes all temporary files in the current directory.
  mktar                - Creates a compressed tar.gz file.
  cdd                  - Navigates to a specific directory and lists its contents.
  check_disk_space     - Checks disk space usage.
  system_info          - Displays detailed system information.
  uptime_info          - Displays system uptime and load averages.
  memory_usage         - Displays memory usage statistics.
Use 'display_help <function_name>' to see detailed usage of a specific function.
EOF
            ;;
    esac
}

# Function: backup_file
#
# Creates a backup of the specified file with a timestamp.
#
# Usage:
#   backup_file <file>
#
function backup_file() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help backup_file
        return 0
    fi

    if [[ -f "$1" ]]; then
        local backup_file="$1.bak.$(date +%F_%T)"
        cp "$1" "$backup_file" && log success "Backup of '$1' created as '$backup_file'"
    else
        log error "File '$1' does not exist"
        return 1
    fi
}

# Function: download_file
#
# Downloads a file from the specified URL to the destination path.
# If no destination is provided, saves to the current directory with the original filename.
#
# Usage:
#   download_file <url> [destination]
#
function download_file() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help download_file
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "No URL provided"
        return 1
    fi

    local url="$1"
    local destination="$2"

    if [[ -z "$destination" ]]; then
        destination="$(basename "$url")"
    fi

    if curl -L -o "$destination" "$url"; then
        log success "File downloaded from '$url' to '$destination'"
    else
        log error "Failed to download file from '$url'"
        return 1
    fi
}

# Function: check_port
#
# Checks if the specified port is in use.
#
# Usage:
#   check_port <port>
#
function check_port() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help check_port
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "No port number provided"
        return 1
    fi

    if lsof -iTCP:"$1" -sTCP:LISTEN >/dev/null 2>&1; then
        log warning "Port $1 is in use"
    else
        log success "Port $1 is available"
    fi
}

# Function: compress_directory
#
# Compresses the specified directory into a tar.gz file.
#
# Usage:
#   compress_directory <directory> [output_file]
#
function compress_directory() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help compress_directory
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "No directory name provided"
        return 1
    fi

    local dir="$1"
    local output_file="${2:-$dir.tar.gz}"

    if [[ ! -d "$dir" ]]; then
        log error "Directory '$dir' does not exist"
        return 1
    fi

    tar -czvf "$output_file" "$dir" && log success "Directory '$dir' compressed into '$output_file'"
}

# Function: create_symlink
#
# Creates a symbolic link from target to link_name.
#
# Usage:
#   create_symlink <target> <link_name>
#
function create_symlink() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help create_symlink
        return 0
    fi

    if [[ -z "$1" || -z "$2" ]]; then
        log error "Usage: create_symlink <target> <link_name>"
        return 1
    fi

    if ln -s "$1" "$2"; then
        log success "Symbolic link created from '$1' to '$2'"
    else
        log error "Failed to create symbolic link"
        return 1
    fi
}

# Function: monitor_disk_usage
#
# Monitors disk usage in real-time at specified intervals.
#
# Usage:
#   monitor_disk_usage [interval]
#
function monitor_disk_usage() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help monitor_disk_usage
        return 0
    fi

    local interval="${1:-5}"

    if ! [[ "$interval" =~ ^[0-9]+$ ]]; then
        log error "Interval must be a positive integer"
        return 1
    fi

    watch -n "$interval" df -h
}

# Function: generate_password
#
# Generates a random password of the specified length (default: 16).
#
# Usage:
#   generate_password [length]
#
function generate_password() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help generate_password
        return 0
    fi

    local length="${1:-16}"

    if ! [[ "$length" =~ ^[0-9]+$ ]]; then
        log error "Length must be a positive integer"
        return 1
    fi

    local password
    password=$(LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*()_+-=' </dev/urandom | head -c "$length")
    echo "$password"
    log success "Random password of length $length generated"
}

# Function: top_memory_processes
#
# Displays the top 'count' memory-consuming processes.
#
# Usage:
#   top_memory_processes [count]
#
function top_memory_processes() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help top_memory_processes
        return 0
    fi

    local count="${1:-10}"

    if ! [[ "$count" =~ ^[0-9]+$ ]]; then
        log error "Count must be a positive integer"
        return 1
    fi

    ps aux --sort=-%mem | awk 'NR<=1{print $0}; NR>1{print $0}' | head -n "$((count + 1))"
    log success "Displayed top $count memory-consuming processes"
}

# Function: check_website
#
# Checks if the specified website is reachable.
#
# Usage:
#   check_website <url>
#
function check_website() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help check_website
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "No URL provided"
        return 1
    fi

    if curl -Is "$1" | head -n 1 | grep -q "200\|301\|302"; then
        log success "Website '$1' is reachable"
    else
        log error "Website '$1' is not reachable"
        return 1
    fi
}

# Function: current_datetime
#
# Displays the current date and time.
#
# Usage:
#   current_datetime
#
function current_datetime() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help current_datetime
        return 0
    fi

    date '+%Y-%m-%d %H:%M:%S'
}

# Function: check_command
#
# Checks if a command is installed and displays its version.
#
# Usage:
#   check_command <command_name>
#
function check_command() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help check_command
        return 0
    fi

    local cmd="$1"

    if command -v "$cmd" >/dev/null 2>&1; then
        log success "$cmd is installed"
        if "$cmd" --version >/dev/null 2>&1; then
            "$cmd" --version | head -n 1
        elif "$cmd" -v >/dev/null 2>&1; then
            "$cmd" -v | head -n 1
        else
            log warning "Version information not available for $cmd"
        fi
    else
        log error "$cmd is not installed"
        return 1
    fi
}

# Function: mkcd
#
# Creates a directory and navigates to it.
#
# Usage:
#   mkcd <directory_name>
#
function mkcd() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help mkcd
        return 0
    fi

    if [[ -z "$1" ]]; then
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
# Usage:
#   ffind <filename>
#
function ffind() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help ffind
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "No filename provided"
        return 1
    fi

    find . -type f -name "*$1*"
}

# Function: cloc
#
# Counts the number of lines of code in the current directory.
#
# Usage:
#   cloc
#
function cloc() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help cloc
        return 0
    fi

    if ! command -v cloc >/dev/null 2>&1; then
        log warning "cloc is not installed. Installing..."
        if sudo apt-get install -y cloc; then
            log success "cloc installed"
        else
            log error "Failed to install cloc"
            return 1
        fi
    fi

    cloc .
}

# Function: extract
#
# Extracts compressed files of various formats.
#
# Usage:
#   extract <file_name>
#
function extract() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help extract
        return 0
    fi

    if [[ ! -f "$1" ]]; then
        log error "'$1' is not a valid file!"
        return 1
    fi

    case "$1" in
        *.tar.bz2|*.tbz2) tar xjf "$1" ;;
        *.tar.gz|*.tgz)   tar xzf "$1" ;;
        *.tar.xz)         tar xJf "$1" ;;
        *.tar)            tar xf "$1" ;;
        *.bz2)            bunzip2 "$1" ;;
        *.rar)            unrar x "$1" ;;
        *.gz)             gunzip "$1" ;;
        *.zip)            unzip "$1" ;;
        *.Z)              uncompress "$1" ;;
        *.7z)             7z x "$1" ;;
        *)                log error "Don't know how to extract '$1'..." ;;
    esac
}

# Function: dusage
#
# Displays disk usage in a readable format.
#
# Usage:
#   dusage [directory]
#
function dusage() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help dusage
        return 0
    fi

    du -h --max-depth=1 "${1:-.}" 2>/dev/null | sort -h
}

# Function: myip
#
# Gets your public IP address.
#
# Usage:
#   myip
#
function myip() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help myip
        return 0
    fi

    local ip
    ip=$(curl -s https://api.ipify.org)
    if [[ -n "$ip" ]]; then
        echo "$ip"
        log success "Public IP address retrieved"
    else
        log error "Failed to retrieve IP address"
        return 1
    fi
}

# Function: gentree
#
# Generates a directory tree and saves it in a Markdown file.
#
# Usage:
#   gentree <application_type>
#
function gentree() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help gentree
        return 0
    fi

    if ! command -v tree >/dev/null 2>&1; then
        log warning "tree is not installed. Installing..."
        if sudo apt-get install -y tree; then
            log success "tree installed"
        else
            log error "Failed to install tree"
            return 1
        fi
    fi

    local apptype="$1"
    local ignores

    function set_ignores() {
        case "$apptype" in
            python) ignores=".git|__pycache__|.vscode|.idea|.venv" ;;
            node)   ignores=".git|node_modules" ;;
            rails)  ignores=".git|log|tmp" ;;
            shell)  ignores=".git" ;;
            *)      log error "Invalid application type"; return 1 ;;
        esac
    }

    if [[ -z "$apptype" ]]; then
        log error "No application type supplied"
        return 1
    fi

    set_ignores
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    if tree -I "$ignores" -L 4 -a -d --noreport > project_tree.md; then
        sed -i 's/^/    /' project_tree.md
        sed -i '1s/^    /# Project Tree\n\n    /' project_tree.md
        log success "Directory tree has been saved to project_tree.md"
    else
        log error "Error generating directory tree"
        return 1
    fi
}

# Function: clean_temp
#
# Deletes all temporary files in the current directory.
#
# Usage:
#   clean_temp
#
function clean_temp() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help clean_temp
        return 0
    fi

    find . -type f -name '*~' -delete && log success "Temporary files deleted"
}

# Function: mktar
#
# Creates a compressed tar.gz file of the specified directory.
#
# Usage:
#   mktar <directory_name> [output_file]
#
function mktar() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help mktar
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "No directory name provided"
        return 1
    fi

    local dir="$1"
    local output_file="${2:-$dir.tar.gz}"

    if [[ ! -d "$dir" ]]; then
        log error "Directory '$dir' does not exist"
        return 1
    fi

    tar czf "$output_file" "$dir" && log success "Tar file '$output_file' created"
}

# Function: cdd
#
# Navigates to a specific directory and lists its contents.
#
# Usage:
#   cdd <directory_name>
#
function cdd() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help cdd
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "No directory name provided"
        return 1
    fi

    if cd "$1"; then
        ls
        log success "Navigated to '$1'"
    else
        log error "Failed to navigate to '$1'"
        return 1
    fi
}

# Function: check_disk_space
#
# Checks disk space usage.
#
# Usage:
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
# Displays detailed system information.
#
# Usage:
#   system_info
#
function system_info() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help system_info
        return 0
    fi

    echo "System Information:"
    echo "-------------------"
    lsb_release -a 2>/dev/null
    uname -a
    log success "System information displayed"
}

# Function: uptime_info
#
# Displays system uptime and load averages.
#
# Usage:
#   uptime_info
#
function uptime_info() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help uptime_info
        return 0
    fi

    uptime
}

# Function: memory_usage
#
# Displays memory usage statistics.
#
# Usage:
#   memory_usage
#
function memory_usage() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help memory_usage
        return 0
    fi

    free -h
}

# Function: open_in_browser
#
# Opens a URL in the default web browser.
#
# Usage:
#   open_in_browser <url>
#
function open_in_browser() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        cat << EOF
Usage: open_in_browser <url>
Opens the specified URL in the default web browser.
EOF
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "No URL provided"
        return 1
    fi

    if xdg-open "$1" >/dev/null 2>&1; then
        log success "Opened '$1' in web browser"
    else
        log error "Failed to open '$1' in web browser"
        return 1
    fi
}

# Function: weather
#
# Displays current weather information for a specified location.
#
# Usage:
#   weather <location>
#
function weather() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        cat << EOF
Usage: weather <location>
Displays current weather information for the specified location.
EOF
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "No location provided"
        return 1
    fi

    curl -s "wttr.in/$1"
}

# Function: random_quote
#
# Displays a random inspirational quote.
#
# Usage:
#   random_quote
#
function random_quote() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        cat << EOF
Usage: random_quote
Displays a random inspirational quote.
EOF
        return 0
    fi

    curl -s https://api.quotable.io/random | jq -r '.content + " — " + .author' 2>/dev/null || log error "Failed to retrieve quote"
}
