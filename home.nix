{ config, lib, pkgs, ... }:
let
  nvimRepoPath = "/home/lajna/Personal/nvim";
in
{
  imports = [ ./hyprland.nix ];

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
    presets = [ "jetpack" ];
    settings = { };
  };
  home.file = { };

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
