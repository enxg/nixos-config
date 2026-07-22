# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let

in

{
  imports =
    [ ./hardware-configuration.nix ];

  # Bootloader.
  boot.loader.limine = {
    enable = true;
    secureBoot.enable = true;
    maxGenerations = 5;
    extraEntries = ''
      /Windows
          protocol: efi_chainload
          path: uuid(e24a4eb2-87da-4347-8714-306994f0c628)://EFI/Microsoft/Boot/bootmgfw.efi
    '';
  };
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "ntfs" ];

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 8 * 1024;
  }];

  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };

  fileSystems."/".options = [ "compress=zstd:1" "noatime" ];
  fileSystems."/home".options = [ "compress=zstd:1" "noatime" ];
  fileSystems."/nix".options = [ "compress=zstd:1" "noatime" ];

  boot.kernelPackages = pkgs.linuxPackages_6_18;

  networking.hostName = "carbon";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Istanbul";

  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_CTYPE = "en_GB.UTF-8";
    LC_ADDRESS = "tr_TR.UTF-8";
    LC_IDENTIFICATION = "tr_TR.UTF-8";
    LC_MEASUREMENT = "tr_TR.UTF-8";
    LC_MONETARY = "tr_TR.UTF-8";
    LC_NAME = "tr_TR.UTF-8";
    LC_NUMERIC = "tr_TR.UTF-8";
    LC_PAPER = "tr_TR.UTF-8";
    LC_TELEPHONE = "tr_TR.UTF-8";
    LC_TIME = "tr_TR.UTF-8";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.xserver.enable = false;

  #services.displayManager.sddm.enable = true;
  #services.displayManager.sddm.wayland.enable = true;
  #services.displayManager.sddm.autoNumlock = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.plasma-login-manager.enable = true;
  services.displayManager.plasma-login-manager.settings = {
    Keyboard = {
      NumLock = 0;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      sync.enable = true;
      intelBusId  = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Configure console keymap
  console.keyMap = "trq";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  fileSystems."/mnt/devdrive" = {
    device = "/dev/disk/by-uuid/01DA8DE6E686CF40";
    fsType = "ntfs-3g";
    options = [
      "rw" "uid=1000" "gid=100"
      "dmask=022" "fmask=022"
      "nofail" "x-systemd.automount"
      "big_writes"
    ];
  };

  programs.zsh.enable = true;

  users.users."enes" = {
    isNormalUser = true;
    description = "Enes Genç";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "enes" ];
  };

  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      vivaldi-bin
    '';
    mode = "0755";
  };

  environment.shellAliases.nrs = "sudo nixos-rebuild switch --flake ~/nixos-config#carbon";

  programs.kdeconnect.enable = true;

  hardware.tuxedo-drivers.enable = true;
  hardware.tuxedo-control-center.enable = true;

  programs.nix-ld.enable = true;

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.kdePackages.xdg-desktop-portal-kde ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  neovim wget curl htop btop ripgrep fd jq unzip p7zip fastfetch patchelf

  sbctl

  (vivaldi.override {
    proprietaryCodecs = false; # FIXME: Enable after codecs get updated
    enableWidevine = true;
  })
  vivaldi-ffmpeg-codecs

  libsForQt5.qt5.qtwayland

  alacritty zellij
  git gh
  go
  jetbrains-toolbox
  spotify
  starship
  inkscape mpv obs-studio
  ferdium
  insomnia
  claude-code
  discord vesktop
  gcc gnumake
  nodejs yarn
  prusa-slicer
  ];

  virtualisation.docker.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    inter
  ];

  systemd.services.numlockOnTty = {
    description = "Enable NumLock on TTYs";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "numlock-on-tty" ''
        for tty in /dev/tty{1..6}; do
          ${pkgs.kbd}/bin/setleds -D +num < "$tty";
        done
      '';
    };
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
