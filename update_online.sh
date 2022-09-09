#!/usr/bin/env bash
if [ -n "$TMUX" ]; then
  exit 0
fi

if [ -n "$TERMINAL_EMULATOR" ]; then
  exit 0
fi

if ping -q -c1 github.com &>/dev/null; then
  /bin/bash -c "$(curl --connect-timeout 5 -fsSL https://raw.github.com/BinaryMisfit/dot-files-ubuntu/active/update_check.sh) &>/dev/null"
fi
