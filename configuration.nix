{ config, pkgs, ... }:

# rhbollinger1s, 2025
# "If I spend 1,000 years writing 10,000 comments,
# then I will have wasted my life.
# However, if one man reads one of my comments,
# he will have wasted his time too,
# and it will all have been worth it.
# JK, read the comments, their here to help."

# ----- [ NOTES ] ------------------------------
# "1. This configuration could be split up.
# However, some people would not know how to work it, so it is not."
#
# "2. This configuration is made to be changed, mod it yourself and learn"
#
# "3. Read the darn comments, but if you read this, I dont need to tell you that"
#
# "4. Have fun, if not, convince yourself you are. It's easier that way"

# ----- [ IMPORTS ] ------------------------------
{
  # "This line tells NixOS to look at another file that tells it about your hardware."
  # "NEVER MESS WITH "hardware-configuration.nix", FOR IT IS DEEP MAGIC"
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

# ----- [ BOOTLOADER ] ------------------------------
  # Set Bootloader to systemd boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

# ----- [ KERNEL and FIRMWARE ] ------------------------------
  # "This sets the kernel to 6.9, and nice and stable kernel."
  # "If you have newer hardware, you can switch it to linuxPackages_latest"
  # "If you came from Arch Linux, you may also switch to linuxPackages_latest"
  boot.kernelPackages = pkgs.linuxPackages_6_9;
  #boot.kernelPackages = pkgs.linuxPackages_latest; # If you have newer hardware

  #"This is where we tell your computer to install firmware. Please dont mess with this."
  hardware.firmware = [ pkgs.linux-firmware ];

# ----- [ HOSTNAME ] ------------------------------
  # "Set up hostname, you may change this, but there are rules on what a hostname can be"
  # "Just google Linux hostname rules before modding it"
  networking.hostName = "monolith";

# ----- [ NETWORKING AND WIFI ] ------------------------------
  # Set up network manager
  networking.networkmanager.enable = true;

# ----- [ TIME AND INTERNATIONALIZATION ] ------------------------------
  # "Timezone, set it to where you are."
  time.timeZone = "America/Chicago";
  # "internationalization stuff, you might not need to touch this"
  # "A long time ago, we had alot of standards, this is the fallout..."
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
  # "This is your login screen."
  # "Use sddm for kde plasma"
  # "Use GDM for gnome"
  # "Do not enable both, keep one uncommented"
  services.displayManager.sddm.enable = true;
  # services.displayManager.gdm.enable = true;

# ----- [ DESKTOP ] ------------------------------
  # "This is your desktop"
  # "If you want to use plasma, keep it uncommented, comment out gnome and look at "Display Manager""
  # "If you want to use gnome, uncomment it, comment out plasma6 and look at "Display Manager""
  # "Technically, you could have both, but your system will not work well."
  services.desktopManager.plasma6.enable = true;
  # services.desktopManager.gnome.enable = true;

# ----- [ DRIVER CONFIG ] ------------------------------
# "This is where drivers are setup. Driver setup on nix is hard, so we made it easy"
# "If you use a Nivida GPU, you will want to uncomment the Nivida part of this"
# "If you use a AMD GPU, you will want to uncomment the AMD part of this"
# "If you use a Intel iGPU, your fine, dont worry about this. (The iGPU is a GPU built in to your CPU")
# "If you use a AMD GPU and know what a ROCm or HIP workaround is, you may need it. If not, don't worry about it."
# "Don't uncomment both, it will cause errors."
#
# "Nivida ( Uncomment if using nvidia GPU )"
# hardware = {
#    graphics.enable = true;
#    nvidia.modesetting.enable = true;
#    nvidia.nvidiaSettings = true;
#    nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
#    nvidia.open = false; # If GPU is new enough, set to true
#    hardware.opengl.enable = true;
#    hardware.nvidia.opencl.enable = true;
#  };

# "AMD ( Uncomment if using AMD GPU )"
# hardware = {
#    graphics.enable = true;
#    graphics.enable32Bit = true;
#    amdgpu.opencl.enable = true;
#    amdgpu.initrd.enable = true; # sets boot.initrd.kernelModules = ["amdgpu"];
#    amdgpu.legacySupport.enable = true; # Only use for Southern islands or Sea islands GPUs
#  };

# ----- [ ROCm / HIP WORKAROUND ] ------------------------------
# "Workaround for software that hardcodes /opt/rocm (e.g., HIP/ROCm apps) from NixOS docs"
# "Only for AMD GPUS. For AI usage"
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
  # "Some programs need SUID wrappers, can be configured further or are
  # started in user sessions. Dont worry about it."
  programs.mtr.enable = true;
  programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };

