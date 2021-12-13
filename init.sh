#!/usr/bin/env bash
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

printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Updating APT\n' -1
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq update
printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Upgrading Ubuntu\n' -1
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -qq upgrade

PACKAGES=("build-essential" "coreutils" "indicator-cpufreq" "jq" "nodejs" "neofetch")
PACKAGES+=("python3" "python3-pip" "tmux" "zsh" "zsh-antigen")
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

TIMEZONE=$(cat /etc/timezone)
if [ "$TIMEZONE" != "Africa/Johannesburg" ]; then
  printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Setting Timezone\n' -1
  sudo ln -fs /usr/share/zoneinfo/Africa/Johannesburg /etc/localtime
  sudo dpkg-reconfigure --frontend noninteractive tzdata
fi