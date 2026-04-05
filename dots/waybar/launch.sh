#!/usr/bin/env bash

exec 200>/tmp/waybar-launch.lock
flock -n 200 || exit 0

killall waybar || true
pkill waybar || true
sleep 0.5

theme_dir="$HOME/.config/waybar/themes/ml4w-glass-center"
theme_config_file="config"
theme_style_file="style.css"
echo ":: Theme: ML4W Glass Center"

if [ -f "$theme_dir/config-custom" ]; then
    theme_config_file="config-custom"
fi
if [ -f "$theme_dir/default/style-custom.css" ]; then
    theme_style_file="style-custom.css"
fi

if [ ! -f "$HOME/.config/ml4w/settings/waybar-disabled" ]; then
    HYPRLAND_SIGNATURE=$(hyprctl instances -j | jq -r '.[0].instance')
    HYPRLAND_INSTANCE_SIGNATURE="$HYPRLAND_SIGNATURE" waybar -c "$theme_dir/$theme_config_file" -s "$theme_dir/default/$theme_style_file" &
else
    echo ":: Waybar disabled"
fi

flock -u 200
exec 200>&-
