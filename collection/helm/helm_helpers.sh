#!/bin/bash
# DESCRIPTION:
# This file, `helm_helpers.sh`, contains a comprehensive collection of utility functions for managing Helm charts and releases.
# It includes functions for installing, upgrading, listing, and removing releases, managing repositories, inspecting charts, and more.
# These functions are designed to simplify common Helm tasks and are intended to be sourced in your `.zshrc` or `.bashrc` file.

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

# Function: display_helm_help
#
# Displays the usage information for various Helm utility functions.
#
# Parameters:
#   - func: The name of the utility function to display help for.
#
# Usage:
#   display_helm_help [function_name]
#
# Example:
#   display_helm_help helm_install
#
function display_helm_help() {
    local func="$1"
    case "$func" in
        helm_install)
            cat << EOF
    Usage: helm_install [options] <release_name> <chart> [-- [values_files...]]
    Installs a Helm chart with the specified release name.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
      -f, --values <file>            Specify values file(s).
    Example:
      helm_install my-release stable/nginx-ingress -f values.yaml
EOF
            ;;
        helm_upgrade)
            cat << EOF
    Usage: helm_upgrade [options] <release_name> <chart> [-- [values_files...]]
    Upgrades a Helm release with the specified chart.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
      -f, --values <file>            Specify values file(s).
      --install                      Install if release does not exist.
    Example:
      helm_upgrade my-release stable/nginx-ingress -f values.yaml --install
EOF
            ;;
        helm_uninstall)
            cat << EOF
    Usage: helm_uninstall [options] <release_name>
    Uninstalls a Helm release.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
    Example:
      helm_uninstall my-release -n default
EOF
            ;;
        helm_list)
            cat << EOF
    Usage: helm_list [options]
    Lists all Helm releases.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is all namespaces).
      -a, --all                      Show all releases (including deleted).
    Example:
      helm_list -n default
EOF
            ;;
        helm_repo_add)
            cat << EOF
    Usage: helm_repo_add <repo_name> <repo_url>
    Adds a Helm repository.
    Example:
      helm_repo_add stable https://charts.helm.sh/stable
EOF
            ;;
        helm_repo_update)
            cat << EOF
    Usage: helm_repo_update
    Updates information of available charts locally from chart repositories.
EOF
            ;;
        helm_search_repo)
            cat << EOF
    Usage: helm_search_repo <keyword>
    Searches for charts in Helm repositories.
    Example:
      helm_search_repo nginx
EOF
            ;;
        helm_show_values)
            cat << EOF
    Usage: helm_show_values <chart>
    Shows the values of a Helm chart.
    Example:
      helm_show_values stable/nginx-ingress
EOF
            ;;
        helm_get_values)
            cat << EOF
    Usage: helm_get_values [options] <release_name>
    Shows the values for a deployed release.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
      -a, --all                      Show all computed values.
    Example:
      helm_get_values my-release -n default
EOF
            ;;
        helm_history)
            cat << EOF
    Usage: helm_history [options] <release_name>
    Shows the history of a Helm release.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
    Example:
      helm_history my-release
EOF
            ;;
        helm_rollback)
            cat << EOF
    Usage: helm_rollback [options] <release_name> <revision>
    Rolls back a release to a previous revision.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
    Example:
      helm_rollback my-release 2
EOF
            ;;
        helm_template)
            cat << EOF
    Usage: helm_template [options] <release_name> <chart> [-- [values_files...]]
    Renders chart templates locally and displays the output.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
      -f, --values <file>            Specify values file(s).
    Example:
      helm_template my-release stable/nginx-ingress -f values.yaml
EOF
            ;;
        helm_repo_list)
            cat << EOF
    Usage: helm_repo_list
    Lists all Helm repositories.
EOF
            ;;
        helm_plugin_list)
            cat << EOF
    Usage: helm_plugin_list
    Lists installed Helm plugins.
