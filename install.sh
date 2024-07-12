#!/bin/bash

# Color logging functions
log() {
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

# Function: show_menu
#
# Displays a menu with the provided options.
#
# Parameters:
#   - $@ : List of menu options
#
# Usage:
#   show_menu "Option 1" "Option 2" "Option 3"
#
show_menu() {
    echo "Select an option:"
    local i=1
    for option in "$@"; do
        echo "$i) $option"
        ((i++))
    done
}

# Function: install_script
#
# Installs the specified script.
#
# Parameters:
#   - $1 : Path to the script to be installed
#
# Usage:
#   install_script "/path/to/script.sh"
#
install_script() {
    local script_path=$1
    local target_dir="$HOME/handy_scripts"
    mkdir -p "$target_dir"

    if [ -f "$script_path" ]; then
        log info "Installing $script_path..."
        cp "$script_path" "$target_dir/"
        chmod +x "$target_dir/$(basename "$script_path")"
        log success "$script_path installed successfully in $target_dir."
    else
        log error "Script $script_path not found."
    fi
}

# Function: install_all_in_dir
#
# Installs all scripts in the specified directory.
#
# Parameters:
#   - $1 : Path to the directory containing scripts to be installed
#
# Usage:
#   install_all_in_dir "/path/to/directory"
#
install_all_in_dir() {
    local dir_path=$1
    if [ -d "$dir_path" ]; then
        log info "Installing all scripts in $dir_path..."
        for script in "$dir_path"/*.sh; do
            install_script "$script"
        done
        log success "All scripts in $dir_path installed successfully."
    else
        log error "Directory $dir_path not found."
    fi
}

# Function: append_to_shell_config
#
# Appends the sourcing command to the user's .bashrc or .zshrc.
#
# Parameters:
#   - $1 : The shell configuration file (.bashrc or .zshrc)
#   - $2 : The script name to be sourced
#
# Usage:
#   append_to_shell_config ".bashrc" "script_name.sh"
#
append_to_shell_config() {
    local shell_config=$1
    local script_name=$2
    local script_path="$HOME/handy_scripts/$script_name"

    if [ -f "$HOME/$shell_config" ]; then
        if ! grep -Fxq "source $script_path" "$HOME/$shell_config"; then
            echo -e "\n# Handy Scripts loading:\nsource $script_path" >> "$HOME/$shell_config"
            log success "Appended source command to $HOME/$shell_config"
        else
            log warning "Source command already exists in $HOME/$shell_config"
        fi
    else
        log error "$HOME/$shell_config not found."
    fi
}

# Function: list_directories
#
# Lists all directories under the collection directory.
#
# Usage:
#   list_directories
#
list_directories() {
    find collection -maxdepth 1 -type d -not -name 'collection' -exec basename {} \;
}

# Function: list_scripts_in_dir
#
# Lists all scripts in the specified directory.
#
# Parameters:
#   - $1 : Path to the directory
#
# Usage:
#   list_scripts_in_dir "/path/to/directory"
#
list_scripts_in_dir() {
    local dir_path=$1
    find "$dir_path" -maxdepth 1 -type f -name '*.sh' -exec basename {} \;
}

# Function: handle_installation
#
# Handles the installation process for a specified directory.
#
# Parameters:
#   - $1 : The directory name
#
handle_installation() {
    local dir="collection/$1"
    local scripts=($(list_scripts_in_dir "$dir"))
    show_menu "${scripts[@]}" "Install all"
    read -p "Select an option: " choice
    if [[ "$choice" -ge 1 && "$choice" -le ${#scripts[@]} ]]; then
        install_script "$dir/${scripts[$((choice-1))]}"
        append_to_shell_config ".bashrc" "${scripts[$((choice-1))]}"
        append_to_shell_config ".zshrc" "${scripts[$((choice-1))]}"
    elif [[ "$choice" -eq $((${#scripts[@]}+1)) ]]; then
        install_all_in_dir "$dir"
        for script in "${scripts[@]}"; do
            append_to_shell_config ".bashrc" "$script"
            append_to_shell_config ".zshrc" "$script"
        done
    else
        log error "Invalid option selected"
    fi
}

# Function: install_all
#
# Installs all scripts in all directories.
#
# Usage:
#   install_all
#
install_all() {
    log info "Installing all scripts..."
    local dirs=($(list_directories))
    for dir in "${dirs[@]}"; do
        install_all_in_dir "collection/$dir"
        local scripts=($(list_scripts_in_dir "collection/$dir"))
        for script in "${scripts[@]}"; do
            append_to_shell_config ".bashrc" "$script"
            append_to_shell_config ".zshrc" "$script"
        done
    done
    log success "All scripts installed successfully."
}

# Main script logic
main() {
    local dirs=($(list_directories))

    if [[ "$1" == "all" ]]; then
        install_all
    elif [[ " ${dirs[@]} " =~ " $1 " ]]; then
        handle_installation "$1"
    else
        echo "Usage: $0 {all|$(IFS=\| ; echo "${dirs[*]}")}"
    fi
}

# Execute main with provided arguments
main "$@"
