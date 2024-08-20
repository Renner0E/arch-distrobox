FROM quay.io/toolbx/arch-toolbox AS arch-distrobox

# Pacman Initialization
# Create build user
RUN sed -i 's/#Color/Color/g' /etc/pacman.conf && \
  printf "[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" | tee -a /etc/pacman.conf && \
  sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/g' /etc/makepkg.conf && \
  pacman-key --init && pacman-key --populate && \
  pacman -Syu --noconfirm && \
  pacman -S \
      wget \
      base-devel \
      git \
      --noconfirm && \
  useradd -m --shell=/bin/bash build && usermod -L build && \
  echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
  echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Distrobox Integration
RUN git clone https://github.com/89luca89/distrobox.git --single-branch /tmp/distrobox && \
  cp /tmp/distrobox/distrobox-host-exec /usr/bin/distrobox-host-exec && \
  ln -s /usr/bin/distrobox-host-exec /usr/bin/flatpak && \
  wget https://github.com/1player/host-spawn/releases/download/$(cat /tmp/distrobox/distrobox-host-exec | grep host_spawn_version= | cut -d "\"" -f 2)/host-spawn-$(uname -m) -O /usr/bin/host-spawn && \
  chmod +x /usr/bin/host-spawn && \
  rm -drf /tmp/distrobox

# Install packages Distrobox adds automatically, this speeds up first launch
RUN pacman -S \
      adw-gtk-theme \
      bash-completion \
      bc \
      curl \
      diffutils \
      findutils \
      glibc \
      gnupg \
      inetutils \
      jdk-openjdk \
      keyutils \
      less \
      lsof \
      man-db \
      man-pages \
      mesa \
      mlocate \
      mtr \
      ncurses \
      nss-mdns \
      opengl-driver \
      openssh \
      pigz \
      pinentry \
      procps-ng \
      rsync \
      shadow \
      sudo \
      tcpdump \
      time \
      traceroute \
      tree \
      tzdata \
      unzip \
      util-linux \
      util-linux-libs \
      vte-common \
      wget \
      words \
      xorg-xauth \
      zip \
      --noconfirm

# My Own custom packages I need
RUN pacman -S \
      android-tools \
      base-devel \
      btop \
      chromium \
      curl \
      dos2unix \
      ffmpeg \
      fzf \
      git \
      htop \
      iftop \
      lf \
      man \
      mediainfo \
      neovim \
      nvtop \
      openssl \
      p7zip \
      qrencode \
      rclone \
      rsync \
      scrcpy \
      shellcheck \
      stress \
      tldr \
      tmux \
      unarchiver \
      unrar \
      wget \
      wl-clipboard \
      xorg-xev \
      xorg-xkill \
      yt-dlp \
      zsh \
      zsh-autosuggestions \
      zsh-completions \
      zsh-syntax-highlighting \
      --noconfirm

# My Own custom packages I need
RUN pacman -S \
      android-tools \
      base-devel \
      btop \
      curl \
      dos2unix \
      ffmpeg \
      fzf \
      git \
      htop \
      iftop \
      lf \
      man \
      mediainfo \
      neovim \
      nvtop \
      openssl \
      p7zip \
      qrencode \
      rsync \
      scrcpy \
      shellcheck \
      stress \
      tldr \
      tmux \
      unarchiver \
      unrar \
      wget \
      wl-clipboard \
      xorg-xev \
      xorg-xkill \
      yt-dlp \
      zsh \
      zsh-autosuggestions \
      zsh-completions \
      zsh-syntax-highlighting \
      --noconfirm

# Add paru and install AUR packages
USER build
WORKDIR /home/build
RUN git clone https://aur.archlinux.org/paru-bin.git --single-branch && \
  cd paru-bin && \
  makepkg -si --noconfirm && \
  cd .. && \
  rm -drf paru-bin && \
  paru -S \
  aur/gallery-dl-bin \
        --noconfirm

USER root
WORKDIR /

# Cleanup
RUN sed -i 's@#en_US.UTF-8@en_US.UTF-8@g' /etc/locale.gen && \
    userdel -r build && \
    rm -drf /home/build && \
    sed -i '/build ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    sed -i '/root ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    rm -rf \
        /tmp/* \
        /var/cache/pacman/pkg/*

FROM arch-distrobox AS arch-distrobox-amdgpupro

# Install amdgpu-pro, remove other drivers
RUN pacman -R \
        libglvnd \
        vulkan-intel \
        vulkan-radeon \
        mesa \
        --noconfirm && \
    useradd -m --shell=/bin/bash build && usermod -L build && \
    echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER build
WORKDIR /home/build
RUN paru -S \
        amdgpu-pro-oglp \
        lib32-amdgpu-pro-oglp \
        vulkan-amdgpu-pro \
        lib32-vulkan-amdgpu-pro \
        amf-amdgpu-pro \
        --noconfirm
USER root
WORKDIR /

# Cleanup
RUN userdel -r build && \
    rm -drf /home/build && \
    sed -i '/build ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    sed -i '/root ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    rm -rf \
        /tmp/* \
        /var/cache/pacman/pkg/*
