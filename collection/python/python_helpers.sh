#!/bin/bash
# DESCRIPTION:
# This file, `python_utils.sh`, contains a collection of utility functions specifically for Python development.
# It includes functions for managing virtual environments, code linting, formatting, testing, packaging, and more.
# These functions are designed to be sourced in your `.zshrc` or `.bashrc` file.

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
#   - func: The name of the utility function to display help for. If omitted, displays help for all functions.
#
# Usage:
#   display_help [func]
#
# Example:
#   display_help mkinit
#
function display_help() {
    local func="$1"
    case "$func" in
        mkinit)
            cat << EOF
    Usage: mkinit [directory]
    Creates '__init__.py' files in the specified directory and all its subdirectories.
    If no directory is provided, uses the current directory.
EOF
            ;;
        mkvenv)
            cat << EOF
    Usage: mkvenv <env_name> [python_version]
    Creates a new virtual environment with the specified name.
    Optionally specify the Python version (e.g., python3.8).
EOF
            ;;
        actvenv)
            cat << EOF
    Usage: actvenv <env_name>
    Activates the specified virtual environment.
EOF
            ;;
        deactvenv)
            cat << EOF
    Usage: deactvenv
    Deactivates the current virtual environment.
EOF
            ;;
        rmvenv)
            cat << EOF
    Usage: rmvenv <env_name>
    Removes the specified virtual environment.
EOF
            ;;
        install_requirements)
            cat << EOF
    Usage: install_requirements [requirements_file]
    Installs packages from the specified requirements file.
    If no file is specified, uses 'requirements.txt' in the current directory.
EOF
            ;;
        upgrade_packages)
            cat << EOF
    Usage: upgrade_packages
    Upgrades all installed packages in the current virtual environment.
EOF
            ;;
        mkpykg)
            cat << EOF
    Usage: mkpykg <package_name>
    Creates a new Python package with the specified name.
EOF
            ;;
        run_tests)
            cat << EOF
    Usage: run_tests [test_directory]
    Runs tests using pytest in the specified directory.
    If no directory is provided, uses 'tests' in the current directory.
EOF
            ;;
        lint_code)
            cat << EOF
    Usage: lint_code [directory]
    Lints Python code using flake8 and mypy in the specified directory.
    If no directory is provided, uses the current directory.
EOF
            ;;
        format_code)
            cat << EOF
    Usage: format_code [directory]
    Formats Python code using black in the specified directory.
    If no directory is provided, uses the current directory.
EOF
            ;;
        format_imports)
            cat << EOF
    Usage: format_imports [directory]
    Formats and orders imports using isort in the specified directory.
    If no directory is provided, uses the current directory.
EOF
            ;;
        check_coverage)
            cat << EOF
    Usage: check_coverage [test_directory]
    Checks code coverage using pytest-cov in the specified directory.
    If no directory is provided, uses 'tests' in the current directory.
EOF
            ;;
        build_package)
            cat << EOF
    Usage: build_package
    Builds the Python package into a distributable format (wheel and sdist).
EOF
            ;;
        publish_package)
            cat << EOF
    Usage: publish_package
    Publishes the package to PyPI using twine.
EOF
            ;;
        py_install_linters)
            cat << EOF
    Usage: py_install_linters
    Installs common Python linters and formatters: flake8, black, mypy, isort.
EOF
            ;;
        manage_dependencies)
            cat << EOF
    Usage: manage_dependencies
    Manages Python dependencies using pip-tools.
    Generates 'requirements.txt' from 'requirements.in'.
EOF
            ;;
        start_project)
            cat << EOF
    Usage: start_project <project_name>
    Initializes a new Python project with a predefined folder structure.
EOF
            ;;
        dockerize_app)
            cat << EOF
    Usage: dockerize_app
    Generates a Dockerfile for containerizing your application.
EOF
            ;;
        generate_docs)
            cat << EOF
    Usage: generate_docs
    Generates documentation using Sphinx.
