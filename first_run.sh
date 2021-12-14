#!/usr/bin/env bash
TIMEZONE=$(cat /etc/timezone)
if [ "$TIMEZONE" != "Africa/Johannesburg" ]; then
  printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Setting Timezone\n' -1
  sudo ln -fs /usr/share/zoneinfo/Africa/Johannesburg /etc/localtime
  sudo dpkg-reconfigure --frontend noninteractive tzdata
fi

CUR_LOCALE=$(cat /etc/default/locale)
if [ "$CUR_LOCALE" != "LANG=en_US.UTF-8" ]; then
  printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Setting Locale\n' -1
  sudo locale-gen --purge en_US.UTF-8 >/dev/null
  sudo update-locale LANG=en_US.UTF-8
fi

if [ ! -f "/etc/sudoers.d/90-$USER-nopasswd" ]; then
  printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Updating sudo for %s\n' -1 "$USER"
  echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/90-$USER-nopasswd" >/dev/null
fi

if [ ! -f "/etc/apt/sources.list.d/git-core-ubuntu-ppa-$(lsb_release -c -s).list" ]; then
  printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Installing GIT repository\n' -1
  sudo add-apt-repository -nsy ppa:git-core/ppa
fi

if [ ! -f "/etc/apt/sources.list.d/neovim-ppa-ubuntu-stable-$(lsb_release -c -s).list" ]; then
  printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Installing Neovim repository\n' -1
  sudo add-apt-repository -nsy ppa:neovim-ppa/stable
fi

if [ ! -f "/etc/apt/sources.list.d/nodesource.list" ]; then
  printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Installing NodeJS repository\n' -1
  curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
fi

printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Updating repositories\n' -1
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq update
printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Upgrading packages\n' -1
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -qq upgrade

PACKAGES=("build-essential" "coreutils" "curl" "i2c-tools" "imagemagick")
PACKAGES+=("indicator-cpufreq" "jq" "lm-sensors" "nodejs" "neofetch")
PACKAGES+=("python3" "python3-pip" "socat" "tmux" "zsh" "zsh-antigen")
INSTALL=()
for PACKAGE in "${PACKAGES[@]}"; do
  if DEBIAN_FRONTEND=noninteractive apt-cache policy "$PACKAGE" | grep -q 'Installed: (none)'; then
    INSTALL+=("$PACKAGE")
  fi
done

if [ ${#INSTALL[@]} -gt 0 ]; then
  printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Installing additional packages\n' -1
  sudo DEBIAN_FRONTEND=noninteractive apt-get -y -qq --no-install-recommends install "${INSTALL[@]}"
fi

if [ ! -d "$HOME/.npm_packages/" ]; then
  mkdir -p .npm_packages
fi

if [ "$(npm config get prefix)" != "$HOME/.npm_packages/" ]; then
  npm config set prefix "$HOME/.npm_packages"
fi

if npm -g --list -p | grep -q "neovim"; then
  printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Installing node packages\n' -1
  npm -g install neovim@latest
fi

if [ "$(npm -g outdated)" != "" ]; then
  printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Updating node packages\n' -1
  npm -g update
fi

if ! pip show pynvim >/dev/null; then
  printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Installing python packages\n' -1
  pip install --upgrade pynvim
fi

if [ "$SHELL" != "$(which zsh)" ]; then
  printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Settings default shell to zsh\n' -1
  sudo chsh -z "$(which zsh)" "$USER"
fi

if [ "$(which nvim)" !=  "$(update-alternatives --get-selections | grep 'editor' | head -1 | awk '{ print $3 }')" ]; then
  printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Setting default editor to neovim\n' -1
  sudo update-alternatives --install /usr/bin/editor editor "$(which nvim)" 100 >/dev/null
fi

if [ "$(which nvim)" !=  "$(update-alternatives --get-selections | grep 'vi' | head -1 | awk '{ print $3 }')" ]; then
  printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Setting default vi to neovim\n' -1
  sudo update-alternatives --install /usr/bin/vi vi "$(which nvim)" 100 >/dev/null
fi

OUTDATED=("vim" "vim-tiny")
REMOVE=()
for PACKAGE in "${OUTDATED[@]}"; do
  if ! DEBIAN_FRONTEND=noninteractive apt-cache policy "$PACKAGE" | grep -q 'Installed: (none)'; then
    REMOVE+=("$PACKAGE")
  fi
done

if [ ${#REMOVE[@]} -gt 0 ]; then
  printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Removing unneeded packages\n' -1
  printf "%s" "${REMOVE[@]}"
  sudo DEBIAN_FRONTEND=noninteractive apt-get -y -qq remove --purge "${REMOVE[@]}"
fi

printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Removing outdated packages\n' -1
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y autoremove
printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Cleaning packages\n' -1
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq autoclean

if [ "$USER" != "binarymisfit" ]; then
  if ! id binarymisfit &>/dev/null; then
    printf "[%(%a %b %e %H:%M:%S %Z %Y)T] User binarymisfit does not exists. Create [Y/n] " -1
    read CREATE
    CREATE=${CREATE:-Y}
    if [ "$CREATE" == "Y" ] || [ "$CREATE" == "y" ]; then
      printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Creating user binarymisfit\n' -1
      sudo useradd -c "Willie Roberts" -m -G sudo -s /usr/bin/zsh binarymisfit
    fi
  fi

  if sudo test -d "/home/binarymisfit"; then
    if sudo test -f "/home/binarymisfit/.bashrc"; then
      printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Removing .bashrc\n' -1
      sudo rm /home/binarymisfit/.bashrc
    fi

    if sudo test -f "/home/binarymisfit/.bash_logout"; then
      printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Removing .bash_logout\n' -1
      sudo rm /home/binarymisfit/.bash_logout
    fi

    if sudo test -f "/home/binarymisfit/.profile"; then
      printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Removing .profile\n' -1
      sudo rm /home/binarymisfit/.profile
    fi
  fi

  if sudo test ! -d "/home/binarymisfit/.dotfiles"; then
    printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Retrieving dot files\n' -1
    sudo git clone --recurse-submodules https://github.com/BinaryMisfit/dot-files-ubuntu /home/binarymisfit/.dotfiles -qq
    sudo chown -R binarymisfit:binarymisfit /home/binarymisfit
  fi

  if sudo test -f "/home/binarymisfit/.dotfiles/install.sh"; then
    printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Installing dot files\n' -1
    sudo -u binarymisfit "/home/binarymisfit/.dotfiles/install.sh"
  fi
fi