EOF
            ;;
        helm_install_plugin)
            cat << EOF
    Usage: helm_install_plugin <plugin_url>
    Installs a Helm plugin from the specified URL.
    Example:
      helm_install_plugin https://github.com/databus23/helm-diff
EOF
            ;;
        helm_diff)
            cat << EOF
    Usage: helm_diff [options] <release_name> <chart> [-- [values_files...]]
    Shows a diff between the current release and the proposed upgrade.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
      -f, --values <file>            Specify values file(s).
    Note:
      Requires 'helm-diff' plugin to be installed.
    Example:
      helm_diff my-release stable/nginx-ingress -f values.yaml
EOF
            ;;
        *)
            cat << EOF
    Available functions:
      helm_install         - Installs a Helm chart.
      helm_upgrade         - Upgrades a Helm release.
      helm_uninstall       - Uninstalls a Helm release.
      helm_list            - Lists Helm releases.
      helm_repo_add        - Adds a Helm repository.
      helm_repo_update     - Updates Helm repositories.
      helm_repo_list       - Lists Helm repositories.
      helm_search_repo     - Searches for charts in repositories.
      helm_show_values     - Shows the default values of a chart.
      helm_get_values      - Gets the values of a deployed release.
      helm_history         - Shows the history of a release.
      helm_rollback        - Rolls back a release to a previous revision.
      helm_template        - Renders chart templates locally.
      helm_plugin_list     - Lists installed Helm plugins.
      helm_install_plugin  - Installs a Helm plugin.
      helm_diff            - Shows diff between releases (requires 'helm-diff' plugin).
    Use 'display_helm_help <function_name>' to see detailed usage of a specific function.
EOF
            ;;
    esac
}

# Function: helm_install
#
# Installs a Helm chart with the specified release name.
#
# Usage:
#   helm_install [options] <release_name> <chart> [-- [values_files...]]
#
function helm_install() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_helm_help helm_install
        return 0
    fi

    local options=()
    while [[ "$1" =~ ^- ]]; do
        case "$1" in
            -n|--namespace)
                options+=("$1" "$2")
                shift 2
                ;;
            -f|--values)
                options+=("$1" "$2")
                shift 2
                ;;
            *)
                log warning "Unknown option: $1"
                shift
                ;;
        esac
    done

    if [[ -z "$1" || -z "$2" ]]; then
        log error "Usage: helm_install [options] <release_name> <chart> [-- [values_files...]]"
        return 1
    fi

    local release_name="$1"
    local chart="$2"
    shift 2

    helm install "$release_name" "$chart" "${options[@]}" "$@" \
        && log success "Installed release '$release_name' using chart '$chart'." \
        || log error "Failed to install release '$release_name'."
}

# Function: helm_upgrade
#
# Upgrades a Helm release with the specified chart.
#
# Usage:
#   helm_upgrade [options] <release_name> <chart> [-- [values_files...]]
#
function helm_upgrade() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_helm_help helm_upgrade
        return 0
    fi

    local options=()
    while [[ "$1" =~ ^- ]]; do
        case "$1" in
            -n|--namespace|--install)
                options+=("$1" "$2")
                shift 2
                ;;
            -f|--values)
                options+=("$1" "$2")
                shift 2
                ;;
            *)
                options+=("$1")
                shift
                ;;
        esac
    done

    if [[ -z "$1" || -z "$2" ]]; then
        log error "Usage: helm_upgrade [options] <release_name> <chart> [-- [values_files...]]"
        return 1
    fi

    local release_name="$1"
    local chart="$2"
    shift 2

    helm upgrade "$release_name" "$chart" "${options[@]}" "$@" \
        && log success "Upgraded release '$release_name' with chart '$chart'." \
        || log error "Failed to upgrade release '$release_name'."
}

