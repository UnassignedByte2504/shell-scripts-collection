#!/bin/bash
# DESCRIPTION:
# This file, `docker_helpers.sh`, contains a collection of utility functions for managing Docker containers and images.
# It includes functions for building images, running containers, managing volumes and networks, and more.
# These functions are designed to simplify common Docker tasks and are intended to be sourced in your `.zshrc` or `.bashrc` file.

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

# Function: display_docker_help
#
# Displays the usage information for various Docker utility functions.
#
# Parameters:
#   - func: The name of the utility function to display help for.
#
# Usage:
#   display_docker_help [function_name]
#
# Example:
#   display_docker_help docker_run
#
function display_docker_help() {
    local func="$1"
    case "$func" in
        docker_build)
            cat << EOF
    Usage: docker_build [options] <image_name> [context]
    Builds a Docker image with the specified name from the provided context (default is current directory).
    Options:
      -f, --file <dockerfile>    Specify the Dockerfile to use (default is 'Dockerfile').
    Example:
      docker_build -f ./Dockerfile.custom myimage .
EOF
            ;;
        docker_run)
            cat << EOF
    Usage: docker_run [options] <image_name> <container_name>
    Runs a Docker container from the specified image.
    Options:
      -p, --port <host_port:container_port>    Map a port.
      -v, --volume <host_dir:container_dir>    Mount a volume.
      -d, --detach                             Run container in background.
      -e, --env <KEY=VALUE>                    Set environment variables.
      --network <network_name>                 Connect to a network.
    Example:
      docker_run -d -p 8080:80 myimage mycontainer
EOF
            ;;
        docker_stop)
            cat << EOF
    Usage: docker_stop <container_name>
    Stops the specified Docker container.
EOF
            ;;
        docker_remove)
            cat << EOF
    Usage: docker_remove <container_name>
    Removes the specified Docker container.
EOF
            ;;
        docker_rmi)
            cat << EOF
    Usage: docker_rmi <image_name>
    Removes the specified Docker image.
EOF
            ;;
        docker_ps)
            cat << EOF
    Usage: docker_ps [options]
    Lists Docker containers.
    Options:
      -a, --all    Show all containers (default shows just running).
    Example:
      docker_ps -a
EOF
            ;;
        docker_images)
            cat << EOF
    Usage: docker_images
    Lists all Docker images.
EOF
            ;;
        docker_exec)
            cat << EOF
    Usage: docker_exec <container_name> <command> [args...]
    Executes a command inside a running Docker container.
    Example:
      docker_exec mycontainer ls -l /app
EOF
            ;;
        docker_logs)
            cat << EOF
    Usage: docker_logs [options] <container_name>
    Displays the logs of the specified Docker container.
    Options:
      -f, --follow    Follow log output.
      --tail <lines>  Show only the last N lines.
    Example:
      docker_logs -f --tail 100 mycontainer
EOF
            ;;
        docker_clean)
            cat << EOF
    Usage: docker_clean [options]
    Removes unused Docker resources.
    Options:
      -a, --all    Remove all unused images not just dangling ones.
    Example:
      docker_clean -a
EOF
            ;;
        docker_prune)
            cat << EOF
    Usage: docker_prune
    Removes all unused containers, networks, images (both dangling and unreferenced).
EOF
            ;;
        docker_network_create)
            cat << EOF
    Usage: docker_network_create <network_name>
    Creates a Docker network.
EOF
            ;;
        docker_network_remove)
            cat << EOF
    Usage: docker_network_remove <network_name>
    Removes a Docker network.
EOF
            ;;
        docker_volume_create)
            cat << EOF
    Usage: docker_volume_create <volume_name>
    Creates a Docker volume.
EOF
            ;;
        docker_volume_remove)
            cat << EOF
    Usage: docker_volume_remove <volume_name>
    Removes a Docker volume.
EOF
            ;;
        docker_compose_up)
            cat << EOF
    Usage: docker_compose_up [options]
    Starts services defined in docker-compose.yml.
    Options:
      -d, --detach    Run containers in the background.
    Example:
      docker_compose_up -d
EOF
            ;;
        docker_compose_down)
            cat << EOF
    Usage: docker_compose_down
    Stops and removes containers defined in docker-compose.yml.