EOF
            ;;
        *)
            cat << EOF
    Available functions:
      mkinit             - Creates '__init__.py' files in directories.
      mkvenv             - Creates a new virtual environment.
      actvenv            - Activates a virtual environment.
      deactvenv          - Deactivates the current virtual environment.
      rmvenv             - Removes a virtual environment.
      install_requirements - Installs packages from a requirements file.
      upgrade_packages   - Upgrades all installed packages.
      mkpykg             - Creates a new Python package.
      run_tests          - Runs tests using pytest.
      lint_code          - Lints code using flake8 and mypy.
      format_code        - Formats code using black.
      format_imports     - Formats and orders imports using isort.
      check_coverage     - Checks code coverage with pytest-cov.
      build_package      - Builds the package (wheel and sdist).
      publish_package    - Publishes the package to PyPI.
      py_install_linters - Installs common Python linters and formatters.
      manage_dependencies - Manages dependencies using pip-tools.
      start_project      - Initializes a new Python project structure.
      dockerize_app      - Generates a Dockerfile for your application.
      generate_docs      - Generates documentation using Sphinx.
    Use 'display_help <function_name>' to see detailed usage of a specific function.
EOF
            ;;
    esac
}

# Function: mkinit
#
# Creates '__init__.py' files in the specified directory and all its subdirectories.
#
# Usage:
#   mkinit [directory]
#
function mkinit() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help mkinit
        return 0
    fi

    local dir="${1:-.}"
    find "$dir" -type d -exec touch "{}/__init__.py" \;
    log success "__init__.py files created in all directories under '$dir'."
}

# Function: mkvenv
#
# Creates a new virtual environment with the specified name.
#
# Usage:
#   mkvenv <env_name> [python_version]
#
function mkvenv() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help mkvenv
        return 0
    fi

    local env_name="$1"
    local python_version="${2:-python3}"

    if [[ -z "$env_name" ]]; then
        log error "No virtual environment name provided."
        return 1
    fi

    if command -v "$python_version" >/dev/null 2>&1; then
        "$python_version" -m venv "$env_name" && log success "Virtual environment '$env_name' created using $python_version."
    else
        log error "Python version '$python_version' not found."
        return 1
    fi
}

# Function: actvenv
#
# Activates the specified virtual environment.
#
# Usage:
#   actvenv <env_name>
#
function actvenv() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help actvenv
        return 0
    fi

    local env_name="$1"

    if [[ -z "$env_name" ]]; then
        log error "No virtual environment name provided."
        return 1
    fi

    if [[ -f "$env_name/bin/activate" ]]; then
        source "$env_name/bin/activate" && log success "Virtual environment '$env_name' activated."
    else
        log error "Virtual environment '$env_name' does not exist."
        return 1
    fi
}

# Function: deactvenv
#
# Deactivates the current virtual environment.
#
# Usage:
#   deactvenv
#
function deactvenv() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help deactvenv
        return 0
    fi

    if [[ -n "$VIRTUAL_ENV" ]]; then
        deactivate && log success "Virtual environment deactivated."
    else
        log warning "No virtual environment is currently activated."
    fi
}

# Function: rmvenv
#
# Removes the specified virtual environment.
#
# Usage:
#   rmvenv <env_name>
#
function rmvenv() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help rmvenv
        return 0
    fi

    local env_name="$1"

    if [[ -z "$env_name" ]]; then
        log error "No virtual environment name provided."
        return 1
    fi

    if [[ -d "$env_name" ]]; then
        rm -rf "$env_name" && log success "Virtual environment '$env_name' removed."
    else
        log error "Virtual environment '$env_name' does not exist."
        return 1
    fi
}

# Function: install_requirements
#
# Installs packages from the specified requirements file.
#
# Usage:
#   install_requirements [requirements_file]
#
function install_requirements() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help install_requirements
        return 0
    fi

    local requirements_file="${1:-requirements.txt}"

    if [[ ! -f "$requirements_file" ]]; then
        log error "Requirements file '$requirements_file' does not exist."
        return 1
    fi

    pip install -r "$requirements_file" && log success "Packages installed from '$requirements_file'."
}

