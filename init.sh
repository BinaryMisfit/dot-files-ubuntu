#!/usr/bin/env bash
TIMEZONE=$(cat /etc/timezone)
if [ "$TIMEZONE" != "Africa/Johannesburg" ]; then
  sudo ln -fs /usr/share/zoneinfo/Africa/Johannesburg /etc/localtime
  sudo dpkg-reconfigure --frontend noninteractive tzdata
fi