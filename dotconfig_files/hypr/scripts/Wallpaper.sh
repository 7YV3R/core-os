#!/usr/bin/env bash

current_session=$XDG_CURRENT_DESKTOP
WALLPAPER_DIR=${HOME}/Bilder/wallpapers

set_wallpaper_hyprland() {
	BG="$(find "$WALLPAPER_DIR" -name '*.jpg' -o -name '*.png' | shuf -n1)"
	PROGRAM="swww-daemon"
	trans_type="simple"

	if pgrep "$PROGRAM" >/dev/null; then
		swww img "$BG" --transition-fps 244 --transition-type $trans_type --transition-duration 1
	else
		swww-daemon && swww img "$BG" --transition-fps 244 --transition-type $trans_type --transition-duration 1
	fi
}

set_wallpaper_hyprland
