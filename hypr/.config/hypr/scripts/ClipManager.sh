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

# Thumbnail directory for image previews
cache_dir="/tmp/cliphist-thumbs"
mkdir -p "$cache_dir"

# Screenshots directory
scr_dir="$HOME/Pictures/Screenshots"

# Generate rofi menu entries
# For image entries: decode to thumbnail and attach as icon (same pattern as WallpaperSelect.sh)
# For text entries: pass through as-is
menu() {
    cliphist list | head -n 50 | while IFS= read -r line; do
        if [[ "$line" == *"[[ binary data"* ]]; then
            id=$(printf '%s' "$line" | cut -f1)
            thumb="$cache_dir/${id}.png"
            if [[ ! -f "$thumb" ]]; then
                printf '%s' "$line" | cliphist decode > "$thumb" 2>/dev/null
            fi
            
            # Try to match with actual file in Screenshots folder
            match=""
            if [[ -d "$scr_dir" ]]; then
                size=$(stat -c%s "$thumb" 2>/dev/null)
                md5=$(md5sum "$thumb" 2>/dev/null | cut -d' ' -f1)
                # Filter by size first for speed, then md5 check on candidates
                # awk handles multiple spaces from md5sum reliably
                match=$(find "$scr_dir" -maxdepth 1 -type f -size "${size}c" -exec md5sum {} + 2>/dev/null | grep "^$md5" | head -n1 | awk '{print $2}')
            fi
            
            if [[ -n "$match" ]]; then
                label=$(basename "$match")
            else
                # Fallback to metadata if no match: e.g. "82 KiB png 770x611"
                label=$(printf '%s' "$line" | grep -oP '\[\[ binary data \K[^\]]+' | sed 's/\s*$//')
            fi
            
            printf "%s\x00icon\x1f%s\n" "$label" "$thumb"
        else
            # Strip ID and leading/trailing whitespace for cleaner text view
            content=$(printf '%s' "$line" | cut -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            printf '%s\n' "$content"
        fi
    done
}

while true; do
	result=$(menu | rofi -i -dmenu \
		-show-icons \
		-kb-custom-1 "Control-Delete" \
		-kb-custom-2 "Alt-Delete" \
		-config "$rofi_theme" \
		-mesg "$msg" \
		-format i)

	exit_code=$?

	if [[ $exit_code -eq 1 ]]; then
		exit 0
	fi

	# Map rofi index (0-based) back to original cliphist entry
	original_line=$(cliphist list | head -n 50 | sed -n "$((result + 1))p")

	case "$exit_code" in
	0)
		case "$original_line" in
		"")
			continue
			;;
		*)
			# Ambil preview teks (max 50 karakter)
			preview_text=$(printf '%s' "$original_line" | cliphist decode | head -c 50)

			# Jika lebih dari 50 karakter, tambah ellipsis
			if [ $(printf '%s' "$original_line" | cliphist decode | wc -c) -gt 50 ]; then
				preview_text="${preview_text}..."
			fi

			# Copy ke clipboard
			printf '%s' "$original_line" | cliphist decode | wl-copy

			# Kirim notifikasi
			notify-send "Clipboard" "$preview_text" -t 3000
			exit 0
			;;
		esac
		;;
	10)
		cliphist delete <<<"$original_line"
		notify-send "Clipboard" "🗑️ Entry berhasil dihapus" -t 2000
		;;
	11)
		cliphist wipe
		rm -rf "$cache_dir"/*
		notify-send "Clipboard" "🧹 Semua clipboard history terhapus" -t 2000
		;;
	esac
done
