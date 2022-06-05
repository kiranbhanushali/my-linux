#!/usr/bin/env bash
#
# script name: dm-wifi
# Description: Connect to wifi using dmenu
# Dependencies: dmenu, nmcli, Any Nerd Font
# Contributor: WitherCubes

set -euo pipefail

main() {
  bssid=$(nmcli device wifi list | sed -n '1!p' | cut -b 9- | dmenu -p "Select Wifi  :" -l 20 | cut -d' ' -f1)
  pass=$(echo "" | dmenu -p "Enter Password  :")
  nmcli device wifi connect "$bssid" password "$pass"
  sleep 10
  if ping -q -c 2 -W 2 google.com >/dev/null; then
    notify-send "Your internet is working :)"
  else
    notify-send "Your internet is not working :("
  fi
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"

