#!/bin/bash

# DESCRIPTION: This file, `github_advanced_utils.sh`, contains a collection of advanced utility functions for managing GitHub repositories.
# These functions include operations related to hooks, cherry-picks, pull requests, releases, and pre-commit hooks.
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

# Function: display_advanced_help
#
# Displays the usage information for various advanced utility functions.
#
# Parameters:
#   - func: The name of the utility function to display help for.
#
# Usage:
#   display_advanced_help <func>
#
# Example:
#   display_advanced_help hub_addhook
#
#   This will display the usage information for the 'hub_addhook' utility function.
#
function display_advanced_help() {
    local func=$1
    shift
    case "$func" in
        hub_addhook)
            echo "Usage: hub_addhook <repo_name> <hook_url> <event>"
            echo "Adds a webhook to the specified GitHub repository."
            ;;
        hub_removehook)
            echo "Usage: hub_removehook <repo_name> <hook_id>"
            echo "Removes a webhook from the specified GitHub repository."
            ;;
        hub_list_hooks)
            echo "Usage: hub_list_hooks <repo_name>"
            echo "Lists all webhooks in the specified GitHub repository."
            ;;
        hub_cherrypick)
            echo "Usage: hub_cherrypick <commit_hash>"
            echo "Cherry-picks the specified commit."
            ;;
        hub_merge)
            echo "Usage: hub_merge <source_branch> <target_branch>"
            echo "Merges the specified source branch into the target branch."
            ;;
        hub_rebase)
            echo "Usage: hub_rebase <base_branch>"
            echo "Rebases the current branch onto the specified base branch."
            ;;
        hub_createpr)
            echo "Usage: hub_createpr <title> <body> <base> <head>"
            echo "Creates a new pull request."
            ;;
        hub_listprs)
            echo "Usage: hub_listprs <repo_name>"
            echo "Lists all pull requests in the specified GitHub repository."
            ;;
        hub_createrelease)
            echo "Usage: hub_createrelease <tag> <title> <body>"
            echo "Creates a new release."
            ;;
        hub_listreleases)
            echo "Usage: hub_listreleases <repo_name>"
            echo "Lists all releases in the specified GitHub repository."
            ;;
        hub_setup_precommit)
            echo "Usage: hub_setup_precommit [hook_id] [rev]"
            echo "Sets up a basic pre-commit configuration."
            ;;
        hub_edit_precommit)
            echo "Usage: hub_edit_precommit"
            echo "Opens the pre-commit configuration file in the default IDE."
            ;;
        *)
            echo "No help available for $func"
            ;;
    esac
}

# Function: hub_addhook
#
# Adds a webhook to the specified GitHub repository.
#
# Parameters:
#   - $1: The name of the repository.
#   - $2: The URL of the webhook.
#   - $3: The event to trigger the webhook.
#
# Usage:
#   hub_addhook <repo_name> <hook_url> <event>
#
# Example:
#   hub_addhook myrepo https://example.com/webhook push
#
function hub_addhook() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_advanced_help hub_addhook
        return 0
    fi

    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        log error "Usage: hub_addhook <repo_name> <hook_url> <event>"
        return 1
    fi

    gh api -X POST "/repos/$1/hooks" -f "config.url=$2" -f "events=$3" -f "config.content_type=json" \
        && log success "Webhook added to repository '$1'." \
        || log error "Failed to add webhook to repository '$1'."
}

# Function: hub_removehook
#
# Removes a webhook from the specified GitHub repository.
#
# Parameters:
#   - $1: The name of the repository.
#   - $2: The ID of the webhook to remove.
#
# Usage:
#   hub_removehook <repo_name> <hook_id>
#
# Example:
#   hub_removehook myrepo 123456
#
function hub_removehook() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_advanced_help hub_removehook
        return 0
    fi

    if [ -z "$1" ] || [ -z "$2" ]; then
        log error "Usage: hub_removehook <repo_name> <hook_id>"
        return 1
    fi

    gh api -X DELETE "/repos/$1/hooks/$2" \
        && log success "Webhook '$2' removed from repository '$1'." \
        || log error "Failed to remove webhook '$2' from repository '$1'."
}

# Function: hub_list_hooks
#
# Lists all webhooks in the specified GitHub repository.
#
# Parameters:
#   - $1: The name of the repository.
#
# Usage:
#   hub_list_hooks <repo_name>
#
# Example:
#   hub_list_hooks myrepo
#
function hub_list_hooks() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_advanced_help hub_list_hooks
        return 0
    fi

    if [ -z "$1" ]; then
        log error "Usage: hub_list_hooks <repo_name>"
        return 1
    fi

    gh api "/repos/$1/hooks" \
        && log success "Listed webhooks for repository '$1'." \
        || log error "Failed to list webhooks for repository '$1'."
}

# Function: hub_cherrypick
#
# Cherry-picks the specified commit.
#
# Parameters:
#   - $1: The commit hash to cherry-pick.
#
# Usage:
#   hub_cherrypick <commit_hash>
#
# Example:
#   hub_cherrypick abc1234
#
function hub_cherrypick() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_advanced_help hub_cherrypick
        return 0
    fi

    if [ -z "$1" ]; then
        log error "Usage: hub_cherrypick <commit_hash>"
        return 1
    fi

    git cherry-pick "$1" \
        && log success "Commit '$1' cherry-picked." \
        || log error "Failed to cherry-pick commit '$1'."
}

