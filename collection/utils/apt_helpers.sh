#!/bin/bash
# DESCRIPTION:
# This file, `apt_utils.sh`, contains a collection of utility functions for managing packages using the apt package manager.
# These functions are designed to simplify common package management tasks and provide useful features.
# They are intended to be sourced in your `.zshrc` or `.bashrc` file.

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
#   display_help install_pkg
#
function display_help() {
    local func=$1
    case "$func" in
        update_system)
            cat << EOF
Usage: update_system
Updates the package lists for upgrades and new package installations.
EOF
            ;;
        upgrade_system)
            cat << EOF
Usage: upgrade_system
Upgrades all installed packages to their latest versions.
EOF
            ;;
        dist_upgrade)
            cat << EOF
Usage: dist_upgrade
Performs a distribution upgrade, updating packages and installing/removing packages as necessary.
EOF
            ;;
        install_pkg)
            cat << EOF
Usage: install_pkg <package_name> [package_name ...]
Installs the specified package(s).
EOF
            ;;
        remove_pkg)
            cat << EOF
Usage: remove_pkg <package_name> [package_name ...]
Removes the specified package(s).
EOF
            ;;
        purge_pkg)
            cat << EOF
Usage: purge_pkg <package_name> [package_name ...]
Removes the specified package(s) and their configuration files.
EOF
            ;;
        search_pkg)
            cat << EOF
Usage: search_pkg <search_term>
Searches for the specified term in package names and descriptions.
EOF
            ;;
        show_pkg_info)
            cat << EOF
Usage: show_pkg_info <package_name>
Displays detailed information about the specified package.
EOF
            ;;
        list_installed)
            cat << EOF
Usage: list_installed
Lists all installed packages.
EOF
            ;;
        list_upgradable)
            cat << EOF
Usage: list_upgradable
Lists packages that have available upgrades.
EOF
            ;;
        clean_system)
            cat << EOF
Usage: clean_system
Cleans up the local repository of retrieved package files.
EOF
            ;;
        autoremove)
            cat << EOF
Usage: autoremove
Removes packages that were automatically installed and are no longer required.
EOF
            ;;
        hold_pkg)
            cat << EOF
Usage: hold_pkg <package_name> [package_name ...]
Holds the specified package(s) at their current version.
EOF
            ;;
        unhold_pkg)
            cat << EOF
Usage: unhold_pkg <package_name> [package_name ...]
Unholds the specified package(s), allowing them to be upgraded.
EOF
            ;;
        show_pkg_deps)
            cat << EOF
Usage: show_pkg_deps <package_name>
Displays the dependencies of the specified package.
EOF
            ;;
        show_pkg_reverse_deps)
            cat << EOF
Usage: show_pkg_reverse_deps <package_name>
Displays the reverse dependencies of the specified package.
EOF
            ;;
        help | "")
            cat << EOF
Available functions:
  update_system          - Updates the package lists for upgrades and new package installations.
  upgrade_system         - Upgrades all installed packages to their latest versions.
  dist_upgrade           - Performs a distribution upgrade, updating packages and installing/removing packages as necessary.
  install_pkg            - Installs the specified package(s).
  remove_pkg             - Removes the specified package(s).
  purge_pkg              - Removes the specified package(s) and their configuration files.
  search_pkg             - Searches for the specified term in package names and descriptions.
  show_pkg_info          - Displays detailed information about the specified package.
  list_installed         - Lists all installed packages.
  list_upgradable        - Lists packages that have available upgrades.
  clean_system           - Cleans up the local repository of retrieved package files.
  autoremove             - Removes packages that were automatically installed and are no longer required.
  hold_pkg               - Holds the specified package(s) at their current version.
  unhold_pkg             - Unholds the specified package(s), allowing them to be upgraded.
  show_pkg_deps          - Displays the dependencies of the specified package.
  show_pkg_reverse_deps  - Displays the reverse dependencies of the specified package.
Use 'display_help <function_name>' to see detailed usage of a specific function.
EOF
            ;;
        *)
            log error "No help available for '$func'"
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
function update_system() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help update_system
        return 0
    fi

    if sudo apt update; then
        log success "Package lists updated."
    else
        log error "Failed to update package lists."
    fi
}

# Function: upgrade_system
#
# Upgrades all installed packages to their latest versions.
#
# Usage:
#   upgrade_system
#
function upgrade_system() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help upgrade_system
        return 0
    fi

    if sudo apt upgrade -y; then
        log success "System upgraded."
    else
        log error "Failed to upgrade system."
    fi
}

# Function: dist_upgrade
#
# Performs a distribution upgrade, updating packages and installing/removing packages as necessary.
#
# Usage:
#   dist_upgrade
#
function dist_upgrade() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help dist_upgrade
        return 0
    fi

    if sudo apt full-upgrade -y; then
        log success "Distribution upgraded."
    else
        log error "Failed to perform distribution upgrade."
    fi
}

# Function: install_pkg
#
# Installs the specified package(s).
#
# Parameters:
#   - $@: The names of the packages to install.
#
# Usage:
#   install_pkg <package_name> [package_name ...]
#
function install_pkg() {
    if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
        display_help install_pkg
        return 0
    fi

    if sudo apt install -y "$@"; then
        log success "Package(s) '$*' installed."
    else
        log error "Failed to install package(s): $*"
    fi
}

