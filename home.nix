{ config, lib, pkgs, ... }:
let
  nvimRepoPath = "/home/lajna/Personal/nvim";
in
{
  imports = [ ./hyprland.nix ];

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
  xdg.configFile."btop".source = ./dots/btop;
  xdg.configFile."fastfetch".source = ./dots/fastfetch;
  xdg.configFile."matugen".source = ./dots/matugen;
  xdg.configFile."swaync".source = ./dots/swaync;
  xdg.configFile."waybar".source = ./dots/waybar;
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
  programs.git = {
    enable = true;
    package = null;
    settings = {
      user.name = "Linus Jansson";
      user.email = "34426335+LajnaLegenden@users.noreply.github.com";
      core.editor = "nano";
    };
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
