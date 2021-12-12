#!/usr/bin/env bash
printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Updating APT sources\n' -1
sudo add-apt-repository -nsy ppa:git-core/ppa
sudo add-apt-repository -nsy ppa:neovim-ppa/stable
curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
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
  tmux

printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Installing node packages\n' -1
mkdir -p .npm_packages
npm config set prefix "$HOME/.npm_packages"
npm -g install --upgrade npm
npm -g install --upgrade neovim
printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Installing python packages\n' -1
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade pynvim
printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Setting Timezone\n' -1
TIMEZONE=$(cat /etc/timezone)
if [ "$TIMEZONE" != "Africa/Johannesburg" ]; then
  sudo ln -fs /usr/share/zoneinfo/Africa/Johannesburg /etc/localtime
  sudo dpkg-reconfigure --frontend noninteractive tzdata
fi