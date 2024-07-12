#!/bin/bash

# DESCRIPTION: This file, `github_utils.sh`, contains a collection of utility functions for managing GitHub repositories.
# These functions are designed to simplify common GitHub tasks and provide useful features.
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
#   display_help hub_clonerepo
#
#   This will display the usage information for the 'hub_clonerepo' utility function.
#
function display_help() {
    local func=$1
    shift
    case "$func" in
        hub_clonerepo)
            echo "Usage: hub_clonerepo <username> <repo_name> [additional_arguments]"
            echo "Clones the specified GitHub repository."
            ;;
        hub_createrepo)
            echo "Usage: hub_createrepo <repo_name> [description]"
            echo "Creates a new GitHub repository with the specified name and optional description."
            ;;
        hub_delrepo)
            echo "Usage: hub_delrepo <repo_name>"
            echo "Deletes the specified GitHub repository."
            ;;
        hub_createbranch)
            echo "Usage: hub_createbranch <branch_name>"
            echo "Creates a new branch with the specified name."
            ;;
        hub_delbranch)
            echo "Usage: hub_delbranch <branch_name>"
            echo "Deletes the specified branch."
            ;;
        hub_listbranches)
            echo "Usage: hub_listbranches"
            echo "Lists all branches in the current repository."
            ;;
        hub_push)
            echo "Usage: hub_push <branch_name>"
            echo "Pushes the specified branch to the remote repository."
            ;;
        hub_pull)
            echo "Usage: hub_pull <branch_name>"
            echo "Pulls the specified branch from the remote repository."
            ;;
        *)
            echo "No help available for $func"
            ;;
    esac
}

# Function: hub_clonerepo
#
# Clones the specified GitHub repository.
#
# Parameters:
#   - $1: The username
#   - $2: The repository name
#   - $3: (Optional) additional arguments
#
# Usage:
#   hub_clonerepo <username> <repo_name> [additional_arguments]
#
# Example:
#   hub_clonerepo user repo --depth 1
#
function hub_clonerepo() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_clonerepo
        return 0
    fi

    if [ -z "$1" ] || [ -z "$2" ]; then
        log error "Usage: hub_clonerepo <username> <repo_name> [additional_arguments]"
        return 1
    fi

    local repo_url="https://github.com/$1/$2.git"
    if ! [[ $repo_url =~ ^https://github\.com/.+/.+\.git$ ]]; then
        log error "Invalid repository URL: $repo_url"
        return 1
    fi

    git clone "$repo_url" "${@:3}" && log success "Repository cloned from '$repo_url'." || log error "Failed to clone repository from '$repo_url'."
}

# Function: hub_createrepo
#
# Creates a new GitHub repository with the specified name and optional description.
#
# Parameters:
#   - $1: The name of the repository to create.
#   - $2: (Optional) The description of the repository.
#
# Usage:
#   hub_createrepo <repo_name> [description]
#
# Example:
#   hub_createrepo myrepo "This is my new repository"
#
function hub_createrepo() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_createrepo
        return 0
    fi

    if [ -z "$1" ]; then
        log error "No repository name provided."
        return 1
    fi

    local description="${2:-}"
    gh repo create "$1" --description "$description" --public && log success "Repository '$1' created." || log error "Failed to create repository '$1'."
}

# Function: hub_delrepo
#
# Deletes the specified GitHub repository.
#
# Parameters:
#   - $1: The name of the repository to delete.
#
# Usage:
#   hub_delrepo <repo_name>
#
# Example:
#   hub_delrepo myrepo
#
function hub_delrepo() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_delrepo
        return 0
    fi

    if [ -z "$1" ]; then
        log error "No repository name provided."
        return 1
    fi

    gh repo delete "$1" --confirm && log success "Repository '$1' deleted." || log error "Failed to delete repository '$1'."
}

# Function: hub_createbranch
#
# Creates a new branch with the specified name.
#
# Parameters:
#   - $1: The name of the branch to create.
#
# Usage:
#   hub_createbranch <branch_name>
#
# Example:
#   hub_createbranch myfeature
#
function hub_createbranch() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_createbranch
        return 0
    fi

    if [ -z "$1" ]; then
        log error "No branch name provided."
        return 1
    fi

    git checkout -b "$1" && log success "Branch '$1' created." || log error "Failed to create branch '$1'."
}

# Function: hub_delbranch
#
# Deletes the specified branch.
#
# Parameters:
#   - $1: The name of the branch to delete.
#
# Usage:
#   hub_delbranch <branch_name>
#
# Example:
#   hub_delbranch myfeature
#
function hub_delbranch() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_delbranch
        return 0
    fi

    if [ -z "$1" ]; then
        log error "No branch name provided."
        return 1
    fi

    git branch -d "$1" && log success "Branch '$1' deleted." || log error "Failed to delete branch '$1'."
}

# Function: hub_listbranches
#
# Lists all branches in the current repository.
#
# Usage:
#   hub_listbranches
#
# Example:
#   hub_listbranches
#
function hub_listbranches() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_listbranches
        return 0
    fi

    git branch -a
}

# Function: hub_push
#
# Pushes the specified branch to the remote repository.
#
# Parameters:
#   - $1: The name of the branch to push.
#
# Usage:
#   hub_push <branch_name>
#
# Example:
#   hub_push myfeature
#
function hub_push() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_push
        return 0
    fi

    if [ -z "$1" ]; then
        log error "No branch name provided."
        return 1
    fi

    git push origin "$1" && log success "Branch '$1' pushed to remote." || log error "Failed to push branch '$1' to remote."
}

# Function: hub_pull
#
# Pulls the specified branch from the remote repository.
#
# Parameters:
#   - $1: The name of the branch to pull.
#
# Usage:
#   hub_pull <branch_name>
#
# Example:
#   hub_pull myfeature
#
function hub_pull() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_pull
        return 0
    fi

    if [ -z "$1" ]; then
        log error "No branch name provided."
        return 1
    fi

    git pull origin "$1" && log success "Branch '$1' pulled from remote." || log error "Failed to pull branch '$1' from remote."
}