# Function: upgrade_packages
#
# Upgrades all installed packages in the current virtual environment.
#
# Usage:
#   upgrade_packages
#
function upgrade_packages() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help upgrade_packages
        return 0
    fi

    local packages
    packages=$(pip list --outdated --format=freeze | cut -d '=' -f 1)

    if [[ -z "$packages" ]]; then
        log info "All packages are up to date."
        return 0
    fi

    echo "$packages" | xargs -n1 pip install -U && log success "All packages upgraded."
}

# Function: mkpykg
#
# Creates a new Python package with the specified name.
#
# Usage:
#   mkpykg <package_name>
#
function mkpykg() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help mkpykg
        return 0
    fi

    local package_name="$1"

    if [[ -z "$package_name" ]]; then
        log error "No package name provided."
        return 1
    fi

    mkdir -p "$package_name/$package_name" && log success "Package directory '$package_name/$package_name' created."
    touch "$package_name/$package_name/__init__.py"
    cat << EOF > "$package_name/setup.py"
from setuptools import setup, find_packages

setup(
    name='$package_name',
    version='0.1.0',
    packages=find_packages(),
    install_requires=[],
)
EOF
    log success "setup.py created for package '$package_name'."

    cat << EOF > "$package_name/README.md"
# $package_name

Description of the $package_name package.
EOF
    log success "README.md created for package '$package_name'."
}

# Function: run_tests
#
# Runs tests using pytest in the specified directory.
#
# Usage:
#   run_tests [test_directory]
#
function run_tests() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help run_tests
        return 0
    fi

    local test_dir="${1:-tests}"

    if ! command -v pytest >/dev/null 2>&1; then
        log warning "pytest is not installed. Installing..."
        pip install pytest || { log error "Failed to install pytest."; return 1; }
    fi

    if [[ -d "$test_dir" ]]; then
        pytest "$test_dir" && log success "Tests executed successfully."
    else
        log error "Test directory '$test_dir' does not exist."
        return 1
    fi
}

# Function: py_install_linters
#
# Installs common Python linters and formatters: flake8, black, mypy, isort.
#
# Usage:
#   py_install_linters
#
function py_install_linters() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help py_install_linters
        return 0
    fi

    local tools=("flake8" "black" "mypy" "isort")

    for tool in "${tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            log info "Installing $tool..."
            pip install "$tool" || { log error "Failed to install $tool."; return 1; }
        else
            log info "$tool is already installed."
        fi
    done

    log success "All linters and formatters are installed."
}

# Function: lint_code
#
# Lints Python code using flake8 and mypy in the specified directory.
#
# Usage:
#   lint_code [directory]
#
function lint_code() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help lint_code
        return 0
    fi

    local dir="${1:-.}"

    py_install_linters

    log info "Running flake8..."
    flake8 "$dir" || { log warning "flake8 found issues."; }

    log info "Running mypy..."
    mypy "$dir" || { log warning "mypy found issues."; }

    log success "Linting completed."
}

# Function: format_code
#
# Formats Python code using black in the specified directory.
#
# Usage:
#   format_code [directory]
#
function format_code() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help format_code
        return 0
    fi

    local dir="${1:-.}"

    py_install_linters

    black "$dir" && log success "Code formatted using black."
}

# Function: format_imports
#
# Formats and orders imports using isort in the specified directory.
#
# Usage:
#   format_imports [directory]
#
function format_imports() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help format_imports
        return 0
    fi

    local dir="${1:-.}"

    py_install_linters

    isort "$dir" && log success "Imports formatted using isort."
}

# Function: check_coverage
#
# Checks code coverage using pytest-cov in the specified directory.
#
# Usage:
#   check_coverage [test_directory]
#
function check_coverage() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help check_coverage
        return 0
    fi

    local test_dir="${1:-tests}"

    if ! command -v pytest >/dev/null 2>&1; then
        log warning "pytest is not installed. Installing..."
        pip install pytest || { log error "Failed to install pytest."; return 1; }
    fi

    if ! pip show pytest-cov >/dev/null 2>&1; then
        log warning "pytest-cov is not installed. Installing..."
        pip install pytest-cov || { log error "Failed to install pytest-cov."; return 1; }
    fi

    if [[ -d "$test_dir" ]]; then
        pytest --cov=. "$test_dir" && log success "Code coverage checked."
    else
        log error "Test directory '$test_dir' does not exist."
        return 1
    fi
}

