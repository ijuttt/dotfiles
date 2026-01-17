#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Using playerctl for both controls and metadata

music_icon="$HOME/.config/swaync/icons/music.png"

# Get prioritized player
get_player() {
	all_players=$(playerctl -l 2>/dev/null)

	# Prioritas 1: Spotify
	if echo "$all_players" | grep -q "spotify"; then
		echo "spotify"
		return
	fi

	# Prioritas 2: Brave
	if echo "$all_players" | grep -q -i "$browser"; then
		echo "$all_players" | grep -i "$browser" | head -n1
		return
	fi

	# Prioritas 3: Player lain yang pertama
	echo "$all_players" | head -n1
}

# Play the next track
play_next() {
	player=$(get_player)
	if [[ -n "$player" ]]; then
		playerctl -p "$player" next 2>/dev/null
		if [[ $? -eq 0 ]]; then
			sleep 0.3 # Kasih waktu metadata update
			show_music_notification
		else
			notify-send -e -u low -i "$music_icon" "Media Control" "Failed to skip to next track"
		fi
	else
		notify-send -e -u low -i "$music_icon" "No Player" "No active media player found"
	fi
}

# Play the previous track
play_previous() {
	player=$(get_player)
	if [[ -n "$player" ]]; then
		# Simpan track sebelumnya untuk deteksi perubahan
		old_track=$(playerctl -p "$player" metadata title 2>/dev/null)
		old_position=$(playerctl -p "$player" position 2>/dev/null)

		playerctl -p "$player" previous 2>/dev/null
		exit_code=$?

		if [[ $exit_code -eq 0 ]]; then
			sleep 0.5 # Kasih waktu lebih lama untuk previous
			new_track=$(playerctl -p "$player" metadata title 2>/dev/null)
			new_position=$(playerctl -p "$player" position 2>/dev/null)

			# Cek apakah track berubah ATAU posisi direset ke awal
			if [[ "$old_track" != "$new_track" ]] || [[ "${new_position%.*}" -lt "${old_position%.*}" ]]; then
				show_music_notification
			else
				notify-send -e -u low -i "$music_icon" "Media Control" "Already at first track"
			fi
		else
			notify-send -e -u low -i "$music_icon" "Media Control" "Player doesn't support previous command"
		fi
	else
		notify-send -e -u low -i "$music_icon" "No Player" "No active media player found"
	fi
}

# Toggle play/pause
toggle_play_pause() {
	player=$(get_player)
	if [[ -n "$player" ]]; then
		playerctl -p "$player" play-pause 2>/dev/null
		if [[ $? -eq 0 ]]; then
			sleep 0.2
			show_music_notification
		else
			notify-send -e -u low -i "$music_icon" "Media Control" "Failed to toggle play/pause"
		fi
	else
		notify-send -e -u low -i "$music_icon" "No Player" "No active media player found"
	fi
}

# Stop playback
stop_playback() {
	player=$(get_player)
	if [[ -n "$player" ]]; then
		playerctl -p "$player" stop
		notify-send -e -u low -i "$music_icon" "Playback:" "Stopped"
	else
		notify-send -e -u low -i "$music_icon" "No Player" "No active media player found"
	fi
}

# Display notification with song information
show_music_notification() {
	player=$(get_player)

	if [[ -z "$player" ]]; then
		notify-send -e -u low -i "$music_icon" "Media Control" "No active player for metadata"
		return
	fi

	status=$(playerctl -p "$player" status 2>/dev/null)

	if [[ "$status" == "Playing" ]]; then
		song_title=$(playerctl -p "$player" metadata title 2>/dev/null)
		song_artist=$(playerctl -p "$player" metadata artist 2>/dev/null)
		player_name=$(echo "$player" | sed 's/\..*//' | sed 's/.*/\u&/')

		# Fallback kalau metadata kosong
		if [[ -z "$song_title" ]]; then
			song_title="Unknown Track"
		fi
		if [[ -z "$song_artist" ]]; then
			song_artist="Unknown Artist"
		fi

		notify-send -e -u low -i "$music_icon" "Now Playing ($player_name):" "$song_title by $song_artist"
	elif [[ "$status" == "Paused" ]]; then
		player_name=$(echo "$player" | sed 's/\..*//' | sed 's/.*/\u&/')
		notify-send -e -u low -i "$music_icon" "Playback ($player_name):" "Paused"
	else
		notify-send -e -u low -i "$music_icon" "Playback:" "Status unknown"
	fi
}

# Get media control action from command line argument
case "$1" in
"--nxt")
	play_next
	;;
"--prv")
	play_previous
	;;
"--pause")
	toggle_play_pause
	;;
"--stop")
	stop_playback
	;;
*)
	echo "Usage: $0 [--nxt|--prv|--pause|--stop]"
	exit 1
	;;
esac
