#!/usr/bin/env bash
printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Checking sudo\n' -1
if [ ! -f "/etc/sudoers.d/90-$USER-nopasswd" ]; then
  echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/90-$USER-nopasswd" >/dev/null
fi

printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Updating APT sources\n' -1
if [ ! -f "/etc/apt/sources.list.d/git-core-ubuntu-ppa-$(lsb_release -c -s).list" ]; then
  sudo add-apt-repository -nsy ppa:git-core/ppa
fi

if [ ! -f "/etc/apt/sources.list.d/neovim-ppa-ubuntu-stable-$(lsb_release -c -s).list" ]; then
  sudo add-apt-repository -nsy ppa:neovim-ppa/stable
fi

if [ ! -f "/etc/apt/sources.list.d/nodesource.list" ]; then
  curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
fi

printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Updating APT\n' -1
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq update
printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Upgrading Ubuntu\n' -1
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -qq upgrade
printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Installing additional packages\n' -1
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -qq --no-install-recommends install \
  build-essential \
  coreutils \
  nodejs \
  neofetch \
  neovim \
  python3 \
  python3-pip \
  tmux \
  zsh \
  zsh-antigen

printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Installing node packages\n' -1
if [ ! -d "$HOME/.npm_packages/" ]; then
  mkdir -p .npm_packages
fi

if [ "$(npm config get prefix)" != "$HOME/.npm_packages/" ]; then
  npm config set prefix "$HOME/.npm_packages"
fi

if npm -g --list -p | grep -q "neovim"; then
  npm -g install neovim@latest
fi

if [ "$(npm -g outdated)" != "" ]; then
  npm -g update
fi

printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Installing python packages\n' -1
if ! pip show pynvim >/dev/null; then
  pip install --upgrade pynvim
fi

printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Setting Timezone\n' -1
TIMEZONE=$(cat /etc/timezone)
if [ "$TIMEZONE" != "Africa/Johannesburg" ]; then
  sudo ln -fs /usr/share/zoneinfo/Africa/Johannesburg /etc/localtime
  sudo dpkg-reconfigure --frontend noninteractive tzdata
fi