# ----- [ USER ACCOUNTS ] ------------------------------
  # "This are the basic user accounts, feel free to mod them."
  # "You will need to set a password, use the command "sudo passwd username" with the username of the account you need to set a password for as username"
  users.users.monoUser = {
    shell = pkgs.fish; # We use fish here, due to us having taste
    isNormalUser = true;
    description = "User for monolithic config";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
       gparted
       #Here you can add apps for this user only!!!
    ];
  };
  users.users.guest = {
    shell = pkgs.bash; # Guests only get BASH!!! Ha, they live without high end tools.
    isNormalUser = true;
    description = "guest user for monolith config";
    extraGroups = [  ]; # No sudo for you.
    packages = with pkgs; [
    ];
  };

# ----- [ PROGRAMS ] ------------------------------
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true; # For non FOSS software to be allowed

  # Here, we add fonts... yay.
  fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
  ];

  # "Programs that are not fonts are below. There are two kinds"
  # "There are installed packages, that work as you would think"
  # "Then we have enable packages, these have other things they need, so enabling it does more that just installing it."
  # "To add a package, add it to installed packages"
  # "To remove a package, remove it from the list"
  # "To remove it just for a while, comment it out"

  # "Installed Packages"
  environment.systemPackages = with pkgs; [

  # "Terminal Emulators"
  alacritty
  foot
  kitty

  # "File Managers & Text Editors (CLI + GUI)"
  kdePackages.dolphin
  kdePackages.kate
  nano
  neovim
  ranger
  vim

  # "System Info & Eye Candy"
  asciiquarium
  btop
  bottom
  cmatrix
  fastfetch # Yes, you must have this. The system does not require it, but I do to all users
  htop
  lolcat
  procs

  # "Web & Media"
  chromium # THIS IS GOOGLE SPYWARE. However, people use it sadly...
  firefox
  mpv
  vlc
  yt-dlp # Here, we download youtube videos. Cool tool, google how to use it.

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
  #steam # This is in enabled allready, just here to remind you
  steam-run
  superTuxKart

  # "Creative & Multimedia"
  audacity
  blender
  gimp
  handbrake
  inkscape
  krita
  obs-studio

  # "System Maintenance & Hardware"
  lm_sensors
  pciutils       # lspci
  pavucontrol
  smartmontools
  usbutils       # lsusb

  # "Security & Privacy"
  keepassxc
  tor-browser
  yubikey-manager

  # "Runtime & Compatibility"
  gnome-boxes    # virtual machines
  wine

  # Nix Eco Utilities
  nix-index
  nix-tree

  # "Custom Monolith Script, powers: "cleanUp" command"
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

  # Enabled Programs

  # Install firefox
  programs.firefox.enable = true;
  programs.starship.enable = true;

  # Steam game store
  programs.steam = {
  enable = true;
  remotePlay.openFirewall = true;
  };
  # "Only for if you own steam hardware"
  # hardware.steam-hardware.enable = true;

  # Fish Shell Config
  programs.fish = {
    enable = true;
    shellAliases = {
      ff = "fastfetch";
      cmat = "cmatrix -Bs";
      checkConfig = "nix eval .#nixosConfigurations.monolith.config.system.build.toplevel";
      cleanUp = "cleanUpOldGen";
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

# ----- [ SERVICES and STUFF ] ------------------------------
  # Cups printing
  services.printing.enable = true;

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
    wireplumber.enable = true;
  };

  # For overclocking AMD GPUs
  #services.lact.enable = true;

  # "Enable OpenSSH"
  # "This is basic so everyone can understand it."
  # "Advanced users should look into system hardening"
  services.openssh.enable = true;

  # "Here is a tool to run AI"
  #services.ollama = {
  #enable = true;
  #acceleration = "cuda"; # Only for NVIDIA GPUs
  #};

  #OpenWebUI for ollama
  #services.open-webui.enable = true;

  # "Firmware updating software"
  services.fwupd.enable = true;

  # "Power profiles"
  services.power-profiles-daemon.enable = true;

  # Bluetooth
  # "So, bluetooth is very hackable, but people use it. Not enabled, but you can take the risk. Most people do on their phones, but we are Linux people, and dont like things like that."
  # hardware.bluetooth.enable = true;

# ----- [ FLAKES ] ------------------------------
 # This is not unstable. In fact, most people use it. If you want Monolith to work, keep this line.
 #If you don't want flakes, fork the project and make your own. (And change the fish alisas, they want flakes.)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

# ----- [ FIREWALL ] ------------------------------
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [  ];
  networking.firewall.enable = true;
  #programs.steam.remotePlay.openFirewall = true; # In steam as service block of code. This line is just to remind you that it exists.

# ----- [ STATE VERSION ] ------------------------------
  system.stateVersion = "25.11" ; # Even if you update, do not change this. You need not understand why, just now that NixOS will kill itself if you do.
  # Did you read this comment? Lol
}

