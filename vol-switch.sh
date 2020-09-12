#!/bin/sh

case "$1" in
  auto_vol|auto_vol.py)
    /usr/local/bin/auto_vol.py "${@:2}" ;;
  vol|vol.py)
    /usr/bin/vol.py "${@:2}" ;;
  "")
    /usr/bin/vol.py "${@:2}" ;;
  *)
    echo "Unsupported command: $1"
esac
