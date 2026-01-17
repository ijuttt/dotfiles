#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
#
# Modified for Ncpamixer Dropdown
# Usage: ./Dropdown_Ncpamixer.sh [-d]
# Example: ./Dropdown_Ncpamixer.sh
#          ./Dropdown_Ncpamixer.sh -d (with debug output)

DEBUG=false
SPECIAL_WS="special:discord"
ADDR_FILE="/tmp/dropdown_ncpamixer_addr"

# Dropdown size and position configuration (percentages)
WIDTH_PERCENT=50  # Width as percentage of screen width
HEIGHT_PERCENT=60 # Height as percentage of screen height
Y_PERCENT=5       # Y position as percentage from top (X is auto-centered)

# Animation settings (matching Hyprland config bezier curve timing)
# Hyprland uses: bezier = quart, 0.25, 1, 0.5, 1
# animation = windows, 1, 6, quart (6 = speed multiplier)
SLIDE_STEPS=1
STEP_DELAY=0.0001

# Ncpamixer command - adjust if needed
NCPAMIXER_CMD="kitty --class ncpamixer -e ncpamixer"

# Parse arguments
if [ "$1" = "-d" ]; then
	DEBUG=true
	shift
fi

# Debug echo function
debug_echo() {
	if [ "$DEBUG" = true ]; then
		echo "$@"
	fi
}

# Function to get window geometry
get_window_geometry() {
	local addr="$1"
	hyprctl clients -j | jq -r --arg ADDR "$addr" '.[] | select(.address == $ADDR) | "\(.at[0]) \(.at[1]) \(.size[0]) \(.size[1])"'
}

# Function to animate window slide down (show)
animate_slide_down() {
	local addr="$1"
	local target_x="$2"
	local target_y="$3"
	local width="$4"
	local height="$5"

	debug_echo "Animating slide down for window $addr to position $target_x,$target_y"

	# Start position (above screen)
	local start_y=$((target_y - height - 50))

	# Calculate step size
	local step_y=$(((target_y - start_y) / SLIDE_STEPS))

	# Move window to start position instantly (off-screen)
	hyprctl dispatch movewindowpixel "exact $target_x $start_y,address:$addr" >/dev/null 2>&1
	sleep 0.02

	# Animate slide down
	for i in $(seq 1 $SLIDE_STEPS); do
		local current_y=$((start_y + (step_y * i)))
		hyprctl dispatch movewindowpixel "exact $target_x $current_y,address:$addr" >/dev/null 2>&1
		sleep $STEP_DELAY
	done

	# Ensure final position is exact
	hyprctl dispatch movewindowpixel "exact $target_x $target_y,address:$addr" >/dev/null 2>&1
}

# Function to animate window slide up (hide)
animate_slide_up() {
	local addr="$1"
	local start_x="$2"
	local start_y="$3"
	local width="$4"
	local height="$5"

	debug_echo "Animating slide up for window $addr from position $start_x,$start_y"

	# End position (above screen)
	local end_y=$((start_y - height - 50))

	# Calculate step size
	local step_y=$(((start_y - end_y) / SLIDE_STEPS))

	# Animate slide up
	for i in $(seq 1 $SLIDE_STEPS); do
		local current_y=$((start_y - (step_y * i)))
		hyprctl dispatch movewindowpixel "exact $start_x $current_y,address:$addr" >/dev/null 2>&1
		sleep $STEP_DELAY
	done

	debug_echo "Slide up animation completed"
}

# Function to get monitor info including scale and name of focused monitor
get_monitor_info() {
	local monitor_data=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.x) \(.y) \(.width) \(.height) \(.scale) \(.name)"')
	if [ -z "$monitor_data" ] || [[ "$monitor_data" =~ ^null ]]; then
		debug_echo "Error: Could not get focused monitor information"
		return 1
	fi
	echo "$monitor_data"
}