EOF
            ;;
        *)
            cat << EOF
    Available functions:
      docker_build           - Builds a Docker image.
      docker_run             - Runs a Docker container.
      docker_stop            - Stops a Docker container.
      docker_remove          - Removes a Docker container.
      docker_rmi             - Removes a Docker image.
      docker_ps              - Lists Docker containers.
      docker_images          - Lists Docker images.
      docker_exec            - Executes a command in a container.
      docker_logs            - Displays container logs.
      docker_clean           - Removes unused Docker resources.
      docker_prune           - Prunes all unused Docker resources.
      docker_network_create  - Creates a Docker network.
      docker_network_remove  - Removes a Docker network.
      docker_volume_create   - Creates a Docker volume.
      docker_volume_remove   - Removes a Docker volume.
      docker_compose_up      - Starts services with Docker Compose.
      docker_compose_down    - Stops services with Docker Compose.
    Use 'display_docker_help <function_name>' to see detailed usage of a specific function.
EOF
            ;;
    esac
}

# Function: docker_build
#
# Builds a Docker image from the specified Dockerfile.
#
# Usage:
#   docker_build [options] <image_name> [context]
#
function docker_build() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_build
        return 0
    fi

    local dockerfile="Dockerfile"
    local options=()

    while [[ "$1" =~ ^- ]]; do
        case "$1" in
            -f|--file)
                shift
                dockerfile="$1"
                ;;
            *)
                options+=("$1")
                ;;
        esac
        shift
    done

    if [[ -z "$1" ]]; then
        log error "Usage: docker_build [options] <image_name> [context]"
        return 1
    fi

    local image_name="$1"
    local context="${2:-.}"

    docker build -f "$dockerfile" "${options[@]}" -t "$image_name" "$context" \
        && log success "Docker image '$image_name' built successfully." \
        || log error "Failed to build Docker image '$image_name'."
}

# Function: docker_run
#
# Runs a Docker container from the specified image.
#
# Usage:
#   docker_run [options] <image_name> <container_name>
#
function docker_run() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_run
        return 0
    fi

    local options=()

    while [[ "$1" =~ ^- ]]; do
        case "$1" in
            -p|--port)
                shift
                options+=("-p" "$1")
                ;;
            -v|--volume)
                shift
                options+=("-v" "$1")
                ;;
            -d|--detach)
                options+=("-d")
                ;;
            -e|--env)
                shift
                options+=("-e" "$1")
                ;;
            --network)
                shift
                options+=("--network" "$1")
                ;;
            *)
                log warning "Unknown option: $1"
                ;;
        esac
        shift
    done

    if [[ -z "$1" || -z "$2" ]]; then
        log error "Usage: docker_run [options] <image_name> <container_name>"
        return 1
    fi

    local image_name="$1"
    local container_name="$2"
    shift 2

    docker run --name "$container_name" "${options[@]}" "$image_name" "$@" \
        && log success "Docker container '$container_name' started successfully." \
        || log error "Failed to start Docker container '$container_name'."
}

# Function: docker_stop
#
# Stops the specified Docker container.
#
# Usage:
#   docker_stop <container_name>
#
function docker_stop() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_stop
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: docker_stop <container_name>"
        return 1
    fi

    local container_name="$1"

    docker stop "$container_name" \
        && log success "Docker container '$container_name' stopped successfully." \
        || log error "Failed to stop Docker container '$container_name'."
}

# Function: docker_remove
#
# Removes the specified Docker container.
#
# Usage:
#   docker_remove <container_name>
#
function docker_remove() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_remove
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: docker_remove <container_name>"
        return 1
    fi

    local container_name="$1"

    docker rm "$container_name" \
        && log success "Docker container '$container_name' removed successfully." \
        || log error "Failed to remove Docker container '$container_name'."
}

# Function: docker_rmi
#
# Removes the specified Docker image.
#
# Usage:
#   docker_rmi <image_name>
#
function docker_rmi() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_rmi
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: docker_rmi <image_name>"
        return 1
    fi

    local image_name="$1"

    docker rmi "$image_name" \
        && log success "Docker image '$image_name' removed successfully." \
        || log error "Failed to remove Docker image '$image_name'."
}

# Function: docker_ps
#
# Lists Docker containers.
#
# Usage:
#   docker_ps [options]
#
function docker_ps() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_ps
        return 0
    fi

    docker ps "$@" \
        && log success "Listed Docker containers." \
        || log error "Failed to list Docker containers."
}

# Function: docker_images
#
# Lists all Docker images.
#
# Usage:
#   docker_images
#
function docker_images() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_images
        return 0
    fi

    docker images \
        && log success "Listed all Docker images." \
        || log error "Failed to list Docker images."
}

