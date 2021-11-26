#!/usr/bin/env bash
if [[ -n ${TMUX+x} ]]; then
  printf "\r\033[0;96m[ TMUX ]\033[0m Online update\n"
  exit 0
fi

BASE_DIR="${HOME}/.dotfiles"
if [[ -d "${BASE_DIR}"/.git ]]; then
  VERSION_CURRENT=$(git -C "${BASE_DIR}" rev-parse HEAD)
  VERSION_NEW=$(git ls-remote https://github.com/BinaryMisfit/dot-files-ubuntu HEAD | awk '{ print $1 }')
  if [[ "${VERSION_CURRENT}" != "${VERSION_NEW}" ]]; then
    printf "\r\033[0;93m[UPDATE]\033[0m Online update"
    COMMAND="git -C ${BASE_DIR} pull --autostash --all --recurse-submodules --rebase --quiet"
    OUTPUT=$(bash -c "${COMMAND}" 2>&1)
    EXIT_CODE=$?
    if [[ ${EXIT_CODE} -eq 0 ]]; then
      COMMAND="\"${BASE_DIR}\"/install"
      OUTPUT=$(bash -c "${COMMAND}" 2>&1)
      EXIT_CODE=$?
      if [[ ${EXIT_CODE} -ne 0 ]]; then
        printf "\r\033[0;91m[FAILED]\033[0m Online update\n"
      else
        printf "\r\033[0;92m[ DONE ]\033[0m Online update\n"
      fi
    fi
  else
    printf "\r\033[0;92m[ SKIP ]\033[0m Online update\n"
  fi
else
    printf "\r\033[0;91m[FAILED]\033[0m Online update\n"
fi
