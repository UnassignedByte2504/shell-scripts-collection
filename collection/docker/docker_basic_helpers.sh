#!/bin/bash

# DESCRIPTION: This file, `docker_helpers.sh`, contains a collection of utility functions for managing Docker containers and images.
# These functions are designed to simplify common Docker tasks and provide useful features.
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

# Function: display_docker_help
#
# Displays the usage information for various Docker utility functions.
#
# Parameters:
#   - func: The name of the utility function to display help for.
#
# Usage:
#   display_docker_help <func>
#
# Example:
#   display_docker_help docker_run
#
#   This will display the usage information for the 'docker_run' utility function.
#
function display_docker_help() {
    local func=$1
    shift
    case "$func" in
        docker_build)
            echo "Usage: docker_build <dockerfile_path> <image_name>"
            echo "Builds a Docker image from the specified Dockerfile."
            ;;
        docker_run)
            echo "Usage: docker_run <image_name> <container_name> [options]"
            echo "Runs a Docker container from the specified image."
            ;;
        docker_stop)
            echo "Usage: docker_stop <container_name>"
            echo "Stops the specified Docker container."
            ;;
        docker_remove)
            echo "Usage: docker_remove <container_name>"
            echo "Removes the specified Docker container."
            ;;
        docker_rmi)
            echo "Usage: docker_rmi <image_name>"
            echo "Removes the specified Docker image."
            ;;
        docker_ps)
            echo "Usage: docker_ps"
            echo "Lists all running Docker containers."
            ;;
        docker_images)
            echo "Usage: docker_images"
            echo "Lists all Docker images."
            ;;
        docker_exec)
            echo "Usage: docker_exec <container_name> <command>"
            echo "Executes a command inside a running Docker container."
            ;;
        docker_logs)
            echo "Usage: docker_logs <container_name>"
            echo "Displays the logs of the specified Docker container."
            ;;
        docker_clean)
            echo "Usage: docker_clean"
            echo "Removes all stopped containers and dangling images."
            ;;
        *)
            echo "No help available for $func"
            ;;
    esac
}

# Function: docker_build
#
# Builds a Docker image from the specified Dockerfile.
#
# Parameters:
#   - $1: The path to the Dockerfile.
#   - $2: The name of the image to build.
#
# Usage:
#   docker_build <dockerfile_path> <image_name>
#
# Example:
#   docker_build ./Dockerfile myimage
#
function docker_build() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_build
        return 0
    fi

    if [ -z "$1" ] || [ -z "$2" ]; then
        log error "Usage: docker_build <dockerfile_path> <image_name>"
        return 1
    fi

    docker build -f "$1" -t "$2" . \
        && log success "Docker image '$2' built successfully." \
        || log error "Failed to build Docker image '$2'."
}

# Function: docker_run
#
# Runs a Docker container from the specified image.
#
# Parameters:
#   - $1: The name of the image to run.
#   - $2: The name of the container.
#   - $3: (Optional) Additional options for the `docker run` command.
#
# Usage:
#   docker_run <image_name> <container_name> [options]
#
# Example:
#   docker_run myimage mycontainer -p 8080:80
#
function docker_run() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_run
        return 0
    fi

    if [ -z "$1" ] || [ -z "$2" ]; then
        log error "Usage: docker_run <image_name> <container_name> [options]"
        return 1
    fi

    docker run --name "$2" "${@:3}" "$1" \
        && log success "Docker container '$2' started successfully." \
        || log error "Failed to start Docker container '$2'."
}

# Function: docker_stop
#
# Stops the specified Docker container.
#
# Parameters:
#   - $1: The name of the container to stop.
#
# Usage:
#   docker_stop <container_name>
#
# Example:
#   docker_stop mycontainer
#
function docker_stop() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_stop
        return 0
    fi

    if [ -z "$1" ]; then
        log error "Usage: docker_stop <container_name>"
        return 1
    fi

    docker stop "$1" \
        && log success "Docker container '$1' stopped successfully." \
        || log error "Failed to stop Docker container '$1'."
}

# Function: docker_remove
#
# Removes the specified Docker container.
#
# Parameters:
#   - $1: The name of the container to remove.
#
# Usage:
#   docker_remove <container_name>
#
# Example:
#   docker_remove mycontainer
#
function docker_remove() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_remove
        return 0
    fi

    if [ -z "$1" ]; then
        log error "Usage: docker_remove <container_name>"
        return 1
    fi

    docker rm "$1" \
        && log success "Docker container '$1' removed successfully." \
        || log error "Failed to remove Docker container '$1'."
}

# Function: docker_rmi
#
# Removes the specified Docker image.
#
# Parameters:
#   - $1: The name of the image to remove.
#
# Usage:
#   docker_rmi <image_name>
#
# Example:
#   docker_rmi myimage
#
function docker_rmi() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_rmi
        return 0
    fi

    if [ -z "$1" ]; then
        log error "Usage: docker_rmi <image_name>"
        return 1
    fi

    docker rmi "$1" \
        && log success "Docker image '$1' removed successfully." \
        || log error "Failed to remove Docker image '$1'."
}

# Function: docker_ps
#
# Lists all running Docker containers.
#
# Usage:
#   docker_ps
#
# Example:
#   docker_ps
#
function docker_ps() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_ps
        return 0
    fi

    docker ps \
        && log success "Listed all running Docker containers." \
        || log error "Failed to list running Docker containers."
}

# Function: docker_images
#
# Lists all Docker images.
#
# Usage:
#   docker_images
#
# Example:
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
# Parameters:
#   - $1: The name of the container.
#   - $2: The command to execute.
#
# Usage:
#   docker_exec <container_name> <command>
#
# Example:
#   docker_exec mycontainer ls -l
#
function docker_exec() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_exec
        return 0
    fi

    if [ -z "$1" ] || [ -z "$2" ]; then
        log error "Usage: docker_exec <container_name> <command>"
        return 1
    fi

    docker exec "$1" "${@:2}" \
        && log success "Executed command '$2' in container '$1'." \
        || log error "Failed to execute command '$2' in container '$1'."
}

# Function: docker_logs
#
# Displays the logs of the specified Docker container.
#
# Parameters:
#   - $1: The name of the container.
#
# Usage:
#   docker_logs <container_name>
#
# Example:
#   docker_logs mycontainer
#
function docker_logs() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_logs
        return 0
    fi

    if [ -z "$1" ]; then
        log error "Usage: docker_logs <container_name>"
        return 1
    fi

    docker logs "$1" \
        && log success "Displayed logs for container '$1'." \
        || log error "Failed to display logs for container '$1'."
}

# Function: docker_clean
#
# Removes all stopped containers and dangling images.
#
# Usage:
#   docker_clean
#
# Example:
#   docker_clean
#
function docker_clean() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_docker_help docker_clean
        return 0
    fi

    docker system prune -f \
        && log success "Removed all stopped containers and dangling images." \
        || log error "Failed to clean Docker system."
}