# Function: build_package
#
# Builds the Python package into a distributable format (wheel and sdist).
#
# Usage:
#   build_package
#
function build_package() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help build_package
        return 0
    fi

    if ! command -v python3 >/dev/null 2>&1; then
        log error "Python 3 is not installed."
        return 1
    fi

    if ! pip show wheel >/dev/null 2>&1; then
        log warning "wheel is not installed. Installing..."
        pip install wheel || { log error "Failed to install wheel."; return 1; }
    fi

    rm -rf dist/ build/ *.egg-info
    python3 setup.py sdist bdist_wheel && log success "Package built successfully."
}

# Function: publish_package
#
# Publishes the package to PyPI using twine.
#
# Usage:
#   publish_package
#
function publish_package() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help publish_package
        return 0
    fi

    if ! command -v twine >/dev/null 2>&1; then
        log warning "twine is not installed. Installing..."
        pip install twine || { log error "Failed to install twine."; return 1; }
    fi

    if [[ -d "dist" ]]; then
        twine upload dist/* && log success "Package published to PyPI."
    else
        log error "Distribution files not found. Build the package first using 'build_package'."
        return 1
    fi
}

# Function: manage_dependencies
#
# Manages Python dependencies using pip-tools.
# Generates 'requirements.txt' from 'requirements.in'.
#
# Usage:
#   manage_dependencies
#
function manage_dependencies() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help manage_dependencies
        return 0
    fi

    if ! command -v pip-compile >/dev/null 2>&1; then
        log warning "pip-tools is not installed. Installing..."
        pip install pip-tools || { log error "Failed to install pip-tools."; return 1; }
    fi

    if [[ ! -f "requirements.in" ]]; then
        log error "'requirements.in' file not found."
        return 1
    fi

    pip-compile requirements.in && log success "'requirements.txt' generated from 'requirements.in'."
}

# Function: start_project
#
# Initializes a new Python project with a predefined folder structure.
#
# Usage:
#   start_project <project_name>
#
function start_project() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help start_project
        return 0
    fi

    local project_name="$1"

    if [[ -z "$project_name" ]]; then
        log error "No project name provided."
        return 1
    fi

    mkdir -p "$project_name"/{src/"$project_name",tests,docs}
    touch "$project_name"/src/"$project_name"/__init__.py
    cat << EOF > "$project_name"/setup.py
from setuptools import setup, find_packages

setup(
    name='$project_name',
    version='0.1.0',
    packages=find_packages('src'),
    package_dir={'': 'src'},
    install_requires=[],
)
EOF
    cat << EOF > "$project_name"/README.md
# $project_name

Description of the $project_name project.
EOF
    log success "Project '$project_name' initialized with standard structure."
}

# Function: dockerize_app
#
# Generates a Dockerfile for containerizing your application.
#
# Usage:
#   dockerize_app
#
function dockerize_app() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help dockerize_app
        return 0
    fi

    if [[ ! -f "requirements.txt" ]]; then
        log error "'requirements.txt' not found. Run 'install_requirements' or 'manage_dependencies' first."
        return 1
    fi

    cat << EOF > Dockerfile
# Use the official Python image.
FROM python:3.9-slim

# Set the working directory in the container.
WORKDIR /app

# Copy the requirements file and install dependencies.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code.
COPY . .

# Expose the port the app runs on.
EXPOSE 8000

# Run the application.
CMD ["python", "src/main.py"]
EOF
    log success "Dockerfile generated."
}

# Function: generate_docs
#
# Generates documentation using Sphinx.
#
# Usage:
#   generate_docs
#
function generate_docs() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        display_help generate_docs
        return 0
    fi

    if ! command -v sphinx-quickstart >/dev/null 2>&1; then
        log warning "Sphinx is not installed. Installing..."
        pip install sphinx || { log error "Failed to install Sphinx."; return 1; }
    fi

    sphinx-quickstart docs
    log success "Sphinx documentation initialized in 'docs' directory."
}