# Function to calculate dropdown position with proper scaling and centering
calculate_dropdown_position() {
	local monitor_info=$(get_monitor_info)

	if [ $? -ne 0 ] || [ -z "$monitor_info" ]; then
		debug_echo "Error: Failed to get monitor info, using fallback values"
		echo "100 100 800 600 fallback-monitor"
		return 1
	fi

	local mon_x=$(echo $monitor_info | cut -d' ' -f1)
	local mon_y=$(echo $monitor_info | cut -d' ' -f2)
	local mon_width=$(echo $monitor_info | cut -d' ' -f3)
	local mon_height=$(echo $monitor_info | cut -d' ' -f4)
	local mon_scale=$(echo $monitor_info | cut -d' ' -f5)
	local mon_name=$(echo $monitor_info | cut -d' ' -f6)

	debug_echo "Monitor info: x=$mon_x, y=$mon_y, width=$mon_width, height=$mon_height, scale=$mon_scale"

	# Validate scale value and provide fallback
	if [ -z "$mon_scale" ] || [ "$mon_scale" = "null" ] || [ "$mon_scale" = "0" ]; then
		debug_echo "Invalid scale value, using 1.0 as fallback"
		mon_scale="1.0"
	fi

	# Calculate logical dimensions by dividing physical dimensions by scale
	local logical_width logical_height
	if command -v bc >/dev/null 2>&1; then
		# Use bc for precise floating point calculation
		logical_width=$(echo "scale=0; $mon_width / $mon_scale" | bc | cut -d'.' -f1)
		logical_height=$(echo "scale=0; $mon_height / $mon_scale" | bc | cut -d'.' -f1)
	else
		# Fallback to integer math (multiply by 100 for precision, then divide)
		local scale_int=$(echo "$mon_scale" | sed 's/\.//' | sed 's/^0*//')
		if [ -z "$scale_int" ]; then scale_int=100; fi

		logical_width=$(((mon_width * 100) / scale_int))
		logical_height=$(((mon_height * 100) / scale_int))
	fi

	# Ensure we have valid integer values
	if ! [[ "$logical_width" =~ ^-?[0-9]+$ ]]; then logical_width=$mon_width; fi
	if ! [[ "$logical_height" =~ ^-?[0-9]+$ ]]; then logical_height=$mon_height; fi

	debug_echo "Physical resolution: ${mon_width}x${mon_height}"
	debug_echo "Logical resolution: ${logical_width}x${logical_height} (physical ÷ scale)"

	# Calculate window dimensions based on LOGICAL space percentages
	local width=$((logical_width * WIDTH_PERCENT / 100))
	local height=$((logical_height * HEIGHT_PERCENT / 100))

	# Calculate Y position from top based on percentage of LOGICAL height
	local y_offset=$((logical_height * Y_PERCENT / 100))

	# Calculate centered X position in LOGICAL space
	local x_offset=$(((logical_width - width) / 2))

	# Apply monitor offset to get final positions in logical coordinates
	local final_x=$((mon_x + x_offset))
	local final_y=$((mon_y + y_offset))

	debug_echo "Window size: ${width}x${height} (logical pixels)"
	debug_echo "Final position: x=$final_x, y=$final_y (logical coordinates)"
	debug_echo "Hyprland will scale these to physical coordinates automatically"

	echo "$final_x $final_y $width $height $mon_name"
}

# Get the current workspace
CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')

# Function to get stored ncpamixer address
get_ncpamixer_address() {
	if [ -f "$ADDR_FILE" ] && [ -s "$ADDR_FILE" ]; then
		cut -d' ' -f1 "$ADDR_FILE"
	fi
}

# Function to get stored monitor name
get_ncpamixer_monitor() {
	if [ -f "$ADDR_FILE" ] && [ -s "$ADDR_FILE" ]; then
		cut -d' ' -f2- "$ADDR_FILE"
	fi
}

# Function to check if ncpamixer exists
ncpamixer_exists() {
	local addr=$(get_ncpamixer_address)
	if [ -n "$addr" ]; then
		hyprctl clients -j | jq -e --arg ADDR "$addr" 'any(.[]; .address == $ADDR)' >/dev/null 2>&1
	else
		return 1
	fi
}

