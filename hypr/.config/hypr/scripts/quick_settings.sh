#!/bin/bash
# ##################################### #
# Configuration
config_file="$HOME/.config/hypr/UserConfigs/01-UserDefaults.conf"
tmp_config_file=$(mktemp)
sed 's/^\$//g; s/ = /=/g' "$config_file" >"$tmp_config_file"
source "$tmp_config_file"

# Cleanup temporary file on exit
trap "rm -f $tmp_config_file" EXIT

# ##################################### #
# Variables
configs="$HOME/.config/hypr/configs"
UserConfigs="$HOME/.config/hypr/UserConfigs"
rofi_theme="$HOME/.config/rofi/config-edit.rasi"
iDIR="$HOME/.config/swaync/images"
scriptsDir="$HOME/.config/hypr/scripts"
UserScripts="$HOME/.config/hypr/UserScripts"
LOG_FILE="$HOME/.cache/hypr-quicksettings.log"

# ##################################### #
# Error Handling for Editor & Terminal
if [ -z "$term" ] || [ -z "$edit" ]; then
  notify-send -i "$iDIR/error.png" "Configuration Error" "Terminal or Editor not set in config"
  exit 1
fi

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# ##################################### #
# File mapping using associative array
declare -A file_map=(
  ["view/edit User Defaults"]="$UserConfigs/01-UserDefaults.conf"
  ["view/edit ENV variables"]="$UserConfigs/ENVariables.conf"
  ["view/edit Window Rules"]="$UserConfigs/WindowRules.conf"
  ["view/edit User Keybinds"]="$UserConfigs/UserKeybinds.conf"
  ["view/edit User Settings"]="$UserConfigs/UserSettings.conf"
  ["view/edit Startup Apps"]="$UserConfigs/Startup_Apps.conf"
  ["view/edit Decorations"]="$UserConfigs/UserDecorations.conf"
  ["view/edit Animations"]="$UserConfigs/UserAnimations.conf"
  ["view/edit Laptop Keybinds"]="$UserConfigs/Laptops.conf"
  ["view/edit Default Keybinds"]="$configs/Keybinds.conf"
)

# ##################################### #
# Function to display the menu options
menu() {
  cat <<EOF
view/edit User Defaults
view/edit ENV variables
view/edit Window Rules
view/edit User Keybinds
view/edit User Settings
view/edit Startup Apps
view/edit Decorations
view/edit Animations
view/edit Laptop Keybinds
view/edit Default Keybinds
Choose Kitty Terminal Theme
Configure Monitors (nwg-displays)
Configure Workspace Rules (nwg-displays)
GTK Settings (nwg-look)
QT Apps Settings (qt6ct)
QT Apps Settings (qt5ct)
Choose Hyprland Animations
Choose Monitor Profiles
Choose Rofi Themes
Choose Waybar Styles
Choose Waybar Layout
Search for Keybinds
Toggle Game Mode
Switch Dark-Light Theme
Change Wallpaper
Wallpaper Effect
Wallpaper Random
EOF
}

# ##################################### #
# Function to check if command exists
check_command() {
  local cmd=$1
  local name=$2
  if ! command -v "$cmd" &>/dev/null; then
    notify-send -i "$iDIR/error.png" "E-R-R-O-R" "Install $name first"
    echo "$(date): Error - $name not installed" >>"$LOG_FILE"
    exit 1
  fi
}

# ##################################### #
# Main function to handle menu selection
main() {
  choice=$(menu | rofi -i -dmenu -config $rofi_theme -mesg "$msg")

  # Exit if no choice made
  [ -z "$choice" ] && exit 0

  # Log the selection
  echo "$(date): Selected - $choice" >>"$LOG_FILE"

  # Check if choice is a file to edit
  if [[ -v file_map["$choice"] ]]; then
    file="${file_map[$choice]}"

    # Validate file exists
    if [ ! -f "$file" ]; then
      notify-send -i "$iDIR/error.png" "File Not Found" "$file does not exist"
      echo "$(date): Error - File not found: $file" >>"$LOG_FILE"
      exit 1
    fi

    # Open in editor
    $term -e $edit "$file"
    echo "$(date): Opened file: $file" >>"$LOG_FILE"
    return
  fi

  # Handle command executions
  case "$choice" in
  "Choose Kitty Terminal Theme")
    $scriptsDir/Kitty_themes.sh
    ;;

  "Change Wallpaper")
    $UserScripts/WallpaperSelect.sh
    ;;

  "Wallpaper Effect")
    $UserScripts/WallpaperEffects.sh
    ;;

  "Wallpaper Random")
    if echo -e "Yes\nNo" | rofi -dmenu -p "Apply random wallpaper?" -config $rofi_theme | grep -q "Yes"; then
      $UserScripts/WallpaperRandom.sh
      echo "$(date): Applied random wallpaper" >>"$LOG_FILE"
    else
      echo "$(date): Random wallpaper cancelled" >>"$LOG_FILE"
    fi
    ;;

  "Configure Monitors (nwg-displays)" | "Configure Workspace Rules (nwg-displays)")
    check_command "nwg-displays" "nwg-displays"
    nwg-displays
    ;;

  "GTK Settings (nwg-look)")
    check_command "nwg-look" "nwg-look"
    nwg-look
    ;;

  "QT Apps Settings (qt6ct)")
    check_command "qt6ct" "qt6ct"
    qt6ct
    ;;

  "QT Apps Settings (qt5ct)")
    check_command "qt5ct" "qt5ct"
    qt5ct
    ;;

  "Choose Hyprland Animations")
    $scriptsDir/Animations.sh
    ;;

  "Choose Monitor Profiles")
    $scriptsDir/MonitorProfiles.sh
    ;;

  "Choose Rofi Themes")
    $scriptsDir/RofiThemeSelector.sh
    ;;

  "Choose Waybar Styles")
    $scriptsDir/WaybarStyles.sh
    ;;

  "Choose Waybar Layout")
    $scriptsDir/WaybarLayout.sh
    ;;

  "Search for Keybinds")
    $scriptsDir/KeyBinds.sh
    ;;

  "Toggle Game Mode")
    $scriptsDir/GameMode.sh
    ;;

  "Switch Dark-Light Theme")
    $scriptsDir/DarkLight.sh
    ;;

  *)
    echo "$(date): Invalid choice - $choice" >>"$LOG_FILE"
    return
    ;;
  esac

  echo "$(date): Executed command for: $choice" >>"$LOG_FILE"
}

# ##################################### #
# Check if rofi is already running
if pidof rofi >/dev/null; then
  pkill rofi
fi

main