# Function: helm_uninstall
#
# Uninstalls a Helm release.
#
# Usage:
#   helm_uninstall [options] <release_name>
#
function helm_uninstall() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_helm_help helm_uninstall
        return 0
    fi

    local options=()
    while [[ "$1" =~ ^- ]]; do
        case "$1" in
            -n|--namespace)
                options+=("$1" "$2")
                shift 2
                ;;
            *)
                log warning "Unknown option: $1"
                shift
                ;;
        esac
    done

    if [[ -z "$1" ]]; then
        log error "Usage: helm_uninstall [options] <release_name>"
        return 1
    fi

    local release_name="$1"

    helm uninstall "${options[@]}" "$release_name" \
        && log success "Uninstalled release '$release_name'." \
        || log error "Failed to uninstall release '$release_name'."
}

# Function: helm_list
#
# Lists all Helm releases.
#
# Usage:
#   helm_list [options]
#
function helm_list() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_helm_help helm_list
        return 0
    fi

    helm list "$@" \
        && log success "Listed Helm releases." \
        || log error "Failed to list Helm releases."
}

# Function: helm_repo_add
#
# Adds a Helm repository.
#
# Usage:
#   helm_repo_add <repo_name> <repo_url>
#
function helm_repo_add() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_helm_help helm_repo_add
        return 0
    fi

    if [[ -z "$1" || -z "$2" ]]; then
        log error "Usage: helm_repo_add <repo_name> <repo_url>"
        return 1
    fi

    local repo_name="$1"
    local repo_url="$2"

    helm repo add "$repo_name" "$repo_url" \
        && log success "Added repository '$repo_name' with URL '$repo_url'." \
        || log error "Failed to add repository '$repo_name'."
}

# Function: helm_repo_update
#
# Updates information of available charts locally from chart repositories.
#
# Usage:
#   helm_repo_update
#
function helm_repo_update() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_helm_help helm_repo_update
        return 0
    fi

    helm repo update \
        && log success "Updated Helm repositories." \
        || log error "Failed to update Helm repositories."
}

# Function: helm_repo_list
#
# Lists all Helm repositories.
#
# Usage:
#   helm_repo_list
#
function helm_repo_list() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_helm_help helm_repo_list
        return 0
    fi

    helm repo list \
        && log success "Listed Helm repositories." \
        || log error "Failed to list Helm repositories."
}

# Function: helm_search_repo
#
# Searches for charts in Helm repositories.
#
# Usage:
#   helm_search_repo <keyword>
#
function helm_search_repo() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_helm_help helm_search_repo
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: helm_search_repo <keyword>"
        return 1
    fi

    local keyword="$1"

    helm search repo "$keyword" \
        && log success "Searched for charts with keyword '$keyword'." \
        || log error "Failed to search for charts."
}

# Function: helm_show_values
#
# Shows the default values of a Helm chart.
#
# Usage:
#   helm_show_values <chart>
#
function helm_show_values() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_helm_help helm_show_values
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: helm_show_values <chart>"
        return 1
    fi

    local chart="$1"

    helm show values "$chart" \
        && log success "Displayed values for chart '$chart'." \
        || log error "Failed to display values for chart '$chart'."
}

# Function: helm_get_values
#
# Shows the values for a deployed release.
#
# Usage:
#   helm_get_values [options] <release_name>
#
function helm_get_values() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_helm_help helm_get_values
        return 0
    fi

    local options=()
    while [[ "$1" =~ ^- ]]; do
        options+=("$1" "$2")
        shift 2
    done

    if [[ -z "$1" ]]; then
        log error "Usage: helm_get_values [options] <release_name>"
        return 1
    fi

    local release_name="$1"

    helm get values "${options[@]}" "$release_name" \
        && log success "Retrieved values for release '$release_name'." \
        || log error "Failed to retrieve values for release '$release_name'."
}

# Function: helm_history
#
# Shows the history of a Helm release.
#
# Usage:
#   helm_history [options] <release_name>
#
function helm_history() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_helm_help helm_history
        return 0
    fi

    local options=()
    while [[ "$1" =~ ^- ]]; do
        options+=("$1" "$2")
        shift 2
    done

    if [[ -z "$1" ]]; then
        log error "Usage: helm_history [options] <release_name>"
        return 1
    fi

    local release_name="$1"

    helm history "${options[@]}" "$release_name" \
        && log success "Displayed history for release '$release_name'." \
        || log error "Failed to display history for release '$release_name'."
}