# Function to check if ncpamixer is in special workspace
ncpamixer_in_special() {
	local addr=$(get_ncpamixer_address)
	if [ -n "$addr" ]; then
		hyprctl clients -j | jq -e --arg ADDR "$addr" 'any(.[]; .address == $ADDR and .workspace.name == "special:discord")' >/dev/null 2>&1
	else
		return 1
	fi
}

# Function to find ncpamixer window by class
find_ncpamixer_window() {
	hyprctl clients -j | jq -r '.[] | select(.class == "ncpamixer") | .address' | head -1
}

# Function to spawn ncpamixer and capture its address
spawn_ncpamixer() {
	debug_echo "Creating new dropdown ncpamixer"

	# Check if ncpamixer is already running
	existing_addr=$(find_ncpamixer_window)

	if [ -n "$existing_addr" ]; then
		debug_echo "Found existing ncpamixer window: $existing_addr"

		# Calculate dropdown position
		local pos_info=$(calculate_dropdown_position)
		if [ $? -ne 0 ]; then
			debug_echo "Warning: Using fallback positioning"
		fi

		local target_x=$(echo $pos_info | cut -d' ' -f1)
		local target_y=$(echo $pos_info | cut -d' ' -f2)
		local width=$(echo $pos_info | cut -d' ' -f3)
		local height=$(echo $pos_info | cut -d' ' -f4)
		local monitor_name=$(echo $pos_info | cut -d' ' -f5)

		# Store the address and monitor name
		echo "$existing_addr $monitor_name" >"$ADDR_FILE"

		# Move to special workspace, set as floating and size
		hyprctl dispatch togglefloating "address:$existing_addr"
		hyprctl dispatch resizewindowpixel "exact $width $height,address:$existing_addr"
		hyprctl dispatch movetoworkspacesilent "$SPECIAL_WS,address:$existing_addr"

		sleep 0.2

		# Bring it back with animation
		hyprctl dispatch movetoworkspacesilent "$CURRENT_WS,address:$existing_addr"
		hyprctl dispatch pin "address:$existing_addr"
		animate_slide_down "$existing_addr" "$target_x" "$target_y" "$width" "$height"

		return 0
	fi

	# Calculate dropdown position for new window
	local pos_info=$(calculate_dropdown_position)
	if [ $? -ne 0 ]; then
		debug_echo "Warning: Using fallback positioning"
	fi

	local target_x=$(echo $pos_info | cut -d' ' -f1)
	local target_y=$(echo $pos_info | cut -d' ' -f2)
	local width=$(echo $pos_info | cut -d' ' -f3)
	local height=$(echo $pos_info | cut -d' ' -f4)
	local monitor_name=$(echo $pos_info | cut -d' ' -f5)

	debug_echo "Target position: ${target_x},${target_y}, size: ${width}x${height}"

	# Launch ncpamixer directly in special workspace to avoid visible spawn
	hyprctl dispatch exec "[float; size $width $height; workspace special:discord silent] $NCPAMIXER_CMD"

	# Wait for window to appear
	sleep 0.5

	# Find ncpamixer window
	local new_addr=$(find_ncpamixer_window)

	if [ -n "$new_addr" ] && [ "$new_addr" != "null" ]; then
		# Store the address and monitor name
		echo "$new_addr $monitor_name" >"$ADDR_FILE"
		debug_echo "Ncpamixer created with address: $new_addr in special workspace on monitor $monitor_name"

		# Small delay to ensure it's properly in special workspace
		sleep 0.2

		# Bring it back with animation
		hyprctl dispatch movetoworkspacesilent "$CURRENT_WS,address:$new_addr"
		hyprctl dispatch pin "address:$new_addr"
		animate_slide_down "$new_addr" "$target_x" "$target_y" "$width" "$height"

		return 0
	fi

	debug_echo "Failed to get ncpamixer address"
	return 1
}

