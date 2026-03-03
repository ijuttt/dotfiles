#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Screenshots scripts
# variables
time=$(date "+%Y-%m-%d_%H-%M-%S")
dir="$HOME/Pictures/Screenshots"
file="${time}.png"
iDIR="$HOME/.config/swaync/icons"
iDoR="$HOME/.config/swaync/images"
sDIR="$HOME/.config/hypr/scripts"

notify_cmd_base="notify-send -t 10000 -A action1=Open -A action2=Delete -h string:x-canonical-private-synchronous:shot-notify"
notify_cmd_shot="${notify_cmd_base} -i ${iDIR}/picture.png "
notify_cmd_shot_win="${notify_cmd_base} -i ${iDIR}/picture.png "
notify_cmd_NOT="notify-send -u low -i ${iDoR}/note.png "

# notify and view screenshot
notify_view() {
	if [[ "$1" == "swappy" ]]; then
		"${sDIR}/Sounds.sh" --screenshot
		resp=$(${notify_cmd_shot} "Screenshot Saved" "Captured by Swappy")
		case "$resp" in
		action1)
			swappy -f - <"$tmpfile"
			;;
		action2)
			rm "$tmpfile"
			;;
		esac
	else
		local check_file="${dir}/${file}"
		if [[ -e "$check_file" ]]; then
			"${sDIR}/Sounds.sh" --screenshot
			resp=$(timeout 5 ${notify_cmd_shot} "Screenshot Saved" "${check_file}")
			case "$resp" in
			action1)
				xdg-open "${check_file}" &
				;;
			action2)
				rm "${check_file}" &
				;;
			esac
		else
			${notify_cmd_NOT} "Screenshot Failed" "Could not save screenshot"
			"${sDIR}/Sounds.sh" --error
		fi
	fi
}

# countdown
countdown() {
	for sec in $(seq $1 -1 1); do
		notify-send -h string:x-canonical-private-synchronous:shot-notify -t 1000 -i "$iDIR"/timer.png "Taking shot" "in: $sec secs"
		sleep 1
	done
}

# take shots
shotnow() {
	cd ${dir} && grim - | tee "$file" | wl-copy
	notify_view
	sleep 2
}

shot5() {
	countdown '5'
	cd ${dir} && grim - | tee "$file" | wl-copy
	notify_view
}

shot10() {
	countdown '10'
	sleep 1 && cd ${dir} && grim - | tee "$file" | wl-copy
	notify_view
}

shotwin() {
	w_pos=$(hyprctl activewindow | grep 'at:' | cut -d':' -f2 | tr -d ' ' | tail -n1)
	w_size=$(hyprctl activewindow | grep 'size:' | cut -d':' -f2 | tr -d ' ' | tail -n1 | sed s/,/x/g)
	cd ${dir} && grim -g "$w_pos $w_size" - | tee "$file" | wl-copy
	notify_view
}

shotarea() {
	tmpfile=$(mktemp)
	grim -g "$(slurp)" - >"$tmpfile"
	# Copy with saving
	if [[ -s "$tmpfile" ]]; then
		wl-copy <"$tmpfile"
		mv "$tmpfile" "$dir/$file"
	fi
	notify_view
}

shotactive() {
	hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | grim -g - - | tee "${dir}/${file}" | wl-copy
	notify_view
}

shotswappy() {
	tmpfile=$(mktemp)
	grim -g "$(slurp)" - >"$tmpfile"
	# Copy without saving
	if [[ -s "$tmpfile" ]]; then
		wl-copy <"$tmpfile"
		notify_view "swappy"
	fi
}

if [[ ! -d "$dir" ]]; then
	mkdir -p "$dir"
fi

case "$1" in
--now)
	shotnow
	;;
--in5)
	shot5
	;;
--in10)
	shot10
	;;
--win)
	shotwin
	;;
--area)
	shotarea
	;;
--active)
	shotactive
	;;
--swappy)
	shotswappy
	;;
*)
	echo -e "Available Options : --now --in5 --in10 --win --area --active --swappy"
	;;
esac
exit 0
