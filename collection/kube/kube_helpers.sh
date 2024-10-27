#!/bin/bash
# DESCRIPTION:
# This file, `kubectl_helpers.sh`, contains a collection of utility functions for managing Kubernetes clusters.
# It includes functions for context management, resource deployment, scaling, rolling updates, port forwarding, and more.
# These functions are designed to simplify common Kubernetes tasks and are intended to be sourced in your `.zshrc` or `.bashrc` file.

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

# Function: display_kubectl_help
#
# Displays the usage information for various kubectl utility functions.
#
# Parameters:
#   - func: The name of the utility function to display help for.
#
# Usage:
#   display_kubectl_help [function_name]
#
# Example:
#   display_kubectl_help k8s_apply
#
function display_kubectl_help() {
    local func="$1"
    case "$func" in
        k8s_apply)
            cat << EOF
    Usage: k8s_apply <manifest_file>
    Applies a Kubernetes manifest file.
    Example:
      k8s_apply deployment.yaml
EOF
            ;;
        k8s_delete)
            cat << EOF
    Usage: k8s_delete <manifest_file>
    Deletes resources defined in a Kubernetes manifest file.
    Example:
      k8s_delete deployment.yaml
EOF
            ;;
        k8s_get_pods)
            cat << EOF
    Usage: k8s_get_pods [options]
    Lists all pods in the current or specified namespace.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
      -w, --watch                    Watch for changes.
    Example:
      k8s_get_pods -n kube-system
EOF
            ;;
        k8s_describe_pod)
            cat << EOF
    Usage: k8s_describe_pod <pod_name> [options]
    Describes a specific pod.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
    Example:
      k8s_describe_pod my-pod -n default
EOF
            ;;
        k8s_logs)
            cat << EOF
    Usage: k8s_logs [options] <pod_name> [container_name]
    Fetches logs from a pod.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
      -f, --follow                   Follow the logs.
      --tail <lines>                 Show last N lines.
    Example:
      k8s_logs -f my-pod my-container
EOF
            ;;
        k8s_exec)
            cat << EOF
    Usage: k8s_exec [options] <pod_name> -- <command> [args...]
    Executes a command inside a pod.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
      -c, --container <container>    Specify container if multiple exist.
    Example:
      k8s_exec my-pod -- ls /app
EOF
            ;;
        k8s_port_forward)
            cat << EOF
    Usage: k8s_port_forward [options] <pod_name> <local_port>:<pod_port>
    Forwards a local port to a port on a pod.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
    Example:
      k8s_port_forward my-pod 8080:80
EOF
            ;;
        k8s_scale)
            cat << EOF
    Usage: k8s_scale [options] <resource_type> <resource_name> --replicas=<number>
    Scales a deployment, replica set, or replication controller.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
    Example:
      k8s_scale deployment my-deployment --replicas=3
EOF
            ;;
        k8s_context_list)
            cat << EOF
    Usage: k8s_context_list
    Lists all available Kubernetes contexts.
EOF
            ;;
        k8s_context_use)
            cat << EOF
    Usage: k8s_context_use <context_name>
    Switches to the specified Kubernetes context.
    Example:
      k8s_context_use my-cluster
EOF
            ;;
        k8s_namespace_list)
            cat << EOF
    Usage: k8s_namespace_list
    Lists all namespaces in the current context.
EOF
            ;;
        k8s_namespace_use)
            cat << EOF
    Usage: k8s_namespace_use <namespace>
    Sets the default namespace for the current context.
    Example:
      k8s_namespace_use kube-system
EOF
            ;;
        k8s_rollout_restart)
            cat << EOF
    Usage: k8s_rollout_restart [options] <resource_type>/<resource_name>
    Restarts pods managed by a deployment, daemonset, or statefulset.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
    Example:
      k8s_rollout_restart deployment/my-deployment
EOF
            ;;
        k8s_rollout_status)
            cat << EOF
    Usage: k8s_rollout_status [options] <resource_type>/<resource_name>
    Checks the rollout status of a deployment, daemonset, or statefulset.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
    Example:
      k8s_rollout_status deployment/my-deployment
