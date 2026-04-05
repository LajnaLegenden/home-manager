{ lib, ... }:
let
  mainMod = "SUPER";

  directions = [
    { key = "left"; vim = "H"; dir = "l"; resize = "-40 0"; }
    { key = "right"; vim = "L"; dir = "r"; resize = "40 0"; }
    { key = "up"; vim = "K"; dir = "u"; resize = "0 -40"; }
    { key = "down"; vim = "J"; dir = "d"; resize = "0 40"; }
  ];

  workspaceKeys =
    map
      (n: {
        key = toString (if n == 10 then 0 else n);
        ws = toString n;
      })
      (lib.range 1 10);

  moveFocusBinds = lib.concatMap
    (d: [
      "${mainMod}, ${d.key}, movefocus, ${d.dir}"
      "${mainMod}, ${d.vim}, movefocus, ${d.dir}"
    ])
    directions;

  resizeBinds = lib.concatMap
    (d: [
      "${mainMod} ALT, ${d.key}, resizeactive, ${d.resize}"
    ])
    directions;

  workspaceBinds = lib.concatMap
    (w: [
      "${mainMod}, ${w.key}, workspace, ${w.ws}"
      "${mainMod} SHIFT, ${w.key}, movetoworkspace, ${w.ws}"
    ])
    workspaceKeys;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    settings = {
      "$mainMod" = mainMod;
      bind =
        [
          "${mainMod}, RETURN, exec, alacritty"
          "${mainMod}, W, killactive,"
          "${mainMod}, V, togglefloating,"
          "${mainMod}, SPACE, exec, run-or-notify vicinae toggle"
          "${mainMod}, T, exec, run-or-notify firefox"
          "${mainMod}, I, togglesplit,"

          "${mainMod} CTRL, H, movecurrentworkspacetomonitor, l"
          "${mainMod} CTRL, L, movecurrentworkspacetomonitor, r"

          "${mainMod}, S, togglespecialworkspace, magic"
          "${mainMod} SHIFT, S, movetoworkspace, special:magic"

          "${mainMod}, mouse_down, workspace, e+1"
          "${mainMod}, mouse_up, workspace, e-1"

          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"

          ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5% && ~/.sh/volume.sh"
          ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5% && ~/.sh/volume.sh"
          ", XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle && ~/.sh/volume.sh"

          ", XF86MonBrightnessUp, exec, brightnessctl set +5% && ~/.sh/brightness.sh"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%- && ~/.sh/brightness.sh"
        ]
        ++ moveFocusBinds
        ++ workspaceBinds;

      binde = resizeBinds;

      workspace = map
        (w: "${w}, gapsout:0, gapsin:0, border:0, rounding:0")
        [
          "w[t1]"
          "w[tg1]"
        ];

      bindm = [
        "${mainMod}, mouse:272, movewindow"
        "${mainMod}, mouse:273, resizewindow"
      ];

      input = {
        kb_layout = "se";
        follow_mouse = 1;
        kb_options = "meta:nocaps";
        touchpad = {
          natural_scroll = false;
        };
        sensitivity = 0;
      };

      env = [
        "ELECTRON_EXTRA_LAUNCH_ARGS,--password-store=kwallet"
        "GDK_BACKEND,wayland,x11,*"
        "CLUTTER_BACKEND,wayland"
        "SDL_VIDEODRIVER,wayland"
        "ELECTRON_OZONE_PLATFORM_HINT,wayland"
        "OZONE_PLATFORM,wayland"
        "HYPRCURSOR_SIZE,24"
        "XCURSOR_SIZE,24"
        "MOZ_ENABLE_WAYLAND,1"
        "GDK_SCALE,1"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_QPA_PLATFORMTHEME,qt6ct"
        "QT_QPA_PLATFORMTHEME,qt5ct"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
      ];

      exec-once = [
        "vicinae server"
        "swaync"
        "hypridle"
        "wl-paste --watch cliphist store"
        "sunsetr"
      ];

      misc = {
        force_default_wallpaper = 1;
        vfr = true;
        vrr = true;
      };
    };
  };
}
