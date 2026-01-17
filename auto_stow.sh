#!/bin/bash

# Dotfiles Stow Automator (Robust Edition)
# Usage: ./stow-auto.sh [--dry-run] app1 app2 app3
# Example: ./stow-auto.sh --dry-run lazygit swaync yazi

set -euo pipefail

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$SCRIPT_DIR}"
CONFIG_SOURCE="$HOME/.config"

# Flags
DRY_RUN=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() { [[ $DRY_RUN -eq 1 ]] && echo -e "${BLUE}[DRY-RUN]${NC} $1"; }

# Validate config exists and determine type
check_app_config() {
  local app=$1
  local source_path="$CONFIG_SOURCE/$app"

  if [[ -d "$source_path" ]]; then
    echo "dir"
    return 0
  elif [[ -f "$source_path" ]]; then
    echo "file"
    return 0
  else
    log_error "$app not found in $CONFIG_SOURCE"
    return 1
  fi
}

# Check for conflicts
check_conflicts() {
  local app=$1
  local source_path="$CONFIG_SOURCE/$app"

  # Already a symlink? (OK, might be pre-stowed)
  if [[ -L "$source_path" ]]; then
    log_warn "$source_path is already a symlink (already stowed?)"
    return 1
  fi

  # Check if stow folder structure exists
  local app_type=$(check_app_config "$app" || echo "none")
  if [[ "$app_type" == "none" ]]; then
    return 1
  fi

  return 0
}

# Test stow without making changes (simulates final state)
test_stow() {
  local app=$1
  local target_path="$DOTFILES_DIR/$app/.config/$app"

  # In dry-run, we check where the file WILL BE after move
  # In real mode, we check where it ALREADY IS after move
  if [[ ! -e "$target_path" ]]; then
    # This means the move hasn't happened yet (expected in dry-run)
    # We'll simulate by checking the source instead
    if [[ $DRY_RUN -eq 1 ]]; then
      log_debug "Testing stow structure (simulated)"
      # In dry-run, just verify the source exists
      # The actual stow test will happen when we run for real
      return 0
    else
      log_error "App structure not found: $target_path"
      return 1
    fi
  fi

  # Test actual stow command
  if cd "$DOTFILES_DIR"; then
    log_debug "Testing stow: $app"
    if [[ $DRY_RUN -eq 1 ]]; then
      # Can't test stow in dry-run since files aren't moved yet
      log_debug "Stow test skipped (dry-run mode)"
      return 0
    else
      stow -n -v "$app" 2>&1 | sed 's/^/  [TEST] /' || {
        log_error "Stow test failed for $app"
        return 1
      }
    fi
  else
    log_error "Cannot cd to $DOTFILES_DIR"
    return 1
  fi
}

# Move config file/folder
move_config() {
  local app=$1
  local app_type=$2
  local source_path="$CONFIG_SOURCE/$app"
  local target_dir="$DOTFILES_DIR/$app/.config"
  local target_path="$target_dir/$app"

  # Check if already moved (real mode only)
  if [[ $DRY_RUN -eq 0 ]] && [[ -e "$target_path" ]]; then
    log_warn "$target_path already exists, skipping move"
    return 0
  fi

  # Create target structure
  if [[ ! -d "$target_dir" ]]; then
    if [[ $DRY_RUN -eq 0 ]]; then
      mkdir -p "$target_dir"
      log_info "Created: $target_dir"
    else
      log_debug "Would create: $target_dir"
    fi
  fi

  # Move file or folder
  if [[ $DRY_RUN -eq 0 ]]; then
    mv "$source_path" "$target_path"
    log_info "Moved: $source_path → $target_path"
  else
    log_debug "Would move: $source_path → $target_path"
  fi

  return 0
}

# Execute stow
do_stow() {
  local app=$1

  if cd "$DOTFILES_DIR"; then
    if [[ $DRY_RUN -eq 1 ]]; then
      log_debug "Would execute: stow $app"
      log_debug "This will create: $CONFIG_SOURCE/$app -> $DOTFILES_DIR/$app/.config/$app"
    else
      log_info "Executing stow: $app"
      stow -v "$app" 2>&1 | sed 's/^/  /' || {
        log_error "Stow command failed"
        return 1
      }
    fi
  else
    log_error "Cannot cd to $DOTFILES_DIR"
    return 1
  fi
}

# Process single app
process_app() {
  local app=$1

  log_info "Processing: $app"

  # Step 1: Validate config exists
  local app_type
  app_type=$(check_app_config "$app") || return 1
  log_debug "Type: $app_type"

  # Step 2: Check for conflicts
  if ! check_conflicts "$app"; then
    return 1
  fi

  # Step 3: Move config
  if ! move_config "$app" "$app_type"; then
    log_error "Failed to move $app"
    return 1
  fi

  # Step 4: Test stow (only meaningful in real mode)
  if ! test_stow "$app"; then
    log_error "Stow validation failed for $app"
    return 1
  fi

  # Step 5: Execute stow
  if ! do_stow "$app"; then
    log_error "Stow failed for $app"
    return 1
  fi

  log_info "✓ $app done"
  return 0
}

# Main
main() {
  # Parse flags FIRST
  case "${1:-}" in
  --dry-run | --dryrun | -n | --dry)
    DRY_RUN=1
    shift
    ;;
  esac

  # Check arguments
  if [[ $# -eq 0 ]]; then
    echo "Usage: $0 [--dry-run] app1 app2 app3"
    echo ""
    echo "Examples:"
    echo "  $0 lazygit swaync yazi"
    echo "  $0 --dry-run wallust wlogout"
    echo ""
    echo "Flags:"
    echo "  --dry-run, -n    Show what would happen without making changes"
    exit 1
  fi

  # Validate dotfiles dir
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    log_error "Dotfiles directory not found: $DOTFILES_DIR"
    exit 1
  fi

  # Header
  echo ""
  log_info "Starting stow automation"
  log_info "Dotfiles dir: $DOTFILES_DIR"
  log_info "Config source: $CONFIG_SOURCE"
  [[ $DRY_RUN -eq 1 ]] && log_debug "DRY-RUN MODE (no changes will be made)"
  echo ""

  # Process apps
  local failed=0
  for app in "$@"; do
    if ! process_app "$app"; then
      ((failed++))
    fi
    echo ""
  done

  # Summary
  local total=$#
  local success=$((total - failed))
  echo -e "${GREEN}═══════════════════════════════════${NC}"
  if [[ $DRY_RUN -eq 1 ]]; then
    log_debug "DRY-RUN COMPLETE - Run without --dry-run to apply changes"
  fi
  log_info "Results: $success/$total successful"
  [[ $failed -gt 0 ]] && log_warn "Failed: $failed"
  echo -e "${GREEN}═══════════════════════════════════${NC}"

  return $failed
}

main "$@"
