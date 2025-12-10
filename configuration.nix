
{ config, pkgs, ... }:

# ----- [ IMPORTS ] ------------------------------
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

# ----- [ BOOTLOADER ] ------------------------------
  # Set Bootloader to systemd boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

# ----- [ KERNEL and FIRMWARE ] ------------------------------
  # Set kernel to latest release
  boot.kernelPackages = pkgs.linuxPackages_lts;
  #boot.kernelPackages = pkgs.linuxPackages_latest; # If you have newer hardware
  hardware.firmware = [ pkgs.linux-firmware ];

# ----- [ HOSTNAME ] ------------------------------
  # Set up hostname
  networking.hostName = "monolith";

# ----- [ NETWORKING AND WIFI ] ------------------------------
  # Set up network manager
  networking.networkmanager.enable = true;

# ----- [ TIME AND INTERNATIONALIZATION ] ------------------------------
  # Timezone
  time.timeZone = "America/Chicago";
  # internationalization stuff
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

# ----- [ DISPLAY MANAGER ] ------------------------------
# Could be set to others like LY, but LY has bugs
services.displayManager.sddm.enable = true;

# ----- [ KDE PLASMA ] ------------------------------
  # Add KDE Plasma desktop for non technical users of PC
  services.desktopManager.plasma6.enable = true;

# ----- [ DRIVER CONFIG ] ------------------------------
# Nivida ( Uncomment if using nvidia GPU )
# hardware = {
#    graphics.enable = true;
#    nvidia.modesetting.enable = true;
#    nvidia.nvidiaSettings = true;
#    nvidia.package = #config.boot.kernelPackages.nvidiaPackages.stable;
#    nvidia.open = false; # If GPU is new enough, set to true
#  };

# AMD ( Uncomment if using AMD GPU )
# hardware = {
#    graphics.enable = true;
#    graphics.enable32Bit = true;
#    amdgpu.opencl.enable = true;
#    amdgpu.initrd.enable = true; # sets boot.initrd.kernelModules = ["amdgpu"];
#    amdgpu.legacySupport.enable = true; # Only use for Southern islands or Sea islands GPUs
#  };

# ----- [ ROCm / HIP WORKAROUND ] ------------------------------
# Workaround for software that hardcodes /opt/rocm (e.g., HIP/ROCm apps) from NixOS docs
# Only for AMD GPUS. For AI usage
#systemd.tmpfiles.rules =
#let
#  rocmEnv = pkgs.symlinkJoin {
#    name = "rocm-combined";
#    paths = with pkgs.rocmPackages; [
#      rocblas
#      hipblas
#      clr
#    ];
#  };
#in [
#  "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
#];

# ----- [ XDG PORTALS ] ------------------------------
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-kde];

# ----- [ SUID WRAPPERS ] ------------------------------
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };

# ----- [ USER ACCOUNTS ] ------------------------------
  # Don't forget to set a password with ‘passwd’.
  users.users.monoUser = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "User for monolithic config";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
       gparted
    ];
  };
  users.users.guest = {
    shell = pkgs.bash;
    isNormalUser = true;
    description = "guest user for monolith config";
    extraGroups = [  ];
    packages = with pkgs; [
    ];
  };

