#!/bin/bash
# ##################################### #
# Universal Quick Settings Dashboard    #
# ##################################### #

# Configuration
config_file="$HOME/.config/hypr/UserConfigs/01-UserDefaults.conf"
tmp_config_file=$(mktemp)
sed 's/^\$//g; s/ = /=/g' "$config_file" >"$tmp_config_file"
source "$tmp_config_file"
trap "rm -f $tmp_config_file" EXIT

# Variables
configs="$HOME/.config/hypr/configs"
UserConfigs="$HOME/.config/hypr/UserConfigs"
rofi_theme="$HOME/.config/rofi/config-quick.rasi"
iDIR="$HOME/.config/swaync/images"
scriptsDir="$HOME/.config/hypr/scripts"
UserScripts="$HOME/.config/hypr/UserScripts"
LOG_FILE="$HOME/.cache/hypr-quicksettings.log"

# Create log dir
mkdir -p "$(dirname "$LOG_FILE")"

# Error Handling
if [ -z "$term" ] || [ -z "$edit" ]; then
  notify-send -i "$iDIR/error.png" "Configuration Error" "Terminal or Editor not set in config"
  exit 1
fi

# ##################################### #
# Status Checks
# ##################################### #

get_theme_mode() {
  if [ -f "$HOME/.cache/.theme_mode" ]; then
    cat "$HOME/.cache/.theme_mode"
  else
    echo "Unknown"
  fi
}

get_hypridle_status() {
  if pgrep -x "hypridle" >/dev/null; then
    echo "ON"
  else
    echo "OFF"
  fi
}

get_touchpad_status() {
  local status_file="$XDG_RUNTIME_DIR/touchpad.status"
  if [ -f "$status_file" ]; then
    if [ "$(cat "$status_file")" = "true" ]; then
      echo "ON"
    else
      echo "OFF"
    fi
  else
    echo "ON"
  fi
}

get_keyboard_layout() {
  local layout_file="$HOME/.cache/kb_layout"
  if [ -f "$layout_file" ]; then
    cat "$layout_file" | tr '[:lower:]' '[:upper:]'
  else
    echo "US"
  fi
}

# Get statuses
current_mode=$(get_theme_mode)
hypridle_status=$(get_hypridle_status)
touchpad_status=$(get_touchpad_status)
kb_layout=$(get_keyboard_layout)

# ##################################### #
# Menu Definition
# ##################################### #

# 1. Hyprland Configs
menu_hypr_configs() {
  cat <<EOF
📝 Hypr: User Defaults
📝 Hypr: Keybinds (User)
📝 Hypr: Keybinds (Default)
📝 Hypr: Window Rules
📝 Hypr: Startup Apps
📝 Hypr: Decorations
📝 Hypr: Animations
📝 Hypr: Laptop Keybinds
📝 Hypr: Environment Variables
📝 Hypr: User Settings
📝 Hypr: Workspace Rules
EOF
}

# 2. Application Configs
menu_app_configs() {
  cat <<EOF
⚡ App: Neovim
⚡ App: Kitty
⚡ App: Waybar Config
⚡ App: SwayNC
⚡ App: Cava
⚡ App: Btop
⚡ App: Rofi
⚡ App: Zshrc
EOF
}

# 3. Appearance & Theme
menu_appearance() {
  cat <<EOF
🎨 Theme: Change Wallpaper
🎨 Theme: Switch Dark/Light [$current_mode]
🎨 Theme: Rofi
🎨 Theme: Hyprland Animations
🎨 Theme: Waybar Styles
🎨 Theme: Waybar Layout
🎨 Theme: Kitty
🎨 Theme: Prompt
🖼️  Theme: Wallpaper Effects
🎲 Theme: Random Wallpaper
EOF
}

# 4. System Controls
menu_system() {
  cat <<EOF
🔄 Sys: Refresh Desktop
💤 Sys: Idle Inhibitor [$hypridle_status]
🖱️  Sys: Touchpad [$touchpad_status]
⌨️  Sys: Keyboard Layout [$kb_layout]
🔍 Sys: Search Keybinds
🖥️  Sys: Monitor Settings
🖥️  Sys: Monitor Profiles
� Sys: GTK Settings
🖌️  Sys: QT6 Settings
🖌️  Sys: QT5 Settings
🔒 Sys: Lock Screen
📋 Sys: Clipboard Manager
🚪 Sys: Power Menu
EOF
}

# 5. System Utilities
menu_utils() {
  cat <<EOF
🔊 Util: Audio Mixer
📶 Util: Bluetooth
🌐 Util: Network Manager
📊 Util: System Monitor
EOF
}

# Combine all menus
menu_all() {
  menu_hypr_configs
  menu_app_configs
  menu_appearance
  menu_system
  menu_utils
}

# ##################################### #
# Logic
# ##################################### #