# Main logic
if ncpamixer_exists; then
	NCPAMIXER_ADDR=$(get_ncpamixer_address)
	debug_echo "Found existing ncpamixer: $NCPAMIXER_ADDR"

	focused_monitor=$(get_monitor_info | awk '{print $6}')
	dropdown_monitor=$(get_ncpamixer_monitor)

	if [ "$focused_monitor" != "$dropdown_monitor" ]; then
		debug_echo "Monitor focus changed: moving dropdown to $focused_monitor"
		# Calculate new position for focused monitor
		pos_info=$(calculate_dropdown_position)
		target_x=$(echo $pos_info | cut -d' ' -f1)
		target_y=$(echo $pos_info | cut -d' ' -f2)
		width=$(echo $pos_info | cut -d' ' -f3)
		height=$(echo $pos_info | cut -d' ' -f4)
		monitor_name=$(echo $pos_info | cut -d' ' -f5)

		# Move and resize window
		hyprctl dispatch movewindowpixel "exact $target_x $target_y,address:$NCPAMIXER_ADDR"
		hyprctl dispatch resizewindowpixel "exact $width $height,address:$NCPAMIXER_ADDR"

		# Update ADDR_FILE
		echo "$NCPAMIXER_ADDR $monitor_name" >"$ADDR_FILE"
	fi

	if ncpamixer_in_special; then
		debug_echo "Bringing ncpamixer from discord with slide down animation"

		# Calculate target position
		pos_info=$(calculate_dropdown_position)
		target_x=$(echo $pos_info | cut -d' ' -f1)
		target_y=$(echo $pos_info | cut -d' ' -f2)
		width=$(echo $pos_info | cut -d' ' -f3)
		height=$(echo $pos_info | cut -d' ' -f4)

		# Use movetoworkspacesilent to avoid affecting workspace history
		hyprctl dispatch movetoworkspacesilent "$CURRENT_WS,address:$NCPAMIXER_ADDR"
		hyprctl dispatch pin "address:$NCPAMIXER_ADDR"

		# Set size and animate slide down
		hyprctl dispatch resizewindowpixel "exact $width $height,address:$NCPAMIXER_ADDR"
		animate_slide_down "$NCPAMIXER_ADDR" "$target_x" "$target_y" "$width" "$height"

		hyprctl dispatch focuswindow "address:$NCPAMIXER_ADDR"
	else
		debug_echo "Hiding ncpamixer to discord with slide up animation"

		# Get current geometry for animation
		geometry=$(get_window_geometry "$NCPAMIXER_ADDR")
		if [ -n "$geometry" ]; then
			curr_x=$(echo $geometry | cut -d' ' -f1)
			curr_y=$(echo $geometry | cut -d' ' -f2)
			curr_width=$(echo $geometry | cut -d' ' -f3)
			curr_height=$(echo $geometry | cut -d' ' -f4)

			debug_echo "Current geometry: ${curr_x},${curr_y} ${curr_width}x${curr_height}"

			# Animate slide up first
			animate_slide_up "$NCPAMIXER_ADDR" "$curr_x" "$curr_y" "$curr_width" "$curr_height"

			# Small delay then move to special workspace and unpin
			sleep 0.1
			hyprctl dispatch pin "address:$NCPAMIXER_ADDR" # Unpin (toggle)
			hyprctl dispatch movetoworkspacesilent "$SPECIAL_WS,address:$NCPAMIXER_ADDR"
		else
			debug_echo "Could not get window geometry, moving to discord without animation"
			hyprctl dispatch pin "address:$NCPAMIXER_ADDR"
			hyprctl dispatch movetoworkspacesilent "$SPECIAL_WS,address:$NCPAMIXER_ADDR"
		fi
	fi
else
	debug_echo "No existing ncpamixer found, creating new one"
	if spawn_ncpamixer; then
		NCPAMIXER_ADDR=$(get_ncpamixer_address)
		if [ -n "$NCPAMIXER_ADDR" ]; then
			hyprctl dispatch focuswindow "address:$NCPAMIXER_ADDR"
		fi
	fi
fi
