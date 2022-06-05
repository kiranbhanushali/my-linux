#!/bin/env bash

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

main(){

    # An array of options to choose.
    declare -a options=(
     "Lock screen"
     "Logout"
     "Reboot"
     "Shutdown"
     "Suspend"
     "Hibernate"
     "Hybrid-sleep"
     "Quit"
    )



    choice=$(printf '%s\n' "${options[@]}" | dmenu -i -p 'Power Menu:' "${@}")

    # What to do when/if we choose one of the options.
    case $choice in
        'Logout')
            if [[ "$(echo -e "No\nYes" | dmenu -i -p "${choice}?" "${@}" )" == "Yes" ]]; then
                kill -9 -1 & 
            else
                output "User chose not to logout." && exit 1
            fi
            ;;
        'Lock screen')
            # shellcheck disable=SC2154
            ${logout_locker}
            ;;
        'Reboot')
            if [[ "$(echo -e "No\nYes" | dmenu -i -p "${choice}?" "${@}" )" == "Yes" ]]; then
                systemctl reboot
            else
                output "User chose not to reboot." && exit 0
            fi
            ;;
        'Shutdown')
            if [[ "$(echo -e "No\nYes" | dmenu -i -p "${choice}?" "${@}" )" == "Yes" ]]; then
                systemctl poweroff
            else
                output "User chose not to shutdown." && exit 0
            fi
            ;;
        'Suspend')
            if [[ "$(echo -e "No\nYes" | dmenu -i -p "${choice}?" "${@}" )" == "Yes" ]]; then
                systemctl suspend
            else
                output "User chose not to suspend." && exit 0
            fi
            ;;
        'Quit')
            output "Program terminated." && exit 0
        ;;
        # It is a common practice to use the wildcard asterisk symbol (*) as a final
        # pattern to define the default case. This pattern will always match.
        *)
            exit 0
        ;;
    esac

}
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
# systemctl halt
# systemctl poweroff
# systemctl reboot
# systemctl suspend
# systemctl hibernate
# systemctl hybrid-sleep
