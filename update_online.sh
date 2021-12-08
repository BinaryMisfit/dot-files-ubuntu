#!/usr/bin/env bash
if [[ -n $TMUX ]]; then
  exit 0
fi

if [[ -n $TERMINAL_EMULATOR ]]; then
  exit 0
fi

if echo -e "GET http://raw.github.com HTTP/1.0\n\n" | nc github.com 80 >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.github.com/BinaryMisfit/dot-files-ubuntu/active/update_check.sh)"
fi
