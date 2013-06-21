#!/bin/bash
#
# LICENSE
#    asusfanctrld copyright (c) 2013 Emil Lind
#
#      This file is part of asusfanctrld.
#
#      asusfanctrld is free software: you can redistribute it and/or modify
#      it under the terms of the GNU General Public License as published by
#      the Free Software Foundation, either version 3 of the License, or
#      (at your option) any later version.
#
#      asusfanctrld is distributed in the hope that it will be useful,
#      but WITHOUT ANY WARRANTY; without even the implied warranty of
#      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
#      GNU General Public License for more details.
#
# WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING
#
#  THIS SCRIPT COULD AND PROBABLY WILL DAMAGE YOUR COMPUTER
#  IF YOU DO NOT UNDERSTAND IT FULLY (INCLUDING THE ACPI_CALLS)
#  AND WHAT THEY DO SPECIFICALLY TO __YOUR__ COMPUTER YOU SHOULD
#  NOT START IT __AT ALL__. AND EVEN THEN BEEWARE THAT IT IS HIGHLY
#  EXPERIMENTAL __AT BEST__.
#
# WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING
#
# For more info and the latest version of this script:
#  https://github.com/nflx/asusfanctrld
#
# Make sure to run this with root permissions
# Make sure that you have acpi_call kernel module loaded
# Script executes `\_SB.PCI0.LPCB.EC0.ST98 0x45' ACPI call to set
# the fanspeed to different levels depending on temperature
# It responds to SIGUSR1 and SIGUSR2 for releasing and taking
# control from the otherwise firmware builtin control routine (auto).
# Example, releasing control to bios/fw would be:
# sudo kill -SIGUSR2 <pidof asusfanctrld.sh>
#
# Before the computer is put to sleep/suspend mode, control must be
# released first. That is what asusfanctrlpmhelper.sh is for.
#
# WARNING! BUG: That script might for now contain something that
# prevents my computer from entering sleep mode.
#
# On Ubuntu 13.04 that is done by placing the pmhelper in /etc/pm/sleep.d/
#
ACPI_CALL=/proc/acpi/call
HIGH=75
MID=65
LOW=58
LOWEST=55

LOWESTRPM=0x20
LOWRPM=0x25
MIDRPM=0x45
HIGHRPM=0xFF

DEBUG=0
if [ "$1" == "-d" ]; then
    DEBUG=1
fi

ME="$(basename $0)"

fatal() {
    logger -id -t $ME -s "FATAL: $@"
}
info() {
    logger -id -t $ME "INFO: $@"
}
debug() {
    if [ $DEBUG -gt 0 ]; then
        logger -id -t $ME "DEBUG:  $@"
        echo "DEBUG: $@"
    fi
}

if ! [ -e $ACPI_CALL ]; then
    sudo modprobe acpi_call
fi
if ! [ -e $ACPI_CALL ]; then
    fatal "You must have acpi_call kernel module loaded."
    fatal sudo modprobe acpi_call
    exit 1
fi

if [ "$(id -u)" != "0" ]; then
    echo "Must be run as root."
    exit 1
fi
fans_lowest() {
    info "Fans lowest $LOWEST $LOWESTRPM."
    command='\_SB.PCI0.LPCB.EC0.ST98 '$LOWESTRPM
    echo "$command" > "${ACPI_CALL}"
    debug $(cat "${ACPI_CALL}")
}
fans_low() {
    info "Fans low $LOW $LOWRPM."
    command='\_SB.PCI0.LPCB.EC0.ST98 '$LOWRPM
    echo "$command" > "${ACPI_CALL}"
    debug $(cat "${ACPI_CALL}")
}
fans_mid() {
    info "Fans mid $MID $MIDRPM."
    command='\_SB.PCI0.LPCB.EC0.ST98 '$MIDRPM
    echo "$command" > "${ACPI_CALL}"
    debug $(cat "${ACPI_CALL}")
}
fans_high() {
    info "Fans high $HIGH $HIGHRPM."
    command='\_SB.PCI0.LPCB.EC0.ST98 '$HIGHRPM
    echo "$command" > "${ACPI_CALL}"
    debug $(cat "${ACPI_CALL}")
}
fans_auto() {
    info "Fans auto."
    command='\_SB.ATKD.QMOD 0x02'
    echo "$command" > "${ACPI_CALL}"
    debug $(cat "${ACPI_CALL}")
    command='\_SB.PCI0.LPCB.EC0.SFNV 0 0'
    echo "$command" > "${ACPI_CALL}"
    debug $(cat "${ACPI_CALL}")
}

main() {
    cooldown=0
    cooldownmid=0
    cur="manual"
    trap "logger -id -s -t $ME got fatal signal, setting mode auto and exiting; fans_auto; exit" INT TERM EXIT KILL
    trap "logger -id -s -t $ME \"got SIGUSR1, invoking manual control of fans\";cur=\"manual\"" SIGUSR1
    trap "logger -id -s -t $ME got SIGUSR2, setting mode to auto;cur=\"setauto\"" SIGUSR2
    while :; do
        TEMP=$(($(cat /sys/devices/virtual/thermal/thermal_zone0/temp)/1000))
        debug $TEMP $cooldownmid $cooldown mode=$cur
        if [ "$cur" == "setauto" ]; then
            fans_auto
            cur="auto"
        fi
        if [ "$cur" != "auto" ]; then
            if [ "$cooldownmid" -gt 0 ] || [ "$TEMP" -ge "$HIGH" ]; then
                if [ "$cur" != "high" ]; then
                    fans_high
                    cur="high"
                fi
                cooldownmid=30
            elif [ "$cooldownmid" -eq "0" -a "$cooldown" -ne "0" ] || [ "$TEMP" -ge "$MID" ]; then
                if [ "$cur" != "mid" ]; then
                    fans_mid
                    cur="mid"
                fi
                cooldownmid=0
                if [ "$cooldown" -eq "0" ]; then
                    cooldown=30
                fi
            elif [ "$cooldown" -eq "0" ] || [ "$TEMP" -ge "$LOW" ]; then
                if [ "$cur" != "low" ]; then
                    fans_low
                    cur="low"
                fi
                cooldown=0
                cooldownmid=0
            elif [ "$TEMP" -lt "$LOW" ]; then
                if [ "$cur" != "lowest" ]; then
                    fans_lowest
                    cur="lowest"
                fi
                cooldown=0
                cooldownmid=0
            fi

            if [ "$cooldownmid" -gt "0" ]; then
                debug "cooldownmid: $cooldownmid"
                debug "cooldown: $cooldown"
                cooldownmid=$(($cooldownmid-1))
            elif [ "$cooldown" -gt "0" ]; then
                debug "cooldownmid: $cooldownmid"
                debug "cooldown: $cooldown"
                cooldown=$(($cooldown-1))
            fi
        fi
        sleep 1
    done
}
set -e
if [ $DEBUG -gt 0 ]; then
    debug "Started $0 using -d for DEBUG mode, will log to stdout, stderr and syslog."
    main
else
    main &
fi