main() {
  # Show Rofi
  choice=$(menu_all | rofi -dmenu -i -config "$rofi_theme" -p "Settings")

  # Exit if cancelled
  [ -z "$choice" ] && exit 0

  echo "$(date): Selected '$choice'" >>"$LOG_FILE"

  # Map choices to commands
  case "$choice" in
  # --- Hyprland Configs ---
  *"Hypr: User Defaults"*)         file="$UserConfigs/01-UserDefaults.conf" ;;
  *"Hypr: Keybinds (User)"*)       file="$UserConfigs/UserKeybinds.conf" ;;
  *"Hypr: Keybinds (Default)"*)    file="$configs/Keybinds.conf" ;;
  *"Hypr: Window Rules"*)          file="$UserConfigs/WindowRules.conf" ;;
  *"Hypr: Startup Apps"*)          file="$UserConfigs/Startup_Apps.conf" ;;
  *"Hypr: Decorations"*)           file="$UserConfigs/UserDecorations.conf" ;;
  *"Hypr: Animations"*)            file="$UserConfigs/UserAnimations.conf" ;;
  *"Hypr: Laptop Keybinds"*)       file="$UserConfigs/Laptops.conf" ;;
  *"Hypr: Environment Variables"*) file="$UserConfigs/ENVariables.conf" ;;
  *"Hypr: User Settings"*)         file="$UserConfigs/UserSettings.conf" ;;
  *"Hypr: Workspace Rules"*)       file="$UserConfigs/WorkSpaceRules" ;;

  # --- Application Configs ---
  *"App: Neovim"*)                 file="$HOME/.config/nvim/init.lua" ;;
  *"App: Kitty"*)                  file="$HOME/.config/kitty/kitty.conf" ;;
  *"App: Waybar Config"*)          file="$HOME/.config/waybar/config" ;;
  *"App: SwayNC"*)                 file="$HOME/.config/swaync/config.json" ;;
  *"App: Cava"*)                   file="$HOME/.config/cava/config" ;;
  *"App: Btop"*)                   file="$HOME/.config/btop/btop.conf" ;;
  *"App: Rofi"*)                   file="$HOME/.config/rofi/config.rasi" ;;
  *"App: Zshrc"*)                  file="$HOME/.zshrc" ;;

  # --- Appearance ---
  *"Theme: Change Wallpaper"*)          $UserScripts/WallpaperSelect.sh ;;
  *"Theme: Switch Dark/Light"*)         $scriptsDir/DarkLight.sh ;;
  *"Theme: Rofi"*)                      $scriptsDir/RofiThemeSelector.sh ;;
  *"Theme: Hyprland Animations"*)       $scriptsDir/Animations.sh ;;
  *"Theme: Waybar Styles"*)             $scriptsDir/WaybarStyles.sh ;;
  *"Theme: Waybar Layout"*)             $scriptsDir/WaybarLayout.sh ;;
  *"Theme: Kitty"*)                     $scriptsDir/Kitty_themes.sh ;;
  *"Theme: Prompt"*)
      # Adaptive: Detect prompt framework and configure accordingly
      if command -v starship &>/dev/null && grep -q "starship" "$HOME/.zshrc" 2>/dev/null; then
        # Starship: Edit config file
        file="$HOME/.config/starship.toml"
      elif [ -f "$HOME/.p10k.zsh" ]; then
        # Powerlevel10k: Run configuration wizard
        $term -e zsh -ic "p10k configure"
      else
        notify-send "Prompt Config" "No supported prompt found (p10k/starship)"
      fi
      ;;
  *"Theme: Wallpaper Effects"*)         $UserScripts/WallpaperEffects.sh ;;
  *"Theme: Random Wallpaper"*)         
      if echo -e "Yes\nNo" | rofi -dmenu -p "Apply random wallpaper?" -config "$rofi_theme" | grep -q "Yes"; then
        $UserScripts/WallpaperRandom.sh
      fi
      ;;

  # --- System ---
  *"Sys: Refresh Desktop"*)        $scriptsDir/Refresh.sh ;;
  *"Sys: Idle Inhibitor"*)         $scriptsDir/Hypridle.sh toggle ;;
  *"Sys: Touchpad"*)               $scriptsDir/TouchPad.sh ;;
  *"Sys: Keyboard Layout"*)        $scriptsDir/SwitchKeyboardLayout.sh ;;
  *"Sys: Search Keybinds"*)        $scriptsDir/KeyBinds.sh ;;
  *"Sys: Monitor Settings"*)       nwg-displays ;;
  *"Sys: Monitor Profiles"*)       $scriptsDir/MonitorProfiles.sh ;;
  *"Sys: GTK Settings"*)           nwg-look ;;
  *"Sys: QT6 Settings"*)           qt6ct ;;
  *"Sys: QT5 Settings"*)           qt5ct ;;
  *"Sys: Lock Screen"*)            $scriptsDir/LockScreen.sh ;;
  *"Sys: Clipboard Manager"*)      $scriptsDir/ClipManager.sh ;;
  *"Sys: Power Menu"*)             $scriptsDir/Wlogout.sh ;;

  # --- Utilities ---
  *"Util: Audio Mixer"*)           $scriptsDir/ncpamixer.sh ;;
  *"Util: Bluetooth"*)             $term -e bluetui ;;
  *"Util: Network Manager"*)       nm-connection-editor ;;
  *"Util: System Monitor"*)        $term -e btop ;;
  
  *)
      notify-send "Error" "Unknown selection: $choice"
      exit 1
      ;;
  esac

  # Open File logic
  if [ -n "$file" ]; then
    if [ -f "$file" ]; then
        $term -e $edit "$file"
    else
        notify-send -u critical "Error" "File not found:\n$file"
    fi
  fi
}

# Kill existing rofi
if pidof rofi >/dev/null; then
  pkill rofi
fi

main
