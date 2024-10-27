# Makefile for installing scripts

# Variables
TARGET_DIR := $(HOME)/handy_scripts
COLLECTION_DIR := collection

# Color logging functions
define log
    @echo -e "\033[1;34m[INFO]\033[0m $(1)"
endef

define log_success
    @echo -e "\033[1;32m[SUCCESS]\033[0m $(1)"
endef

define log_warning
    @echo -e "\033[1;33m[WARNING]\033[0m $(1)"
endef

define log_error
    @echo -e "\033[1;31m[ERROR]\033[0m $(1)"
endef

# Install a single script
install_script:
    $(call log, "Installing $(script_path)...")
    @mkdir -p $(TARGET_DIR)
    @if [ -f $(script_path) ]; then \
        cp $(script_path) $(TARGET_DIR)/; \
        chmod +x $(TARGET_DIR)/$(notdir $(script_path)); \
        $(call log_success, "$(script_path) installed successfully in $(TARGET_DIR)."); \
    else \
        $(call log_error, "Script $(script_path) not found."); \
    fi

# Install all scripts in a directory
install_all_in_dir:
    $(call log, "Installing all scripts in $(dir_path)...")
    @if [ -d $(dir_path) ]; then \
        for script in $(dir_path)/*.sh; do \
            $(MAKE) install_script script_path=$$script; \
        done; \
        $(call log_success, "All scripts in $(dir_path) installed successfully."); \
    else \
        $(call log_error, "Directory $(dir_path) not found."); \
    fi

# Append to shell config
append_to_shell_config:
    $(call log, "Appending to $(shell_config)...")
	@if [ -f $(HOME)/$(shell_config) ]; then \
        if ! grep -Fxq "source $(TARGET_DIR)/$(script_name)" $(HOME)/$(shell_config); then \
            echo -e "\n# Handy Scripts loading:\nsource $(TARGET_DIR)/$(script_name)" >> $(HOME)/$(shell_config); \
            $(call log_success, "Appended source command to $(HOME)/$(shell_config)"); \
        else \
            $(call log_warning, "Source command already exists in $(HOME)/$(shell_config)"); \
        fi \
    else \
        $(call log_error, "$(HOME)/$(shell_config) not found."); \
    fi

# List directories
list_directories:
    @find $(COLLECTION_DIR) -maxdepth 1 -type d -not -name '$(COLLECTION_DIR)' -exec basename {} \;

# List scripts in a directory
list_scripts_in_dir:
    @find $(dir_path) -maxdepth 1 -type f -name '*.sh' -exec basename {} \;

# Handle installation for a specified directory
handle_installation:
    $(call log, "Handling installation for $(dir)...")
    @$(MAKE) list_scripts_in_dir dir_path=$(COLLECTION_DIR)/$(dir) | while read script; do \
        $(MAKE) install_script script_path=$(COLLECTION_DIR)/$(dir)/$$script; \
        $(MAKE) append_to_shell_config shell_config=.bashrc script_name=$$script; \
        $(MAKE) append_to_shell_config shell_config=.zshrc script_name=$$script; \
    done

# Install all scripts in all directories
install_all:
    $(call log, "Installing all scripts...")
    @$(MAKE) list_directories | while read dir; do \
        $(MAKE) install_all_in_dir dir_path=$(COLLECTION_DIR)/$$dir; \
        $(MAKE) list_scripts_in_dir dir_path=$(COLLECTION_DIR)/$$dir | while read script; do \
            $(MAKE) append_to_shell_config shell_config=.bashrc script_name=$$script; \
            $(MAKE) append_to_shell_config shell_config=.zshrc script_name=$$script; \
        done; \
    done
    $(call log_success, "All scripts installed successfully.")

# Main target
.PHONY: all
all:
    @$(MAKE) list_directories | while read dir; do \
        $(MAKE) handle_installation dir=$$dir; \
    done

# Usage
.PHONY: usage
usage:
    @echo "Usage: make [target] [variable=value]"
    @echo "Targets:"
    @echo "  install_script script_path=/path/to/script.sh"
    @echo "  install_all_in_dir dir_path=/path/to/directory"
    @echo "  append_to_shell_config shell_config=.bashrc script_name=script_name.sh"
    @echo "  list_directories"
    @echo "  list_scripts_in_dir dir_path=/path/to/directory"
    @echo "  handle_installation dir=directory_name"
    @echo "  install_all"
    @echo "  all"