# Function: remove_pkg
#
# Removes the specified package(s).
#
# Parameters:
#   - $@: The names of the packages to remove.
#
# Usage:
#   remove_pkg <package_name> [package_name ...]
#
function remove_pkg() {
    if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
        display_help remove_pkg
        return 0
    fi

    if sudo apt remove -y "$@"; then
        log success "Package(s) '$*' removed."
    else
        log error "Failed to remove package(s): $*"
    fi
}

# Function: purge_pkg
#
# Removes the specified package(s) and their configuration files.
#
# Parameters:
#   - $@: The names of the packages to purge.
#
# Usage:
#   purge_pkg <package_name> [package_name ...]
#
function purge_pkg() {
    if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
        display_help purge_pkg
        return 0
    fi

    if sudo apt purge -y "$@"; then
        log success "Package(s) '$*' purged."
    else
        log error "Failed to purge package(s): $*"
    fi
}

# Function: search_pkg
#
# Searches for the specified term in package names and descriptions.
#
# Parameters:
#   - $1: The search term.
#
# Usage:
#   search_pkg <search_term>
#
function search_pkg() {
    if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
        display_help search_pkg
        return 0
    fi

    apt search "$1"
}

# Function: show_pkg_info
#
# Displays detailed information about the specified package.
#
# Parameters:
#   - $1: The name of the package.
#
# Usage:
#   show_pkg_info <package_name>
#
function show_pkg_info() {
    if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
        display_help show_pkg_info
        return 0
    fi

    apt show "$1"
}

# Function: list_installed
#
# Lists all installed packages.
#
# Usage:
#   list_installed
#
function list_installed() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help list_installed
        return 0
    fi

    dpkg -l
}

# Function: list_upgradable
#
# Lists packages that have available upgrades.
#
# Usage:
#   list_upgradable
#
function list_upgradable() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help list_upgradable
        return 0
    fi

    apt list --upgradable
}

# Function: clean_system
#
# Cleans up the local repository of retrieved package files.
#
# Usage:
#   clean_system
#
function clean_system() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help clean_system
        return 0
    fi

    if sudo apt clean; then
        log success "System cleaned."
    else
        log error "Failed to clean system."
    fi
}

# Function: autoremove
#
# Removes packages that were automatically installed and are no longer required.
#
# Usage:
#   autoremove
#
function autoremove() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help autoremove
        return 0
    fi

    if sudo apt autoremove -y; then
        log success "Unused packages removed."
    else
        log error "Failed to remove unused packages."
    fi
}

# Function: hold_pkg
#
# Holds the specified package(s) at their current version.
#
# Parameters:
#   - $@: The names of the packages to hold.
#
# Usage:
#   hold_pkg <package_name> [package_name ...]
#
function hold_pkg() {
    if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
        display_help hold_pkg
        return 0
    fi

    if echo "$@" | xargs sudo apt-mark hold; then
        log success "Package(s) '$*' held."
    else
        log error "Failed to hold package(s): $*"
    fi
}

# Function: unhold_pkg
#
# Unholds the specified package(s), allowing them to be upgraded.
#
# Parameters:
#   - $@: The names of the packages to unhold.
#
# Usage:
#   unhold_pkg <package_name> [package_name ...]
#
function unhold_pkg() {
    if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
        display_help unhold_pkg
        return 0
    fi

    if echo "$@" | xargs sudo apt-mark unhold; then
        log success "Package(s) '$*' unheld."
    else
        log error "Failed to unhold package(s): $*"
    fi
}

# Function: show_pkg_deps
#
# Displays the dependencies of the specified package.
#
# Parameters:
#   - $1: The name of the package.
#
# Usage:
#   show_pkg_deps <package_name>
#
function show_pkg_deps() {
    if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
        display_help show_pkg_deps
        return 0
    fi

    apt-cache depends "$1"
}

# Function: show_pkg_reverse_deps
#
# Displays the reverse dependencies of the specified package.
#
# Parameters:
#   - $1: The name of the package.
#
# Usage:
#   show_pkg_reverse_deps <package_name>
#
function show_pkg_reverse_deps() {
    if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
        display_help show_pkg_reverse_deps
        return 0
    fi

    apt-cache rdepends "$1"
}

# Function: search_file_in_pkgs
#
# Searches for packages that provide a file.
#
# Parameters:
#   - $1: The file name to search for.
#
# Usage:
#   search_file_in_pkgs <file_name>
#
function search_file_in_pkgs() {
    if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
        cat << EOF
Usage: search_file_in_pkgs <file_name>
Searches for packages that provide a file.
EOF
        return 0
    fi

    check_apt_file

    apt-file search "$1"
}

# Function: update_apt_file
#
# Updates the apt-file index.
#
# Usage:
#   update_apt_file
#
function update_apt_file() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        cat << EOF
Usage: update_apt_file
Updates the apt-file index.
EOF
        return 0
    fi

    if sudo apt-file update; then
        log success "apt-file index updated."
    else
        log error "Failed to update apt-file index."
    fi
}

# Function: check_apt_file
#
# Checks if apt-file is installed, and installs it if not.
#
function check_apt_file() {
    if ! command -v apt-file >/dev/null 2>&1; then
        log info "apt-file is not installed. Installing apt-file..."
        if sudo apt install -y apt-file; then
            log success "apt-file installed."
            update_apt_file
        else
            log error "Failed to install apt-file."
        fi
    fi
}
