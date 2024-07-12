#!/usr/bin/env bats

# Load the script to be tested
load '../install.sh'

# Test case: Verify the installation of a specific script
@test "install_script should copy script to handy_scripts" {
  run install_script "collection/docker/docker_basic_helpers.sh"
  [ "$status" -eq 0 ]
  [ -f "$HOME/handy_scripts/docker_basic_helpers.sh" ]
}

# Test case: Verify the installation of all scripts in a directory
@test "install_all_in_dir should copy all scripts to handy_scripts" {
  run install_all_in_dir "collection/github"
  [ "$status" -eq 0 ]
  [ -f "$HOME/handy_scripts/github_advanced_helpers.sh" ]
  [ -f "$HOME/handy_scripts/github_basic_helpers.sh" ]
}

# Test case: Verify appending to .bashrc
@test "append_to_shell_config should append source command to .bashrc" {
  append_to_shell_config ".bashrc" "docker_basic_helpers.sh"
  run grep -Fxq "source $HOME/handy_scripts/docker_basic_helpers.sh" "$HOME/.bashrc"
  [ "$status" -eq 0 ]
}

# Test case: Verify appending to .zshrc
@test "append_to_shell_config should append source command to .zshrc" {
  append_to_shell_config ".zshrc" "docker_basic_helpers.sh"
  run grep -Fxq "source $HOME/handy_scripts/docker_basic_helpers.sh" "$HOME/.zshrc"
  [ "$status" -eq 0 ]
}

# Cleanup after tests
teardown() {
  rm -rf "$HOME/handy_scripts"
  sed -i '/# Handy Scripts loading:/d' "$HOME/.bashrc"
  sed -i '/source $HOME\/handy_scripts\/docker_basic_helpers.sh/d' "$HOME/.bashrc"
  sed -i '/# Handy Scripts loading:/d' "$HOME/.zshrc"
  sed -i '/source $HOME\/handy_scripts\/docker_basic_helpers.sh/d' "$HOME/.zshrc"
}
