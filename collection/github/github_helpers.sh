#!/bin/bash
# DESCRIPTION:
# This file, `github_utils.sh`, contains a collection of utility functions for managing GitHub repositories.
# It includes basic and advanced functions for operations like cloning repositories, managing branches,
# handling pull requests, webhooks, releases, and setting up pre-commit hooks.
# These functions are designed to simplify common GitHub tasks and are intended to be sourced in your `.zshrc` or `.bashrc` file.

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
    local type="$1"
    shift
    local message="$*"
    case "$type" in
        info)
            printf "%b[INFO]%b %s\n" "$COLOR_INFO" "$COLOR_RESET" "$message"
            ;;
        success)
            printf "%b[SUCCESS]%b %s\n" "$COLOR_SUCCESS" "$COLOR_RESET" "$message"
            ;;
        warning)
            printf "%b[WARNING]%b %s\n" "$COLOR_WARNING" "$COLOR_RESET" "$message"
            ;;
        error)
            printf "%b[ERROR]%b %s\n" "$COLOR_ERROR" "$COLOR_RESET" "$message" >&2
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
#   - func: The name of the utility function to display help for.
#
# Usage:
#   display_help [function_name]
#
# Example:
#   display_help hub_clone_repo
#
function display_help() {
    local func="$1"
    case "$func" in
        hub_clone_repo)
            cat << EOF
    Usage: hub_clone_repo <username> <repo_name> [additional_arguments]
    Clones the specified GitHub repository.
EOF
            ;;
        hub_create_repo)
            cat << EOF
    Usage: hub_create_repo <repo_name> [description] [private]
    Creates a new GitHub repository with the specified name and optional description.
    Set 'private' to 'true' to create a private repository.
EOF
            ;;
        hub_delete_repo)
            cat << EOF
    Usage: hub_delete_repo <repo_name>
    Deletes the specified GitHub repository.
EOF
            ;;
        hub_create_branch)
            cat << EOF
    Usage: hub_create_branch <branch_name>
    Creates a new branch with the specified name.
EOF
            ;;
        hub_delete_branch)
            cat << EOF
    Usage: hub_delete_branch <branch_name>
    Deletes the specified branch.
EOF
            ;;
        hub_list_branches)
            cat << EOF
    Usage: hub_list_branches
    Lists all branches in the current repository.
EOF
            ;;
        hub_push)
            cat << EOF
    Usage: hub_push [remote] [branch_name]
    Pushes the specified branch to the remote repository. Defaults to 'origin' and current branch if not specified.
EOF
            ;;
        hub_pull)
            cat << EOF
    Usage: hub_pull [remote] [branch_name]
    Pulls the specified branch from the remote repository. Defaults to 'origin' and current branch if not specified.
EOF
            ;;
        hub_add_hook)
            cat << EOF
    Usage: hub_add_hook <repo_name> <hook_url> <event>
    Adds a webhook to the specified GitHub repository.
EOF
            ;;
        hub_remove_hook)
            cat << EOF
    Usage: hub_remove_hook <repo_name> <hook_id>
    Removes a webhook from the specified GitHub repository.
EOF
            ;;
        hub_list_hooks)
            cat << EOF
    Usage: hub_list_hooks <repo_name>
    Lists all webhooks in the specified GitHub repository.
EOF
            ;;
        hub_cherry_pick)
            cat << EOF
    Usage: hub_cherry_pick <commit_hash>
    Cherry-picks the specified commit.
EOF
            ;;
        hub_merge)
            cat << EOF
    Usage: hub_merge <source_branch> <target_branch>
    Merges the specified source branch into the target branch.
EOF
            ;;
        hub_rebase)
            cat << EOF
    Usage: hub_rebase <base_branch>
    Rebases the current branch onto the specified base branch.
EOF
            ;;
        hub_create_pr)
            cat << EOF
    Usage: hub_create_pr <title> <body> [base] [head]
    Creates a new pull request. Defaults to current branch as 'head' and 'main' as 'base' if not specified.
EOF
            ;;
        hub_list_prs)
            cat << EOF
    Usage: hub_list_prs <repo_name>
    Lists all pull requests in the specified GitHub repository.
EOF
            ;;
        hub_create_release)
            cat << EOF
    Usage: hub_create_release <tag> <title> <body>
    Creates a new release.
EOF
            ;;
        hub_list_releases)
            cat << EOF
    Usage: hub_list_releases <repo_name>
    Lists all releases in the specified GitHub repository.
