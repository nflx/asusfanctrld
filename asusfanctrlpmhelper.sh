#!/bin/bash
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
#      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the•
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
# this script needs to run on suspend and resume
# on ubuntu 13.04 at least this fits in /etc/pm/sleep.d/
setauto() {
    echo Sending SIGUSR2 to $(pgrep -l asusfanctrld.sh)
    sudo pkill -SIGUSR2 asusfanctrld.sh > /dev/null 2>&1
}
setmanual() {
    echo Sending SIGUSR1 to $(pgrep -l asusfanctrld.sh)
    sudo pkill -SIGUSR1 asusfanctrld.sh > /dev/null 2>&1
}

case $1 in
     suspend|suspend_hybrid|hibernate)
        setauto
    ;;
     resume|thaw)
        setmanual
    ;;
esac

