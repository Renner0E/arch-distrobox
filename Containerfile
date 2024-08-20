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
# bloated stuff gets its own layer
# LC_ALL=C.UTF-8 pacman -Qi | awk '/^Name/{name=$3} /^Installed Size/{print $4$5, name}' | LC_ALL=C.UTF-8 sort -h

RUN pacman -S chromium --noconfirm
RUN pacman -S rclone --noconfirm
RUN pacman -S ffmpeg --noconfirm
RUN pacman -S jdk-openjdk --noconfirm
# My Own custom packages I need
RUN pacman -S \
      android-tools \
      btop \
      curl \
      dos2unix \
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
      shellcheck
      stress \
      svn \
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
