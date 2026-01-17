#!/bin/bash

# Array of network managers to try in order
declare -a MANAGERS=("iwgtk" "nm-applet" "nmtui" "nm-connection-editor")

# Function to check if command exists
command_exists() {
	command -v "$1" &>/dev/null
}

# Try each manager
for manager in "${MANAGERS[@]}"; do
	if command_exists "$manager"; then
		# Check if it's already running (for GUI apps)
		if [[ "$manager" == "iwgtk" ]] || [[ "$manager" == "nm-applet" ]]; then
			if ! pgrep -x "$manager" >/dev/null; then
				"$manager" &
			else
				# If already running, bring window to focus or toggle
				pkill -f "$manager"
				sleep 0.5
				"$manager" &
			fi
		else
			# Terminal apps - just run
			"$manager"
		fi
		exit 0
	fi
done

# Fallback if nothing found
notify-send "Error" "No network manager found. Install iwgtk, nm-applet, or nmtui"
exit 1