EOF
            ;;
        k8s_get_services)
            cat << EOF
    Usage: k8s_get_services [options]
    Lists all services in the current or specified namespace.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
    Example:
      k8s_get_services -n default
EOF
            ;;
        k8s_describe_service)
            cat << EOF
    Usage: k8s_describe_service <service_name> [options]
    Describes a specific service.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
    Example:
      k8s_describe_service my-service -n default
EOF
            ;;
        k8s_get_nodes)
            cat << EOF
    Usage: k8s_get_nodes
    Lists all nodes in the cluster.
EOF
            ;;
        k8s_describe_node)
            cat << EOF
    Usage: k8s_describe_node <node_name>
    Describes a specific node.
    Example:
      k8s_describe_node node-1
EOF
            ;;
        k8s_get_deployments)
            cat << EOF
    Usage: k8s_get_deployments [options]
    Lists all deployments in the current or specified namespace.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
    Example:
      k8s_get_deployments -n default
EOF
            ;;
        k8s_describe_deployment)
            cat << EOF
    Usage: k8s_describe_deployment <deployment_name> [options]
    Describes a specific deployment.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
    Example:
      k8s_describe_deployment my-deployment -n default
EOF
            ;;
        k8s_create_secret)
            cat << EOF
    Usage: k8s_create_secret [options] <secret_name> --from-literal=<key>=<value>
    Creates a secret with specified key-value pairs.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
    Example:
      k8s_create_secret my-secret --from-literal=username=admin --from-literal=password=secret
EOF
            ;;
        k8s_create_configmap)
            cat << EOF
    Usage: k8s_create_configmap [options] <configmap_name> --from-file=<file_path>
    Creates a configmap from a file or directory.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
    Example:
      k8s_create_configmap my-config --from-file=config.properties
EOF
            ;;
        k8s_get_events)
            cat << EOF
    Usage: k8s_get_events [options]
    Retrieves events in the cluster or specified namespace.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is all namespaces).
    Example:
      k8s_get_events -n default
EOF
            ;;
        k8s_watch_resources)
            cat << EOF
    Usage: k8s_watch_resources [options] <resource_type>
    Watches for changes to resources of a specified type.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
    Example:
      k8s_watch_resources pods -n default
EOF
            ;;
        k8s_apply_directory)
            cat << EOF
    Usage: k8s_apply_directory <directory>
    Applies all manifest files in a directory.
    Example:
      k8s_apply_directory ./k8s-manifests
EOF
            ;;
        k8s_get_ingresses)
            cat << EOF
    Usage: k8s_get_ingresses [options]
    Lists all ingresses in the current or specified namespace.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
    Example:
      k8s_get_ingresses -n default
EOF
            ;;
        k8s_describe_ingress)
            cat << EOF
    Usage: k8s_describe_ingress <ingress_name> [options]
    Describes a specific ingress.
    Options:
      -n, --namespace <namespace>    Specify namespace (default is current).
    Example:
      k8s_describe_ingress my-ingress -n default
EOF
            ;;
        k8s_view_config)
            cat << EOF
    Usage: k8s_view_config
    Displays the current kubectl configuration.