EOF
            ;;
        hub_setup_precommit)
            cat << EOF
    Usage: hub_setup_precommit [hook_id] [rev]
    Sets up a basic pre-commit configuration.
EOF
            ;;
        hub_edit_precommit)
            cat << EOF
    Usage: hub_edit_precommit
    Opens the pre-commit configuration file in the default editor.
EOF
            ;;
        *)
            cat << EOF
    Available functions:
      hub_clone_repo        - Clones a GitHub repository.
      hub_create_repo       - Creates a new GitHub repository.
      hub_delete_repo       - Deletes a GitHub repository.
      hub_create_branch     - Creates a new branch.
      hub_delete_branch     - Deletes a branch.
      hub_list_branches     - Lists all branches in the repository.
      hub_push              - Pushes a branch to the remote repository.
      hub_pull              - Pulls a branch from the remote repository.
      hub_add_hook          - Adds a webhook to a repository.
      hub_remove_hook       - Removes a webhook from a repository.
      hub_list_hooks        - Lists all webhooks in a repository.
      hub_cherry_pick       - Cherry-picks a commit.
      hub_merge             - Merges a branch into another.
      hub_rebase            - Rebases current branch onto another.
      hub_create_pr         - Creates a new pull request.
      hub_list_prs          - Lists all pull requests in a repository.
      hub_create_release    - Creates a new release.
      hub_list_releases     - Lists all releases in a repository.
      hub_setup_precommit   - Sets up pre-commit hooks.
      hub_edit_precommit    - Edits pre-commit configuration.
    Use 'display_help <function_name>' to see detailed usage of a specific function.
EOF
            ;;
    esac
}

# Function: hub_clone_repo
#
# Clones the specified GitHub repository.
#
# Usage:
#   hub_clone_repo <username> <repo_name> [additional_arguments]
#
function hub_clone_repo() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_clone_repo
        return 0
    fi

    if [[ -z "$1" || -z "$2" ]]; then
        log error "Usage: hub_clone_repo <username> <repo_name> [additional_arguments]"
        return 1
    fi

    local username="$1"
    local repo_name="$2"
    shift 2
    local repo_url="https://github.com/${username}/${repo_name}.git"

    if ! git clone "$repo_url" "$@" ; then
        log error "Failed to clone repository from '$repo_url'."
        return 1
    else
        log success "Repository cloned from '$repo_url'."
    fi
}

# Function: hub_create_repo
#
# Creates a new GitHub repository with the specified name and optional description.
#
# Usage:
#   hub_create_repo <repo_name> [description] [private]
#
function hub_create_repo() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_create_repo
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "No repository name provided."
        return 1
    fi

    local repo_name="$1"
    local description="${2:-}"
    local private_flag="--public"

    if [[ "$3" == "true" ]]; then
        private_flag="--private"
    fi

    if gh repo create "$repo_name" --description "$description" $private_flag --confirm; then
        log success "Repository '$repo_name' created."
    else
        log error "Failed to create repository '$repo_name'."
        return 1
    fi
}

# Function: hub_delete_repo
#
# Deletes the specified GitHub repository.
#
# Usage:
#   hub_delete_repo <repo_name>
#
function hub_delete_repo() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_delete_repo
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "No repository name provided."
        return 1
    fi

    local repo_name="$1"

    if gh repo delete "$repo_name" --confirm; then
        log success "Repository '$repo_name' deleted."
    else
        log error "Failed to delete repository '$repo_name'."
        return 1
    fi
}

# Function: hub_create_branch
#
# Creates a new branch with the specified name.
#
# Usage:
#   hub_create_branch <branch_name>
#
function hub_create_branch() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_create_branch
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "No branch name provided."
        return 1
    fi

    local branch_name="$1"

    if git branch "$branch_name" && git checkout "$branch_name"; then
        log success "Branch '$branch_name' created and checked out."
    else
        log error "Failed to create branch '$branch_name'."
        return 1
    fi
}

# Function: hub_delete_branch
#
# Deletes the specified branch.
#
# Usage:
#   hub_delete_branch <branch_name>
#
function hub_delete_branch() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_delete_branch
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "No branch name provided."
        return 1
    fi

    local branch_name="$1"

    if git branch -d "$branch_name"; then
        log success "Branch '$branch_name' deleted locally."
    else
        log error "Failed to delete branch '$branch_name' locally."
        return 1
    fi

    if git push origin --delete "$branch_name"; then
        log success "Branch '$branch_name' deleted from remote."
    else
        log warning "Branch '$branch_name' could not be deleted from remote."
    fi
}