# ----- [ PROGRAMS ] ------------------------------
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  #fonts
  fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
  ];

  # Installed Packages
  environment.systemPackages = with pkgs; [

  # Terminal Emulators
  alacritty
  foot
  kitty

  # File Managers & Text Editors (CLI + GUI)
  kdePackages.dolphin
  kdePackages.kate
  nano
  neovim
  ranger
  vim

  # System Info & Eye Candy
  asciiquarium
  btop
  bottom
  cmatrix
  fastfetch
  htop
  lolcat
  procs

  # Web & Media
  chromium
  firefox
  mpv
  vlc
  yt-dlp

  # Productivity & Office
  anki
  calibre
  libreoffice-qt-fresh
  obsidian
  spotify
  thunderbird
  zathura

  # Core CLI Utilities
  curl
  git
  gnupg
  less
  unzip
  wget

  # Modern CLI Replacements
  bat           # cat with syntax highlighting
  delta         # git diff highlighter
  eza           # modern ls
  fd            # simple, fast find
  fzf           # fuzzy finder
  ripgrep       # recursive grep
  zoxide        # smarter cd

  # Development and Container Tools
  direnv
  docker
  lazydocker    # TUI for Docker/Podman
  nixpkgs-fmt
  podman        # Docker alternative (rootless by default)
  vscode

  # Gaming
  gamemode
  godot
  lutris
  mangohud
  protonup-qt
  steam
  steam-run
  superTuxKart

  # Creative & Multimedia
  audacity
  blender
  gimp
  handbrake
  inkscape
  krita
  obs-studio

  # System Maintenance & Hardware
  lm_sensors
  pciutils       # lspci
  pavucontrol
  smartmontools
  usbutils       # lsusb

  # Security & Privacy
  keepassxc
  tor-browser
  yubikey-manager

  # Runtime & Compatibility
  gnome-boxes    # virtual machines
  wine

  # Nix Eco Utilities
  nix-index
  nix-index-completion
  nix-tree

  # Custom Monolith Script, powers: "cleanUp" command
  (writeScriptBin "cleanUpOldGen" ''
    #!${stdenv.shell}
    set -euo pipefail
    PROFILE="/nix/var/nix/profiles/system"
    ROOTS_DIR="/nix/var/nix/gcroots"
    # Remove old pinned GC roots
    find "$ROOTS_DIR" -maxdepth 1 -name "system-gen-*" -delete
    # Get the last 3 generation numbers
    gens=$(nix-env --list-generations --profile "$PROFILE" | tail -3 | awk '{print $1}')
    # Pin them as GC roots
    for gen in $gens; do
        ln -sf "$PROFILE-$gen-link" "$ROOTS_DIR/system-gen-$gen"
    done
    # Run garbage collection (older than 14 days)
    nix-collect-garbage --delete-older-than 14d
  '')

  ];
  # Install firefox
  programs.firefox.enable = true;
  programs.steam.enable = true;
  programs.starship.enable = true;
  # Fish Shell Config
  programs.fish = {
    enable = true;
    shellAliases = {
      ff = "fastfetch";
      cmat = "cmatrix -Bs";
      checkConfig = "nix eval .#nixosConfigurations.monolith.config.system.build.toplevel";
      cleanUp = "cleanUp = "cleanUpOldGen";
      update = ''echo "This will rebuild from config, if you want to update packages, try fullUpdate"; sudo nixos-rebuild switch --flake .#monolith '';
      fullUpdate = ''echo "Updating packages and rebuilding system from config"; sudo bash -c "fwupdmgr refresh; fwupdmgr get-updates; fwupdmgr update; nix flake update; nixos-rebuild switch --flake .#monolith"'';
      cat = "bat";
      ls = "eza";
      cd = "zoxide";
    };
    shellInit = "echo 'NixOS btw'";
  };

# ----- [ AUTO UPDATES ] ------------------------------
#system.autoUpgrade.enable = true;
#system.autoUpgrade.allowReboot = false;

# ----- [ SERVICES ] ------------------------------
  # Cups printing
  services.printing.enable = true;

  # Steam game store
  programs.steam = {
  enable = true;
  remotePlay.openFirewall = true;
  };

  # Fail2ban enabled
  services.fail2ban.enable = true;

  # rtkit enabled
  security.rtkit.enable = true;

  # audio setup
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    media-session.enable = true;
  };

  # For overclocking AMD GPUs
  #services.lact.enable = true;

  # Enable OpenSSH
  services.openssh.enable = true;

  #ollama
  #services.ollama = {
  #enable = true;
  #acceleration = "cuda"; # Only for NVIDIA GPUs
  #};

  #OpenWebUI for ollama
  #services.open-webui.enable = true;

  # Firmware updating software
  services.fwupd.enable = true;

  # Power profiles
  services.power-profiles-daemon.enable = true;

# ----- [ FLAKES ] ------------------------------
  nix.settings.experimental-features = [ "nix-command" "flakes" ]; # This is not unstable

# ----- [ FIREWALL ] ------------------------------
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [  ];
  networking.firewall.enable = true;
  #programs.steam.remotePlay.openFirewall = true; # In steam as service block

# ----- [ STATE VERSION ] ------------------------------
  system.stateVersion = "25.11" ; #Even if you update, do not change this
}

