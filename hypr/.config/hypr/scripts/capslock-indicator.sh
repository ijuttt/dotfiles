#!/bin/bash
# State file untuk tracking
STATE_FILE="/tmp/capslock_state_$$"
LOCK_FILE="/tmp/capslock_lock"

# Cleanup function
cleanup() {
	rm -f "$STATE_FILE" "$LOCK_FILE"
}
trap cleanup EXIT

# Prevent multiple instances
if ! mkdir "$LOCK_FILE" 2>/dev/null; then
	exit 0
fi

# Fungsi untuk detect caps lock state yang lebih robust
get_capslock_state() {
	# Method 1: xset (primary)
	if command -v xset &>/dev/null; then
		if xset q 2>/dev/null | grep -q "Caps Lock:.*on"; then
			echo "on"
			return
		fi
	fi

	# Method 2: hyprctl (fallback untuk Hyprland)
	if command -v hyprctl &>/dev/null; then
		local devices=$(hyprctl devices -j 2>/dev/null)
		if echo "$devices" | grep -q '"capsLock": true'; then
			echo "on"
			return
		fi
	fi

	# Method 3: /sys/class/leds (hardware fallback)
	if [[ -f /sys/class/leds/input*::capslock/brightness ]]; then
		local brightness=$(cat /sys/class/leds/input*::capslock/brightness 2>/dev/null | head -n1)
		if [[ "$brightness" == "1" ]]; then
			echo "on"
			return
		fi
	fi

	echo "off"
}

# **FIX: Tunggu sebentar agar state sempat update di sistem**
sleep 0.05

# Get current state
CURRENT_STATE=$(get_capslock_state)

# Read previous state
PREV_STATE="off"
[[ -f "$STATE_FILE" ]] && PREV_STATE=$(cat "$STATE_FILE")

# Only act if state actually changed
if [[ "$CURRENT_STATE" != "$PREV_STATE" ]]; then
	if [[ "$CURRENT_STATE" == "on" ]]; then
		# Caps Lock NYALA
		swayosd-client --caps-lock on 2>/dev/null &

		# Persistent notification dengan ID unik
		notify-send \
			-a "System" \
			-u critical \
			-t 0 \
			-r 9991 \
			-i dialog-warning \
			"🔒 CAPS LOCK AKTIF" \
			"Caps Lock sedang menyala" &
	else
		# Caps Lock MATI
		swayosd-client --caps-lock off 2>/dev/null &

		# Close persistent notification
		notify-send \
			-a "System" \
			-u low \
			-t 500 \
			-r 9991 \
			"" "" &
	fi

	# Save new state
	echo "$CURRENT_STATE" >"$STATE_FILE"
fi

# Cleanup lock
rmdir "$LOCK_FILE" 2>/dev/null
exit 0