# Function: hub_list_branches
#
# Lists all branches in the current repository.
#
# Usage:
#   hub_list_branches
#
function hub_list_branches() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_list_branches
        return 0
    fi

    git branch -a
}

# Function: hub_push
#
# Pushes the specified branch to the remote repository.
#
# Usage:
#   hub_push [remote] [branch_name]
#
function hub_push() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_push
        return 0
    fi

    local remote="${1:-origin}"
    local branch="${2:-$(git rev-parse --abbrev-ref HEAD)}"

    if git push "$remote" "$branch"; then
        log success "Branch '$branch' pushed to '$remote'."
    else
        log error "Failed to push branch '$branch' to '$remote'."
        return 1
    fi
}

# Function: hub_pull
#
# Pulls the specified branch from the remote repository.
#
# Usage:
#   hub_pull [remote] [branch_name]
#
function hub_pull() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_pull
        return 0
    fi

    local remote="${1:-origin}"
    local branch="${2:-$(git rev-parse --abbrev-ref HEAD)}"

    if git pull "$remote" "$branch"; then
        log success "Branch '$branch' pulled from '$remote'."
    else
        log error "Failed to pull branch '$branch' from '$remote'."
        return 1
    fi
}

# Function: hub_add_hook
#
# Adds a webhook to the specified GitHub repository.
#
# Usage:
#   hub_add_hook <repo_name> <hook_url> <event>
#
function hub_add_hook() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_add_hook
        return 0
    fi

    if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
        log error "Usage: hub_add_hook <repo_name> <hook_url> <event>"
        return 1
    fi

    local repo_name="$1"
    local hook_url="$2"
    local event="$3"

    if gh api -X POST "/repos/$repo_name/hooks" -f "config.url=$hook_url" -f "events[]=$event" -f "config.content_type=json"; then
        log success "Webhook added to repository '$repo_name'."
    else
        log error "Failed to add webhook to repository '$repo_name'."
        return 1
    fi
}

# Function: hub_remove_hook
#
# Removes a webhook from the specified GitHub repository.
#
# Usage:
#   hub_remove_hook <repo_name> <hook_id>
#
function hub_remove_hook() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_remove_hook
        return 0
    fi

    if [[ -z "$1" || -z "$2" ]]; then
        log error "Usage: hub_remove_hook <repo_name> <hook_id>"
        return 1
    fi

    local repo_name="$1"
    local hook_id="$2"

    if gh api -X DELETE "/repos/$repo_name/hooks/$hook_id"; then
        log success "Webhook '$hook_id' removed from repository '$repo_name'."
    else
        log error "Failed to remove webhook '$hook_id' from repository '$repo_name'."
        return 1
    fi
}

# Function: hub_list_hooks
#
# Lists all webhooks in the specified GitHub repository.
#
# Usage:
#   hub_list_hooks <repo_name>
#
function hub_list_hooks() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_list_hooks
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: hub_list_hooks <repo_name>"
        return 1
    fi

    local repo_name="$1"

    if gh api "/repos/$repo_name/hooks"; then
        log success "Listed webhooks for repository '$repo_name'."
    else
        log error "Failed to list webhooks for repository '$repo_name'."
        return 1
    fi
}

# Function: hub_cherry_pick
#
# Cherry-picks the specified commit.
#
# Usage:
#   hub_cherry_pick <commit_hash>
#
function hub_cherry_pick() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_cherry_pick
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: hub_cherry_pick <commit_hash>"
        return 1
    fi

    local commit_hash="$1"

    if git cherry-pick "$commit_hash"; then
        log success "Commit '$commit_hash' cherry-picked."
    else
        log error "Failed to cherry-pick commit '$commit_hash'."
        return 1
    fi
}

# Function: hub_merge
#
# Merges the specified source branch into the target branch.
#
# Usage:
#   hub_merge <source_branch> <target_branch>
#
function hub_merge() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_merge
        return 0
    fi

    if [[ -z "$1" || -z "$2" ]]; then
        log error "Usage: hub_merge <source_branch> <target_branch>"
        return 1
    fi

    local source_branch="$1"
    local target_branch="$2"

    if git checkout "$target_branch" && git merge "$source_branch"; then
        log success "Branch '$source_branch' merged into '$target_branch'."
    else
        log error "Failed to merge branch '$source_branch' into '$target_branch'."
        return 1
    fi
}