EOF
            ;;
        *)
            cat << EOF
    Available functions:
      k8s_apply              - Applies a Kubernetes manifest file.
      k8s_delete             - Deletes resources from a manifest file.
      k8s_apply_directory    - Applies all manifest files in a directory.
      k8s_get_pods           - Lists pods in the current or specified namespace.
      k8s_describe_pod       - Describes a specific pod.
      k8s_get_services       - Lists services in the current or specified namespace.
      k8s_describe_service   - Describes a specific service.
      k8s_get_nodes          - Lists all nodes in the cluster.
      k8s_describe_node      - Describes a specific node.
      k8s_get_deployments    - Lists deployments in the current or specified namespace.
      k8s_describe_deployment - Describes a specific deployment.
      k8s_logs               - Fetches logs from a pod.
      k8s_exec               - Executes a command inside a pod.
      k8s_port_forward       - Forwards a local port to a pod.
      k8s_scale              - Scales a resource to a desired number of replicas.
      k8s_context_list       - Lists all Kubernetes contexts.
      k8s_context_use        - Switches to a specified Kubernetes context.
      k8s_namespace_list     - Lists all namespaces.
      k8s_namespace_use      - Sets the default namespace.
      k8s_rollout_restart    - Restarts pods managed by a resource.
      k8s_rollout_status     - Checks rollout status of a resource.
      k8s_create_secret      - Creates a secret with key-value pairs.
      k8s_create_configmap   - Creates a configmap from a file or directory.
      k8s_get_events         - Retrieves events in the cluster or namespace.
      k8s_watch_resources    - Watches for changes to resources.
      k8s_get_ingresses      - Lists ingresses in the current or specified namespace.
      k8s_describe_ingress   - Describes a specific ingress.
      k8s_view_config        - Displays the current kubectl configuration.
    Use 'display_kubectl_help <function_name>' to see detailed usage of a specific function.
EOF
            ;;
    esac
}

# Additional Functions:

# Function: k8s_get_services
#
# Lists all services in the current or specified namespace.
#
# Usage:
#   k8s_get_services [options]
#
function k8s_get_services() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_get_services
        return 0
    fi

    kubectl get services "$@" \
        && log success "Listed services." \
        || log error "Failed to list services."
}

# Function: k8s_describe_service
#
# Describes a specific service.
#
# Usage:
#   k8s_describe_service <service_name> [options]
#
function k8s_describe_service() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_describe_service
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: k8s_describe_service <service_name> [options]"
        return 1
    fi

    local service_name="$1"
    shift

    kubectl describe service "$service_name" "$@" \
        && log success "Described service '$service_name'." \
        || log error "Failed to describe service '$service_name'."
}

# Function: k8s_get_nodes
#
# Lists all nodes in the cluster.
#
# Usage:
#   k8s_get_nodes
#
function k8s_get_nodes() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_get_nodes
        return 0
    fi

    kubectl get nodes \
        && log success "Listed nodes." \
        || log error "Failed to list nodes."
}

# Function: k8s_describe_node
#
# Describes a specific node.
#
# Usage:
#   k8s_describe_node <node_name>
#
function k8s_describe_node() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_describe_node
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: k8s_describe_node <node_name>"
        return 1
    fi

    local node_name="$1"

    kubectl describe node "$node_name" \
        && log success "Described node '$node_name'." \
        || log error "Failed to describe node '$node_name'."
}

# Function: k8s_get_deployments
#
# Lists all deployments in the current or specified namespace.
#
# Usage:
#   k8s_get_deployments [options]
#
function k8s_get_deployments() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_get_deployments
        return 0
    fi

    kubectl get deployments "$@" \
        && log success "Listed deployments." \
        || log error "Failed to list deployments."
}

# Function: k8s_describe_deployment
#
# Describes a specific deployment.
#
# Usage:
#   k8s_describe_deployment <deployment_name> [options]
#
function k8s_describe_deployment() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_describe_deployment
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: k8s_describe_deployment <deployment_name> [options]"
        return 1
    fi

    local deployment_name="$1"
    shift

    kubectl describe deployment "$deployment_name" "$@" \
        && log success "Described deployment '$deployment_name'." \
        || log error "Failed to describe deployment '$deployment_name'."
}

# Function: k8s_create_secret
#
# Creates a secret with specified key-value pairs.
#
# Usage:
#   k8s_create_secret [options] <secret_name> --from-literal=<key>=<value>
#
function k8s_create_secret() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_create_secret
        return 0
    fi

    local options=()
    while [[ "$1" =~ ^- ]]; do
        options+=("$1" "$2")
        shift 2
    done

    if [[ -z "$1" ]]; then
        log error "Usage: k8s_create_secret [options] <secret_name> --from-literal=<key>=<value>"
        return 1
    fi

    local secret_name="$1"
    shift

    kubectl create secret generic "$secret_name" "${options[@]}" "$@" \
        && log success "Created secret '$secret_name'." \
        || log error "Failed to create secret '$secret_name'."
}