# Function: hub_merge
#
# Merges the specified source branch into the target branch.
#
# Parameters:
#   - $1: The source branch.
#   - $2: The target branch.
#
# Usage:
#   hub_merge <source_branch> <target_branch>
#
# Example:
#   hub_merge feature-branch main
#
function hub_merge() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_advanced_help hub_merge
        return 0
    fi

    if [ -z "$1" ] || [ -z "$2" ]; then
        log error "Usage: hub_merge <source_branch> <target_branch>"
        return 1
    fi

    git checkout "$2" \
        && git merge "$1" \
        && log success "Branch '$1' merged into '$2'." \
        || log error "Failed to merge branch '$1' into '$2'."
}

# Function: hub_rebase
#
# Rebases the current branch onto the specified base branch.
#
# Parameters:
#   - $1: The base branch to rebase onto.
#
# Usage:
#   hub_rebase <base_branch>
#
# Example:
#   hub_rebase main
#
function hub_rebase() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_advanced_help hub_rebase
        return 0
    fi

    if [ -z "$1" ]; then
        log error "Usage: hub_rebase <base_branch>"
        return 1
    fi

    git rebase "$1" \
        && log success "Current branch rebased onto '$1'." \
        || log error "Failed to rebase current branch onto '$1'."
}

# Function: hub_createpr
#
# Creates a new pull request.
#
# Parameters:
#   - $1: The title of the pull request.
#   - $2: The body of the pull request.
#   - $3: The base branch.
#   - $4: The head branch.
#
# Usage:
#   hub_createpr <title> <body> <base> <head>
#
# Example:
#   hub_createpr "New Feature" "This PR adds a new feature" main feature-branch
#
function hub_createpr() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_advanced_help hub_createpr
        return 0
    fi

    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
        log error "Usage: hub_createpr <title> <body> <base> <head>"
        return 1
    fi

    gh pr create --title "$1" --body "$2" --base "$3" --head "$4" \
        && log success "Pull request created." \
        || log error "Failed to create pull request."
}

# Function: hub_listprs
#
# Lists all pull requests in the specified GitHub repository.
#
# Parameters:
#   - $1: The name of the repository.
#
# Usage:
#   hub_listprs <repo_name>
#
# Example:
#   hub_listprs myrepo
#
function hub_listprs() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_advanced_help hub_listprs
        return 0
    fi

    if [ -z "$1" ]; then
        log error "Usage: hub_listprs <repo_name>"
        return 1
    fi

    gh pr list --repo "$1" \
        && log success "Listed pull requests for repository '$1'." \
        || log error "Failed to list pull requests for repository '$1'."
}

# Function: hub_createrelease
#
# Creates a new release.
#
# Parameters:
#   - $1: The tag for the release.
#   - $2: The title of the release.
#   - $3: The body of the release.
#
# Usage:
#   hub_createrelease <tag> <title> <body>
#
# Example:
#   hub_createrelease v1.0.0 "Initial Release" "This is the first release."
#
function hub_createrelease() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_advanced_help hub_createrelease
        return 0
    fi

    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        log error "Usage: hub_createrelease <tag> <title> <body>"
        return 1
    fi

    gh release create "$1" --title "$2" --notes "$3" \
        && log success "Release created." \
        || log error "Failed to create release."
}

# Function: hub_listreleases
#
# Lists all releases in the specified GitHub repository.
#
# Parameters:
#   - $1: The name of the repository.
#
# Usage:
#   hub_listreleases <repo_name>
#
# Example:
#   hub_listreleases myrepo
#
function hub_listreleases() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_advanced_help hub_listreleases
        return 0
    fi

    if [ -z "$1" ]; then
        log error "Usage: hub_listreleases <repo_name>"
        return 1
    fi

    gh release list --repo "$1" \
        && log success "Listed releases for repository '$1'." \
        || log error "Failed to list releases for repository '$1'."
}

# Function: hub_setup_precommit
#
# Sets up a basic pre-commit configuration.
#
# Parameters:
#   - $1: (Optional) The hook ID.
#   - $2: (Optional) The revision/version of the hook.
#
# Usage:
#   hub_setup_precommit [hook_id] [rev]
#
# Example:
#   hub_setup_precommit trailing-whitespace v3.4.0
#
function hub_setup_precommit() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_advanced_help hub_setup_precommit
        return 0
    fi

    local hook_id=${1:-trailing-whitespace}
    local rev=${2:-v3.4.0}

    if [ ! -f ".pre-commit-config.yaml" ]; then
        cat <<EOF > .pre-commit-config.yaml
# Example pre-commit configuration
repos:
- repo: https://github.com/pre-commit/pre-commit-hooks
  rev: $rev
  hooks:
    - id: $hook_id
EOF
        log success "Created .pre-commit-config.yaml with hook '$hook_id' at revision '$rev'."
    else
        log warning ".pre-commit-config.yaml already exists."
    fi

    pre-commit install && log success "Pre-commit hooks installed." || log error "Failed to install pre-commit hooks."
}

# Function: hub_edit_precommit
#
# Opens the pre-commit configuration file in the default IDE.
#
# Usage:
#   hub_edit_precommit
#
# Example:
#   hub_edit_precommit
#
function hub_edit_precommit() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_advanced_help hub_edit_precommit
        return 0
    fi

    if [ ! -f ".pre-commit-config.yaml" ]; then
        hub_setup_precommit
    fi

    local editor=${EDITOR:-code}
    if ! command -v "$editor" &> /dev/null; then
        log error "Editor '$editor' not found. Please set your default editor using the EDITOR environment variable."
        return 1
    fi

    "$editor" .pre-commit-config.yaml && log success "Opened .pre-commit-config.yaml in the default editor." || log error "Failed to open .pre-commit-config.yaml in the default editor."
}
