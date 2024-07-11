# DESCRIPTION: This file, `apt_utils.sh`, contains a collection of utility functions for managing packages using the apt package manager.
# These functions are designed to simplify common package management tasks and provide useful features.
# They are intended to be sourced in your `.zshrc` or `.bashrc` file.

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
#   display_help install_pkg
#
#   This will display the usage information for the 'install_pkg' utility function.
#
function display_help() {
    local func=$1
    shift
    case "$func" in
        update_system)
            echo "Usage: update_system"
            echo "Updates the package lists for upgrades and new package installations."
            ;;
        upgrade_system)
            echo "Usage: upgrade_system"
            echo "Upgrades all installed packages to their latest versions."
            ;;
        install_pkg)
            echo "Usage: install_pkg <package_name>"
            echo "Installs the specified package."
            ;;
        remove_pkg)
            echo "Usage: remove_pkg <package_name>"
            echo "Removes the specified package."
            ;;
        search_pkg)
            echo "Usage: search_pkg <package_name>"
            echo "Searches for the specified package in the repositories."
            ;;
        show_pkg_info)
            echo "Usage: show_pkg_info <package_name>"
            echo "Displays information about the specified package."
            ;;
        list_installed)
            echo "Usage: list_installed"
            echo "Lists all installed packages."
            ;;
        clean_system)
            echo "Usage: clean_system"
            echo "Cleans up the local repository of retrieved package files."
            ;;
        autoremove)
            echo "Usage: autoremove"
            echo "Removes packages that were automatically installed to satisfy dependencies for other packages and are no longer needed."
            ;;
        *)
            echo "No help available for $func"
            ;;
    esac
}

# Function: update_system
#
# Updates the package lists for upgrades and new package installations.
#
# Usage:
#   update_system
#
# Example:
#   update_system
#
function update_system() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help update_system
        return 0
    fi

    sudo apt-get update && log success "Package lists updated."
}

# Function: upgrade_system
#
# Upgrades all installed packages to their latest versions.
#
# Usage:
#   upgrade_system
#
# Example:
#   upgrade_system
#
function upgrade_system() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help upgrade_system
        return 0
    fi

    sudo apt-get upgrade -y && log success "System upgraded."
}

# Function: install_pkg
#
# Installs the specified package.
#
# Parameters:
#   - $1: The name of the package to install.
#
# Usage:
#   install_pkg <package_name>
#
# Example:
#   install_pkg git
#
function install_pkg() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help install_pkg
        return 0
    fi

    if [ -z "$1" ]; then
        log error "No package name provided."
        return 1
    fi

    sudo apt-get install -y "$1" && log success "Package '$1' installed."
}

# Function: remove_pkg
#
# Removes the specified package.
#
# Parameters:
#   - $1: The name of the package to remove.
#
# Usage:
#   remove_pkg <package_name>
#
# Example:
#   remove_pkg git
#
function remove_pkg() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help remove_pkg
        return 0
    fi

    if [ -z "$1" ]; then
        log error "No package name provided."
        return 1
    fi

    sudo apt-get remove -y "$1" && log success "Package '$1' removed."
}

# Function: search_pkg
#
# Searches for the specified package in the repositories.
#
# Parameters:
#   - $1: The name of the package to search for.
#
# Usage:
#   search_pkg <package_name>
#
# Example:
#   search_pkg git
#
function search_pkg() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help search_pkg
        return 0
    fi

    if [ -z "$1" ]; then
        log error "No package name provided."
        return 1
    fi

    apt-cache search "$1"
}

# Function: show_pkg_info
#
# Displays information about the specified package.
#
# Parameters:
#   - $1: The name of the package to show information for.
#
# Usage:
#   show_pkg_info <package_name>
#
# Example:
#   show_pkg_info git
#
function show_pkg_info() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help show_pkg_info
        return 0
    fi

    if [ -z "$1" ]; then
        log error "No package name provided."
        return 1
    fi

    apt-cache show "$1"
}

# Function: list_installed
#
# Lists all installed packages.
#
# Usage:
#   list_installed
#
# Example:
#   list_installed
#
function list_installed() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help list_installed
        return 0
    fi

    dpkg -l
}

# Function: clean_system
#
# Cleans up the local repository of retrieved package files.
#
# Usage:
#   clean_system
#
# Example:
#   clean_system
#
function clean_system() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help clean_system
        return 0
    fi

    sudo apt-get clean && log success "System cleaned."
}

# Function: autoremove
#
# Removes packages that were automatically installed to satisfy dependencies for other packages and are no longer needed.
#
# Usage:
#   autoremove
#
# Example:
#   autoremove
#
function autoremove() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help autoremove
        return 0
    fi

    sudo apt-get autoremove -y && log success "Unused packages removed."
}
