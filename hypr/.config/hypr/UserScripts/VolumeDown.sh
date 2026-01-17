#!/bin/bash
while true; do
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-
	sleep 0.05
done