# Function: hub_rebase
#
# Rebases the current branch onto the specified base branch.
#
# Usage:
#   hub_rebase <base_branch>
#
function hub_rebase() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_rebase
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: hub_rebase <base_branch>"
        return 1
    fi

    local base_branch="$1"

    if git rebase "$base_branch"; then
        log success "Current branch rebased onto '$base_branch'."
    else
        log error "Failed to rebase current branch onto '$base_branch'."
        return 1
    fi
}

# Function: hub_create_pr
#
# Creates a new pull request.
#
# Usage:
#   hub_create_pr <title> <body> [base] [head]
#
function hub_create_pr() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_create_pr
        return 0
    fi

    if [[ -z "$1" || -z "$2" ]]; then
        log error "Usage: hub_create_pr <title> <body> [base] [head]"
        return 1
    fi

    local title="$1"
    local body="$2"
    local base="${3:-main}"
    local head="${4:-$(git rev-parse --abbrev-ref HEAD)}"

    if gh pr create --title "$title" --body "$body" --base "$base" --head "$head"; then
        log success "Pull request created."
    else
        log error "Failed to create pull request."
        return 1
    fi
}

# Function: hub_list_prs
#
# Lists all pull requests in the specified GitHub repository.
#
# Usage:
#   hub_list_prs <repo_name>
#
function hub_list_prs() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_list_prs
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: hub_list_prs <repo_name>"
        return 1
    fi

    local repo_name="$1"

    if gh pr list --repo "$repo_name"; then
        log success "Listed pull requests for repository '$repo_name'."
    else
        log error "Failed to list pull requests for repository '$repo_name'."
        return 1
    fi
}

# Function: hub_create_release
#
# Creates a new release.
#
# Usage:
#   hub_create_release <tag> <title> <body>
#
function hub_create_release() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_create_release
        return 0
    fi

    if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
        log error "Usage: hub_create_release <tag> <title> <body>"
        return 1
    fi

    local tag="$1"
    local title="$2"
    local body="$3"

    if gh release create "$tag" --title "$title" --notes "$body"; then
        log success "Release '$tag' created."
    else
        log error "Failed to create release '$tag'."
        return 1
    fi
}

# Function: hub_list_releases
#
# Lists all releases in the specified GitHub repository.
#
# Usage:
#   hub_list_releases <repo_name>
#
function hub_list_releases() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_list_releases
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: hub_list_releases <repo_name>"
        return 1
    fi

    local repo_name="$1"

    if gh release list --repo "$repo_name"; then
        log success "Listed releases for repository '$repo_name'."
    else
        log error "Failed to list releases for repository '$repo_name'."
        return 1
    fi
}

# Function: hub_setup_precommit
#
# Sets up a basic pre-commit configuration.
#
# Usage:
#   hub_setup_precommit [hook_id] [rev]
#
function hub_setup_precommit() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_setup_precommit
        return 0
    fi

    local hook_id="${1:-trailing-whitespace}"
    local rev="${2:-v3.4.0}"

    if ! command -v pre-commit >/dev/null 2>&1; then
        log warning "pre-commit is not installed. Installing..."
        if ! pip install pre-commit; then
            log error "Failed to install pre-commit."
            return 1
        fi
    fi

    if [[ ! -f ".pre-commit-config.yaml" ]]; then
        cat <<EOF > .pre-commit-config.yaml
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: $rev
    hooks:
    -   id: $hook_id
EOF
        log success "Created .pre-commit-config.yaml with hook '$hook_id' at revision '$rev'."
    else
        log warning ".pre-commit-config.yaml already exists."
    fi

    if pre-commit install; then
        log success "Pre-commit hooks installed."
    else
        log error "Failed to install pre-commit hooks."
        return 1
    fi
}

# Function: hub_edit_precommit
#
# Opens the pre-commit configuration file in the default editor.
#
# Usage:
#   hub_edit_precommit
#
function hub_edit_precommit() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help hub_edit_precommit
        return 0
    fi

    if [[ ! -f ".pre-commit-config.yaml" ]]; then
        hub_setup_precommit
    fi

    local editor="${EDITOR:-nano}"

    if command -v "$editor" >/dev/null 2>&1; then
        "$editor" .pre-commit-config.yaml
        log success "Opened .pre-commit-config.yaml in '$editor'."
    else
        log error "Editor '$editor' not found. Please set your default editor using the EDITOR environment variable."
        return 1
    fi
}