# Function: helm_rollback
#
# Rolls back a release to a previous revision.
#
# Usage:
#   helm_rollback [options] <release_name> <revision>
#
function helm_rollback() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_helm_help helm_rollback
        return 0
    fi

    local options=()
    while [[ "$1" =~ ^- ]]; do
        options+=("$1" "$2")
        shift 2
    done

    if [[ -z "$1" || -z "$2" ]]; then
        log error "Usage: helm_rollback [options] <release_name> <revision>"
        return 1
    fi

    local release_name="$1"
    local revision="$2"

    helm rollback "${options[@]}" "$release_name" "$revision" \
        && log success "Rolled back release '$release_name' to revision '$revision'." \
        || log error "Failed to roll back release '$release_name'."
}

# Function: helm_template
#
# Renders chart templates locally and displays the output.
#
# Usage:
#   helm_template [options] <release_name> <chart> [-- [values_files...]]
#
function helm_template() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_helm_help helm_template
        return 0
    fi

    local options=()
    while [[ "$1" =~ ^- ]]; do
        case "$1" in
            -n|--namespace)
                options+=("$1" "$2")
                shift 2
                ;;
            -f|--values)
                options+=("$1" "$2")
                shift 2
                ;;
            *)
                options+=("$1")
                shift
                ;;
        esac
    done

    if [[ -z "$1" || -z "$2" ]]; then
        log error "Usage: helm_template [options] <release_name> <chart> [-- [values_files...]]"
        return 1
    fi

    local release_name="$1"
    local chart="$2"
    shift 2

    helm template "$release_name" "$chart" "${options[@]}" "$@" \
        && log success "Rendered templates for chart '$chart'." \
        || log error "Failed to render templates for chart '$chart'."
}

# Function: helm_plugin_list
#
# Lists installed Helm plugins.
#
# Usage:
#   helm_plugin_list
#
function helm_plugin_list() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_helm_help helm_plugin_list
        return 0
    fi

    helm plugin list \
        && log success "Listed Helm plugins." \
        || log error "Failed to list Helm plugins."
}

# Function: helm_install_plugin
#
# Installs a Helm plugin from the specified URL.
#
# Usage:
#   helm_install_plugin <plugin_url>
#
function helm_install_plugin() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_helm_help helm_install_plugin
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: helm_install_plugin <plugin_url>"
        return 1
    fi

    local plugin_url="$1"

    helm plugin install "$plugin_url" \
        && log success "Installed Helm plugin from '$plugin_url'." \
        || log error "Failed to install Helm plugin."
}

# Function: helm_diff
#
# Shows a diff between the current release and the proposed upgrade.
#
# Usage:
#   helm_diff [options] <release_name> <chart> [-- [values_files...]]
#
function helm_diff() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_helm_help helm_diff
        return 0
    fi

    if ! helm plugin list | grep -q 'diff'; then
        log error "The 'helm-diff' plugin is not installed. Install it using 'helm_install_plugin https://github.com/databus23/helm-diff'."
        return 1
    fi

    local options=()
    while [[ "$1" =~ ^- ]]; do
        case "$1" in
            -n|--namespace|--install)
                options+=("$1" "$2")
                shift 2
                ;;
            -f|--values)
                options+=("$1" "$2")
                shift 2
                ;;
            *)
                options+=("$1")
                shift
                ;;
        esac
    done

    if [[ -z "$1" || -z "$2" ]]; then
        log error "Usage: helm_diff [options] <release_name> <chart> [-- [values_files...]]"
        return 1
    fi

    local release_name="$1"
    local chart="$2"
    shift 2

    helm diff upgrade "$release_name" "$chart" "${options[@]}" "$@" \
        && log success "Displayed diff for release '$release_name'." \
        || log error "Failed to display diff for release '$release_name'."
}
