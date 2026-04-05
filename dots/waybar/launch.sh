#!/usr/bin/env bash
#                    __
#  _    _____ ___ __/ /  ___ _____
# | |/|/ / _ `/ // / _ \/ _ `/ __/
# |__,__/\_,_/\_, /_.__/\_,_/_/
#            /___/
#

# -----------------------------------------------------
# Prevent duplicate launches: only the first parallel
# invocation proceeds; all others exit immediately.
# -----------------------------------------------------

exec 200>/tmp/waybar-launch.lock
flock -n 200 || exit 0

# -----------------------------------------------------
# Quit all running waybar instances
# -----------------------------------------------------

killall waybar || true
pkill waybar || true
sleep 0.5

# -----------------------------------------------------
# Fixed theme
# -----------------------------------------------------

theme_dir="$HOME/.config/waybar/themes/ml4w-glass-center"
theme_config_file="config"
theme_style_file="style.css"
echo ":: Theme: ML4W Glass Center"

# -----------------------------------------------------
# Loading the configuration
# -----------------------------------------------------

# Standard files can be overwritten with an existing config-custom or style-custom.css
if [ -f "$theme_dir/config-custom" ]; then
    theme_config_file="config-custom"
fi
if [ -f "$theme_dir/default/style-custom.css" ]; then
    theme_style_file="style-custom.css"
fi

# Check if waybar-disabled file exists
if [ ! -f "$HOME/.config/ml4w/settings/waybar-disabled" ]; then
    HYPRLAND_SIGNATURE=$(hyprctl instances -j | jq -r '.[0].instance')
    HYPRLAND_INSTANCE_SIGNATURE="$HYPRLAND_SIGNATURE" waybar -c "$theme_dir/$theme_config_file" -s "$theme_dir/default/$theme_style_file" &
    # env GTK_DEBUG=interactive waybar -c "$theme_dir/$theme_config_file" -s "$theme_dir/default/$theme_style_file" &
else
    echo ":: Waybar disabled"
fi

# Explicitly release the lock (optional) -> flock releases on exit
flock -u 200
exec 200>&-
