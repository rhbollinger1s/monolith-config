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

# ----- [ KERNEL ] ------------------------------
  # Set kernel to latest release
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
# Disable SDDM
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
  # Define a user account. Don't forget to set a password with ‘passwd’.
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
    shell = pkgs.bash
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
    #Term
    kitty
    foot

    #Term-Apps
    fastfetch
    cmatrix
    neovim
    asciiquarium
    htop
    lolcat
    nano
    ranger
    unzip
    vim

    #GUI-Apps
    kdePackages.kate
    kdePackages.dolphin
    gnome-boxes
    godot
    vlc
    libreoffice
    spotify
    obs-studio
    obsidian
    vscode

    #Games
    superTuxKart
    steam
    # bsdgames # Has bugs with fish shell, try at your own risk

    #else
    git
    wine
    docker
    less
    pavucontrol
    #timeshift (Not needed for nixOS, but here just in case)

  ];
  # Install firefox.
  programs.firefox.enable = true;
  programs.steam.enable = true;
  programs.starship.enable = true;
  # Fish Shell Config
  programs.fish = {
    enable = true;
    shellAliases = {
      ff = "fastfetch";
      cmat = "cmatrix -Bs";
      update = "nix flake update && sudo nixos-rebuild switch --flake .#monolith";
    };
    shellInit = "echo 'NixOS btw'";
  };
# ----- [ AUTO UPDATES ] ------------------------------
system.autoUpgrade.enable = true;
system.autoUpgrade.allowReboot = false;

# ----- [ SERVICES ] ------------------------------
  # Cups printing
  services.printing.enable = true;
  # Fail2ban enabled
  services.fail2ban.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    media-session.enable = true;
  };
  # Enable OpenSSH
  services.openssh.enable = true;
  #ollama
  #services.ollama = {
  #enable = true;
  #acceleration = "cuda"; # Only for NVIDIA GPUs
  #};
  #OpenWebUI for ollama
  #services.open-webui.enable = true;
# ----- [ FLAKES ] ------------------------------
  nix.settings.experimental-features = [ "nix-command" "flakes" ]; # This is not unstable

# ----- [ FIREWALL ] ------------------------------
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [  ];
  networking.firewall.enable = true;

  system.stateVersion = "25.11" ; #Even if you update, do not change this
}