# Function: k8s_create_configmap
#
# Creates a configmap from a file or directory.
#
# Usage:
#   k8s_create_configmap [options] <configmap_name> --from-file=<file_path>
#
function k8s_create_configmap() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_create_configmap
        return 0
    fi

    local options=()
    while [[ "$1" =~ ^- ]]; do
        options+=("$1" "$2")
        shift 2
    done

    if [[ -z "$1" ]]; then
        log error "Usage: k8s_create_configmap [options] <configmap_name> --from-file=<file_path>"
        return 1
    fi

    local configmap_name="$1"
    shift

    kubectl create configmap "$configmap_name" "${options[@]}" "$@" \
        && log success "Created configmap '$configmap_name'." \
        || log error "Failed to create configmap '$configmap_name'."
}

# Function: k8s_get_events
#
# Retrieves events in the cluster or specified namespace.
#
# Usage:
#   k8s_get_events [options]
#
function k8s_get_events() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_get_events
        return 0
    fi

    kubectl get events "$@" \
        && log success "Retrieved events." \
        || log error "Failed to retrieve events."
}

# Function: k8s_watch_resources
#
# Watches for changes to resources of a specified type.
#
# Usage:
#   k8s_watch_resources [options] <resource_type>
#
function k8s_watch_resources() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_watch_resources
        return 0
    fi

    local options=()
    while [[ "$1" =~ ^- ]]; do
        options+=("$1" "$2")
        shift 2
    done

    if [[ -z "$1" ]]; then
        log error "Usage: k8s_watch_resources [options] <resource_type>"
        return 1
    fi

    local resource_type="$1"

    kubectl get "$resource_type" "${options[@]}" --watch \
        && log success "Watching resources of type '$resource_type'." \
        || log error "Failed to watch resources of type '$resource_type'."
}

# Function: k8s_apply_directory
#
# Applies all manifest files in a directory.
#
# Usage:
#   k8s_apply_directory <directory>
#
function k8s_apply_directory() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_apply_directory
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: k8s_apply_directory <directory>"
        return 1
    fi

    local directory="$1"

    if [[ ! -d "$directory" ]]; then
        log error "Directory '$directory' does not exist."
        return 1
    fi

    kubectl apply -f "$directory" \
        && log success "Applied manifests in directory '$directory'." \
        || log error "Failed to apply manifests in directory '$directory'."
}

# Function: k8s_get_ingresses
#
# Lists all ingresses in the current or specified namespace.
#
# Usage:
#   k8s_get_ingresses [options]
#
function k8s_get_ingresses() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_get_ingresses
        return 0
    fi

    kubectl get ingresses "$@" \
        && log success "Listed ingresses." \
        || log error "Failed to list ingresses."
}

# Function: k8s_describe_ingress
#
# Describes a specific ingress.
#
# Usage:
#   k8s_describe_ingress <ingress_name> [options]
#
function k8s_describe_ingress() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_describe_ingress
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: k8s_describe_ingress <ingress_name> [options]"
        return 1
    fi

    local ingress_name="$1"
    shift

    kubectl describe ingress "$ingress_name" "$@" \
        && log success "Described ingress '$ingress_name'." \
        || log error "Failed to describe ingress '$ingress_name'."
}

# Function: k8s_view_config
#
# Displays the current kubectl configuration.
#
# Usage:
#   k8s_view_config
#
function k8s_view_config() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_view_config
        return 0
    fi

    kubectl config view \
        && log success "Displayed kubectl configuration." \
        || log error "Failed to display kubectl configuration."
}

# Function: k8s_apply
#
# Applies a Kubernetes manifest file.
#
# Usage:
#   k8s_apply <manifest_file>
#
function k8s_apply() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_apply
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: k8s_apply <manifest_file>"
        return 1
    fi

    local manifest_file="$1"

    if [[ ! -f "$manifest_file" ]]; then
        log error "Manifest file '$manifest_file' does not exist."
        return 1
    fi

    kubectl apply -f "$manifest_file" \
        && log success "Applied manifest '$manifest_file'." \
        || log error "Failed to apply manifest '$manifest_file'."
}

