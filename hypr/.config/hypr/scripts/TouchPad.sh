#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# For disabling touchpad - Auto-detect touchpad device

notif="$HOME/.config/swaync/images/ja.png"
export STATUS_FILE="$XDG_RUNTIME_DIR/touchpad.status"

# Auto-detect touchpad device
get_touchpad_device() {
    hyprctl devices -j | jq -r '.mice[] | select(.name | test("ouchpad|rackpad"; "i")) | .name' | head -n1
}

TOUCHPAD_DEVICE=$(get_touchpad_device)

if [ -z "$TOUCHPAD_DEVICE" ]; then
    notify-send -u critical -i "$notif" "Touchpad Error" "No touchpad device found"
    exit 1
fi

enable_touchpad() {
    printf "true" >"$STATUS_FILE"
    notify-send -u low -i "$notif" "Enabling" "touchpad"
    hyprctl keyword "device[$TOUCHPAD_DEVICE]:enabled" "true" -r
}

disable_touchpad() {
    printf "false" >"$STATUS_FILE"
    notify-send -u low -i "$notif" "Disabling" "touchpad"
    hyprctl keyword "device[$TOUCHPAD_DEVICE]:enabled" "false" -r
}

if ! [ -f "$STATUS_FILE" ]; then
  enable_touchpad
else
  if [ "$(cat "$STATUS_FILE")" = "true" ]; then
    disable_touchpad
  elif [ "$(cat "$STATUS_FILE")" = "false" ]; then
    enable_touchpad
  fi
fi
