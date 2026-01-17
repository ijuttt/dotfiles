#!/bin/bash

MODE="$1" # "wallust" or "static"

KITTY_CONF="$HOME/.config/kitty/current-theme.conf"
KITTY_WALLUST="$HOME/.config/kitty/kitty-themes/01-Wallust.conf"
KITTY_STATIC="$HOME/.config/kitty/themes/tokyo-night-moon.conf"

NVIM_WALLUST_FILE="$HOME/.config/nvim/lua/wallust_colors.lua"
NVIM_WALLUST_BACKUP="$HOME/.config/nvim/lua/wallust_colors.lua.bak"

if [ "$MODE" == "wallust" ]; then
	echo "Switching to Wallust (Wallpaper) Mode..."

	# 1. Link Kitty to Wallust
	ln -sf "$KITTY_WALLUST" "$KITTY_CONF"

	# 2. Restore Neovim Wallust file if it was hidden
	if [ -f "$NVIM_WALLUST_BACKUP" ]; then
		mv "$NVIM_WALLUST_BACKUP" "$NVIM_WALLUST_FILE"
	fi

	# 3. Reload
	killall -SIGUSR1 kitty
	# Rofi updates automatically next time it launches because config.rasi is static

elif [ "$MODE" == "static" ]; then
	echo "Switching to Static (TokyoNight) Mode..."

	# 1. Link Kitty to Static
	ln -sf "$KITTY_STATIC" "$KITTY_CONF"

	# 2. Hide Neovim Wallust file (triggers Neovim to fall back to default LazyVim theme)
	if [ -f "$NVIM_WALLUST_FILE" ]; then
		mv "$NVIM_WALLUST_FILE" "$NVIM_WALLUST_BACKUP"
	fi

	# 3. Reload
	killall -SIGUSR1 kitty

else
	echo "Usage: ./ThemeSwitch.sh [wallust|static]"
fi
