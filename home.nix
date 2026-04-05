{ config, lib, pkgs, ... }:
let
  mainMod = "SUPER";

  directions = [
    { key = "left"; vim = "H"; dir = "l"; resize = "-40 0"; }
    { key = "right"; vim = "L"; dir = "r"; resize = "40 0"; }
    { key = "up"; vim = "K"; dir = "u"; resize = "0 -40"; }
    { key = "down"; vim = "J"; dir = "d"; resize = "0 40"; }
  ];
  runOrNotify = cmd: pkgs.writeShellScript "run-${cmd}" ''
    if command -v ${cmd} >/dev/null; then
      exec ${cmd}
    else
      exec notify-send "Not installed" "${cmd} is not installed"
    fi
  '';

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

  nvimRepoPath = "/home/lajna/Personal/nvim";
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "lajna";
  home.homeDirectory = "/home/lajna";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "run-or-notify" ''
      cmd="$1"
      shift

      if command -v "$cmd" >/dev/null; then
        exec "$cmd" "$@"
      else
        exec notify-send "Not installed" "$cmd is not installed"
      fi
    '')
    fnm
    gnome-themes-extra
    imagemagick
    grimblast
    swaynotificationcenter
    font-awesome
    # add fira code ned font
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];
  home.activation.cloneNvimRepo = ''
    if [ ! -d "${nvimRepoPath}" ]; then
      echo "Cloning Neovim config..."
      mkdir -p /home/lajna/Personal
       GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh" \
      ${pkgs.git}/bin/git clone git@github.com:LajnaLegenden/nvim.git ${nvimRepoPath}
    fi
  '';

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink nvimRepoPath;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 100000;
      save = 100000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      share = true;
    };
    initContent = ''
      eval "$(fnm env)"
    '';
  };
  programs.starship = {
    enable = true;
    # Configuration written to ~/.config/starship.toml
    enableInteractive = true;
    presets = [ "jetpack" ];
    settings = {
      # add_newline = false;

      # character = {
      #   success_symbol = "[➜](bold green)";
      #   error_symbol = "[➜](bold red)";
      # };

      # package.disabled = true;
    };
  };
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/lajna/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.alacritty = {
    enable = true;
    package = null; # 👈 prevents Home Manager from installing it
    settings = {
      window.opacity = 0.9;
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold Italic";
        };
        size = 12;
      };
    };
  };
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
          # "${mainMod} SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy"
          # "${mainMod}, N, exec, swaync-client -t -sw"

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
    programs.git = {
        userName = "Linus Jansson"; # Replace with actual work name
        userEmail = "34426335+LajnaLegenden@users.noreply.github.com"; # Replace with actual work email
        extraConfig = {
          core.editor = "nano";
        };
      };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
