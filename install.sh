#!/usr/bin/env bash
CONFIG="install.conf.yaml"
DOT_BOT_DIR="dotbot"
DOT_BOT_BIN="bin/dotbot"
DOT_FILES_BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pushd "$DOT_FILES_BASE" >/dev/null || exit
git -C "$DOT_BOT_DIR" submodule sync --quiet --recursive
git submodule update --init --recursive "${DOT_BOT_DIR}"
eval "$DOT_FILES_BASE/$DOT_BOT_DIR/$DOT_BOT_BIN" -d "$DOT_FILES_BASE" -c "$CONFIG" "${@}"
popd >/dev/null || exit
