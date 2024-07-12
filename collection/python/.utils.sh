#!/bin/bash

# DESCRIPTION: This file, `python_utils.sh`, contains a collection of utility functions specifically for Python development.
# It includes functions for managing virtual environments, creating `__init__.py` files, and other helpful utilities.
# These functions are designed to be sourced in your `.zshrc` or `.bashrc` file.

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
#   display_help mkinit
#
#   This will display the usage information for the 'mkinit' utility function.
#
function display_help() {
    local func=$1
    shift
    case "$func" in
        mkinit)
            echo "Usage: mkinit"
            echo "Creates '__init__.py' files in the current directory and all its subdirectories."
            ;;
        mkvenv)
            echo "Usage: mkvenv <env_name>"
            echo "Creates a new virtual environment with the specified name."
            ;;
        actvenv)
            echo "Usage: actvenv <env_name>"
            echo "Activates the specified virtual environment."
            ;;
        deactvenv)
            echo "Usage: deactvenv"
            echo "Deactivates the current virtual environment."
            ;;
        rmvenv)
            echo "Usage: rmvenv <env_name>"
            echo "Removes the specified virtual environment."
            ;;
        install_requirements)
            echo "Usage: install_requirements <requirements_file>"
            echo "Installs packages from the specified requirements file."
            ;;
        upgrade_packages)
            echo "Usage: upgrade_packages"
            echo "Upgrades all installed packages in the current virtual environment."
            ;;
        *)
            echo "No help available for $func"
            ;;
    esac
}

# Function: mkinit
#
# Creates '__init__.py' files in the current directory and all its subdirectories.
#
# Usage:
#   mkinit
#
# Example:
#   mkinit
#
function mkinit() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help mkinit
        return 0
    fi

    find . -type d -exec touch {}/__init__.py \;
    log success "__init__.py files created in all directories."
}

# Function: mkvenv
#
# Creates a new virtual environment with the specified name.
#
# Parameters:
#   - $1: The name of the virtual environment to create.
#
# Usage:
#   mkvenv <env_name>
#
# Example:
#   mkvenv myenv
#
function mkvenv() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help mkvenv
        return 0
    fi

    if [ -z "$1" ]; then
        log error "No virtual environment name provided."
        return 1
    fi

    python3 -m venv "$1" && log success "Virtual environment '$1' created."
}

# Function: actvenv
#
# Activates the specified virtual environment.
#
# Parameters:
#   - $1: The name of the virtual environment to activate.
#
# Usage:
#   actvenv <env_name>
#
# Example:
#   actvenv myenv
#
function actvenv() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help actvenv
        return 0
    fi

    if [ -z "$1" ]; then
        log error "No virtual environment name provided."
        return 1
    fi

    source "$1/bin/activate" && log success "Virtual environment '$1' activated."
}

# Function: deactvenv
#
# Deactivates the current virtual environment.
#
# Usage:
#   deactvenv
#
# Example:
#   deactvenv
#
function deactvenv() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help deactvenv
        return 0
    fi

    deactivate && log success "Virtual environment deactivated."
}

# Function: rmvenv
#
# Removes the specified virtual environment.
#
# Parameters:
#   - $1: The name of the virtual environment to remove.
#
# Usage:
#   rmvenv <env_name>
#
# Example:
#   rmvenv myenv
#
function rmvenv() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help rmvenv
        return 0
    fi

    if [ -z "$1" ]; then
        log error "No virtual environment name provided."
        return 1
    fi

    rm -rf "$1" && log success "Virtual environment '$1' removed."
}

# Function: install_requirements
#
# Installs packages from the specified requirements file.
#
# Parameters:
#   - $1: The path to the requirements file.
#
# Usage:
#   install_requirements <requirements_file>
#
# Example:
#   install_requirements requirements.txt
#
function install_requirements() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help install_requirements
        return 0
    fi

    if [ -z "$1" ]; then
        log error "No requirements file provided."
        return 1
    fi

    pip install -r "$1" && log success "Packages installed from '$1'."
}

# Function: upgrade_packages
#
# Upgrades all installed packages in the current virtual environment.
#
# Usage:
#   upgrade_packages
#
# Example:
#   upgrade_packages
#
function upgrade_packages() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help upgrade_packages
        return 0
    fi

    pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U && log success "All packages upgraded."
}
