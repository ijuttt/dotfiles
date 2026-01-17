#!/bin/bash
# File untuk tracking apakah notif udah dikirim (biar ga spam)
NOTIF_FILE="/tmp/battery_notif_sent"

for i in {0..3}; do
	if [ -f /sys/class/power_supply/BAT$i/capacity ]; then
		battery_status=$(cat /sys/class/power_supply/BAT$i/status)
		battery_capacity=$(cat /sys/class/power_supply/BAT$i/capacity)

		# Display untuk waybar/hyprlock (output normal)
		echo "Battery: $battery_capacity% ($battery_status)"

		# Kirim notif kalo battery low DAN ga lagi charging
		if [ "$battery_capacity" -le 30 ] && [ "$battery_status" != "Charging" ]; then
			if [ ! -f "${NOTIF_FILE}_30" ]; then
				notify-send -u normal -i battery-low "⚠️ Battery Low" "Battery at ${battery_capacity}%"
				touch "${NOTIF_FILE}_30"
			fi
		fi

		if [ "$battery_capacity" -le 15 ] && [ "$battery_status" != "Charging" ]; then
			if [ ! -f "${NOTIF_FILE}_15" ]; then
				notify-send -u critical -i battery-caution "🔋 Battery Critical!" "Battery at ${battery_capacity}% - Charge now!"
				touch "${NOTIF_FILE}_15"
			fi
		fi

		if [ "$battery_capacity" -le 10 ] && [ "$battery_status" != "Charging" ]; then # ← UBAH 5 jadi 10
			if [ ! -f "${NOTIF_FILE}_10" ]; then                                          # ← UBAH _5 jadi _10
				notify-send -u critical -i battery-empty "⚡ Battery Emergency!" "Battery at ${battery_capacity}% - System will shutdown soon!"
				touch "${NOTIF_FILE}_10" # ← UBAH _5 jadi _10
			fi
		fi

		# Reset notif flag kalo lagi charging atau battery naik
		if [ "$battery_status" == "Charging" ] || [ "$battery_capacity" -gt 30 ]; then
			rm -f "${NOTIF_FILE}_30" "${NOTIF_FILE}_15" "${NOTIF_FILE}_10" 2>/dev/null # ← UBAH _5 jadi _10
		fi

	fi
done