# Function: k8s_apply_directory
#
# Applies all manifest files in a directory.
#
# Usage:
#   k8s_apply_directory <directory>
#
function k8s_apply_directory() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_apply_directory
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: k8s_apply_directory <directory>"
        return 1
    fi

    local directory="$1"

    if [[ ! -d "$directory" ]]; then
        log error "Directory '$directory' does not exist."
        return 1
    fi

    kubectl apply -f "$directory" \
        && log success "Applied manifests in directory '$directory'." \
        || log error "Failed to apply manifests in directory '$directory'."
}

# Function: k8s_delete
#
# Deletes resources defined in a Kubernetes manifest file.
#
# Usage:
#   k8s_delete <manifest_file>
#
function k8s_delete() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_delete
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: k8s_delete <manifest_file>"
        return 1
    fi

    local manifest_file="$1"

    if [[ ! -f "$manifest_file" ]]; then
        log error "Manifest file '$manifest_file' does not exist."
        return 1
    fi

    kubectl delete -f "$manifest_file" \
        && log success "Deleted resources from manifest '$manifest_file'." \
        || log error "Failed to delete resources from manifest '$manifest_file'."
}

# Function: k8s_get_pods
#
# Lists all pods in the current or specified namespace.
#
# Usage:
#   k8s_get_pods [options]
#
function k8s_get_pods() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_get_pods
        return 0
    fi

    kubectl get pods "$@" \
        && log success "Listed pods." \
        || log error "Failed to list pods."
}

# Additional functions from the enhanced script
# ...

# Function: k8s_get_configmaps
#
# Lists all configmaps in the current or specified namespace.
#
# Usage:
#   k8s_get_configmaps [options]
#
function k8s_get_configmaps() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_get_configmaps
        return 0
    fi

    kubectl get configmaps "$@" \
        && log success "Listed configmaps." \
        || log error "Failed to list configmaps."
}

# Function: k8s_describe_configmap
#
# Describes a specific configmap.
#
# Usage:
#   k8s_describe_configmap <configmap_name> [options]
#
function k8s_describe_configmap() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_describe_configmap
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: k8s_describe_configmap <configmap_name> [options]"
        return 1
    fi

    local configmap_name="$1"
    shift

    kubectl describe configmap "$configmap_name" "$@" \
        && log success "Described configmap '$configmap_name'." \
        || log error "Failed to describe configmap '$configmap_name'."
}

# Function: k8s_get_secrets
#
# Lists all secrets in the current or specified namespace.
#
# Usage:
#   k8s_get_secrets [options]
#
function k8s_get_secrets() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_get_secrets
        return 0
    fi

    kubectl get secrets "$@" \
        && log success "Listed secrets." \
        || log error "Failed to list secrets."
}

# Function: k8s_describe_secret
#
# Describes a specific secret.
#
# Usage:
#   k8s_describe_secret <secret_name> [options]
#
function k8s_describe_secret() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_describe_secret
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: k8s_describe_secret <secret_name> [options]"
        return 1
    fi

    local secret_name="$1"
    shift

    kubectl describe secret "$secret_name" "$@" \
        && log success "Described secret '$secret_name'." \
        || log error "Failed to describe secret '$secret_name'."
}

# Function: k8s_get_jobs
#
# Lists all jobs in the current or specified namespace.
#
# Usage:
#   k8s_get_jobs [options]
#
function k8s_get_jobs() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_get_jobs
        return 0
    fi

    kubectl get jobs "$@" \
        && log success "Listed jobs." \
        || log error "Failed to list jobs."
}

# Function: k8s_describe_job
#
# Describes a specific job.
#
# Usage:
#   k8s_describe_job <job_name> [options]
#
function k8s_describe_job() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_kubectl_help k8s_describe_job
        return 0
    fi

    if [[ -z "$1" ]]; then
        log error "Usage: k8s_describe_job <job_name> [options]"
        return 1
    fi

    local job_name="$1"
    shift

    kubectl describe job "$job_name" "$@" \
        && log success "Described job '$job_name'." \
        || log error "Failed to describe job '$job_name'."
}