# Function: docker_exec
#
# Executes a command inside a running Docker container.
#
# Usage:
#   docker_exec <container_name> <command> [args...]
#
function docker_exec() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_exec
        return 0
    fi

    if [[ -z "$1" || -z "$2" ]]; then
        log error "Usage: docker_exec <container_name> <command> [args...]"
        return 1
    fi

    local container_name="$1"
    shift

    docker exec "$container_name" "$@" \
        && log success "Executed command in container '$container_name'." \
        || log error "Failed to execute command in container '$container_name'."
}

# Function: docker_logs
#
# Displays the logs of the specified Docker container.
#
# Usage:
#   docker_logs [options] <container_name>
#
function docker_logs() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_logs
        return 0
    fi

    local options=()

    while [[ "$1" =~ ^- ]]; do
        options+=("$1")
        shift
    done

    if [[ -z "$1" ]]; then
        log error "Usage: docker_logs [options] <container_name>"
        return 1
    fi

    local container_name="$1"

    docker logs "${options[@]}" "$container_name" \
        && log success "Displayed logs for container '$container_name'." \
        || log error "Failed to display logs for container '$container_name'."
}

# Function: docker_clean
#
# Removes unused Docker resources.
#
# Usage:
#   docker_clean [options]
#
function docker_clean() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_clean
        return 0
    fi

    docker image prune "$@" -f \
        && log success "Removed unused Docker images." \
        || log error "Failed to remove unused Docker images."

    docker container prune -f \
        && log success "Removed stopped Docker containers." \
        || log error "Failed to remove stopped Docker containers."

    docker volume prune -f \
        && log success "Removed unused Docker volumes." \
        || log error "Failed to remove unused Docker volumes."

    docker network prune -f \
        && log success "Removed unused Docker networks." \
        || log error "Failed to remove unused Docker networks."
}

# Function: docker_prune
#
# Removes all unused containers, networks, images (both dangling and unreferenced).
#
# Usage:
#   docker_prune
#
function docker_prune() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_prune
        return 0
    fi

    docker system prune -a -f \
        && log success "Pruned all unused Docker resources." \
        || log error "Failed to prune Docker resources."
}

# Function: docker_network_create
#
# Creates a Docker network.
#
# Usage:
#   docker_network_create <network_name>
#
function docker_network_create() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_network_create
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: docker_network_create <network_name>"
        return 1
    fi

    local network_name="$1"

    docker network create "$network_name" \
        && log success "Docker network '$network_name' created." \
        || log error "Failed to create Docker network '$network_name'."
}

# Function: docker_network_remove
#
# Removes a Docker network.
#
# Usage:
#   docker_network_remove <network_name>
#
function docker_network_remove() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_network_remove
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: docker_network_remove <network_name>"
        return 1
    fi

    local network_name="$1"

    docker network rm "$network_name" \
        && log success "Docker network '$network_name' removed." \
        || log error "Failed to remove Docker network '$network_name'."
}

# Function: docker_volume_create
#
# Creates a Docker volume.
#
# Usage:
#   docker_volume_create <volume_name>
#
function docker_volume_create() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_volume_create
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: docker_volume_create <volume_name>"
        return 1
    fi

    local volume_name="$1"

    docker volume create "$volume_name" \
        && log success "Docker volume '$volume_name' created." \
        || log error "Failed to create Docker volume '$volume_name'."
}

# Function: docker_volume_remove
#
# Removes a Docker volume.
#
# Usage:
#   docker_volume_remove <volume_name>
#
function docker_volume_remove() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_volume_remove
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: docker_volume_remove <volume_name>"
        return 1
    fi

    local volume_name="$1"

    docker volume rm "$volume_name" \
        && log success "Docker volume '$volume_name' removed." \
        || log error "Failed to remove Docker volume '$volume_name'."
}

# Function: docker_compose_up
#
# Starts services defined in docker-compose.yml.
#
# Usage:
#   docker_compose_up [options]
#
function docker_compose_up() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_compose_up
        return 0
    fi

    docker-compose up "$@" \
        && log success "Docker Compose services started." \
        || log error "Failed to start Docker Compose services."
}

# Function: docker_compose_down
#
# Stops and removes containers defined in docker-compose.yml.
#
# Usage:
#   docker_compose_down
#
function docker_compose_down() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_compose_down
        return 0
    fi

    docker-compose down \
        && log success "Docker Compose services stopped." \
        || log error "Failed to stop Docker Compose services."
}
