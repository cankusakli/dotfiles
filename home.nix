{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    # the font everything renders in
    nerd-fonts.hack
    # sourced manually from ~/.zshrc - zsh itself stays unmanaged, see below
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];
  fonts.fontconfig.enable = true;

  # zsh/starship are intentionally left unmanaged here - ~/.zshrc already has
  # substantial hand-written setup (PATH, Grafana MCP switching, secrets
  # loading, the claude-1m-fix wrapper) that home-manager would clobber.

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/CLAUDE.md";

  # Stable, fixed paths for ~/.zshrc to source manually - home-manager keeps
  # these pointed at the right package version on every switch, so .zshrc
  # never has to guess a nix store/profile path itself.
  home.file.".config/zsh-plugins/zsh-autosuggestions.zsh".source =
    "${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh";
  home.file.".config/zsh-plugins/zsh-syntax-highlighting.zsh".source =
    "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
}
