{ config, lib, pkgs, ... }:
let
  nvimRepoPath = "/home/lajna/Personal/nvim";
in
{
  imports = [
    ./hyprland.nix
    ./hyprlock.nix
  ];

  home.username = "lajna";
  home.homeDirectory = "/home/lajna";

  home.stateVersion = "25.11";

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
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
  ];
  home.activation.cloneNvimRepo = ''
    if [ ! -d "${nvimRepoPath}" ]; then
      echo "Cloning Neovim config..."
      mkdir -p /home/lajna/Personal
       GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh" \
      ${pkgs.git}/bin/git clone git@github.com:LajnaLegenden/nvim.git ${nvimRepoPath}
    fi
  '';
  home.activation.setWaybarScriptPerms = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    scripts_dir="${config.xdg.configHome}/waybar/scripts"
    if [ -d "$scripts_dir" ]; then
      find "$scripts_dir" -type f -exec chmod 755 {} +
    fi
  '';
  home.activation.prepareMatugenCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${config.home.homeDirectory}/.cache/ml4w/matugen/waybar"
    mkdir -p "${config.home.homeDirectory}/.cache/ml4w/matugen/swaync"

    touch "${config.home.homeDirectory}/.cache/ml4w/matugen/waybar/colors.css"
    touch "${config.home.homeDirectory}/.cache/ml4w/matugen/swaync/colors.css"
  '';

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink nvimRepoPath;
  xdg.configFile."btop".source = ./dots/btop;
  xdg.configFile."fastfetch".source = ./dots/fastfetch;
  xdg.configFile."matugen".source = ./dots/matugen;
  xdg.configFile."swaync".source = ./dots/swaync;
  xdg.configFile."waybar".source = ./dots/waybar;
  xdg.configFile."scripts".source = ./dots/scripts;
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
    presets = [ "jetpack" ];
    settings = { };
  };
  home.file."Pictures/wallpapers".source = ./wallpapers;

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.alacritty = {
    enable = true;
    package = null;
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
  programs.home-manager.enable = true;
}
