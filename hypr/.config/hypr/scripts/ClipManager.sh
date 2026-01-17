#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Clipboard Manager. This script uses cliphist, rofi, and wl-copy.
# Variables
rofi_theme="$HOME/.config/rofi/config-clipboard.rasi"
msg=' CTRL DEL = cliphist del (entry)   or   ALT DEL - cliphist wipe (all)'
# Actions:
# CTRL Del to delete an entry
# ALT Del to wipe clipboard contents
# Check if rofi is already running
if pidof rofi >/dev/null; then
	pkill rofi
fi
while true; do
	result=$(
		rofi -i -dmenu \
			-kb-custom-1 "Control-Delete" \
			-kb-custom-2 "Alt-Delete" \
			-config $rofi_theme \
			-mesg "$msg" < <(cliphist list)
	)
	case "$?" in
	1)
		exit
		;;
	0)
		case "$result" in
		"")
			continue
			;;
		*)
			# Ambil urutan dari clipboard history
			clipboard_num=$(cliphist list | grep -n "^$result" | cut -d: -f1)

			# Ambil preview teks (max 50 karakter)
			preview_text=$(cliphist decode <<<"$result" | head -c 50)

			# Jika lebih dari 50 karakter, tambah ellipsis
			if [ $(cliphist decode <<<"$result" | wc -c) -gt 50 ]; then
				preview_text="${preview_text}..."
			fi

			# Copy ke clipboard
			cliphist decode <<<"$result" | wl-copy

			# Kirim notifikasi
			notify-send "Clipboard #$clipboard_num" "$preview_text" -t 3000
			exit
			;;
		esac
		;;
	10)
		cliphist delete <<<"$result"
		notify-send "Clipboard" "🗑️ Entry berhasil dihapus" -t 2000
		;;
	11)
		cliphist wipe
		notify-send "Clipboard" "🧹 Semua clipboard history terhapus" -t 2000
		;;
	esac
done
