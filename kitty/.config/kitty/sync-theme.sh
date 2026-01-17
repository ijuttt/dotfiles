#!/usr/bin/env bash
# Sinkronisasi tema Neovim -> Kitty + Waybar (jegesmk setup)

THEME_NAME="$1"
KITTY_THEME_DIR="$HOME/.config/kitty/themes"
WAYBAR_STYLE_DIR="$HOME/.config/waybar/style"
KITTY_CURRENT="$KITTY_THEME_DIR/current-theme.conf"
WAYBAR_STYLE_SYMLINK="$HOME/.config/waybar/style.css"

# --- Update Kitty ---
if [ -f "$KITTY_THEME_DIR/tokyonight_${THEME_NAME}.conf" ]; then
  ln -sf "$KITTY_THEME_DIR/tokyonight_${THEME_NAME}.conf" "$KITTY_CURRENT"
  kitty @ set-colors -a "$KITTY_THEME_DIR/tokyonight_${THEME_NAME}.conf" >/dev/null 2>&1
  echo "✅ Synced Kitty -> tokyonight_${THEME_NAME}"
else
  echo "⚠️ Kitty theme not found: $THEME_NAME"
fi

# --- Update Waybar ---
WAYBAR_THEME_PATH="$WAYBAR_STYLE_DIR/tokyonight_${THEME_NAME}.css"
if [ -f "$WAYBAR_THEME_PATH" ]; then
  ln -sf "$WAYBAR_THEME_PATH" "$WAYBAR_STYLE_SYMLINK"
  killall waybar && waybar >/dev/null 2>&1 &
  echo "✅ Synced Waybar -> tokyonight_${THEME_NAME}"
else
  echo "⚠️ Waybar theme not found: $WAYBAR_THEME_PATH"
fi
