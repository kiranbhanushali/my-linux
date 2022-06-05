#!/bin/sh

# A dwm_bar function to read the battery level and status
# Joe Standring <git@joestandring.com>
# GNU GPLv3

    # Change BAT1 to whatever your battery is identified as. Typically BAT0 or BAT1
    CHARGE=$(cat /sys/class/power_supply/BAT1/capacity)
    STATUS=$(cat /sys/class/power_supply/BAT1/status)
   
    printf "%s" "$SEP1"
        if [ "$STATUS" = "Charging" ]; then
            echo " " #"$CHARGE" "+" #🔌
      elif [ $CHARGE -le 75 ] && [ $CHARGE -gt 50  ]; then
            echo " " #"$CHARGE"
        elif [ $CHARGE -le 50 ] && [ $CHARGE -gt 25  ]; then
            echo " " #"$CHARGE"
        elif [ $CHARGE -le 25 ] && [ $CHARGE -gt 10  ]; then
            echo " " #"$CHARGE"
        elif [ $CHARGE -le 10 ]; then
            echo " "  "!!"
        else
            echo " " #"$CHARGE" #🔋
        fi
    echo $CHARGE #"$SEP2"

