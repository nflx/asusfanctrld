asusfanctrld
============

# WHAT
  Highly experimental fan control for my ASUS UX32VD based on acpi_call module.

# LICENSE
  asusfanctrld copyright (c) 2013 Emil Lind

    This file is part of asusfanctrld.

    asusfanctrld is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    asusfanctrld is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with asusfanctrld.  If not, see <http://www.gnu.org/licenses/>.

# CREDITS
  Based on Michal Kottman's acpi_call module: https://github.com/mkottman/acpi_call/

  Based on prikolchik's amazing work from this post:
  http://forum.notebookreview.com/asus/705656-fan-control-asus-prime-ux31-ux31a-ux32a-ux32vd.html

  Thank you Michal Kottman and prikolchik for your amazing work!

# WHY
  Well I feel that the fans hit their predefined "builtin" thresholds too early 
  and then turn of shortly after. This repeatedly is distracting me from my work.

# HOW
  Please read the forum posts linked above to fully understand how this script works
  and why this approach is not advised and could DAMAGE YOUR COMPUTER.
  With that said, in short it uses acpi_call debug module to interface and send
  commands directly to the acpi controller overriding the builtin automatic control
  with thresholds in embedded firmware. Beware that this code is nothing more than
  an experimental hack. The builtin fancontrol will cool your computer and keep your
  computer in good shape. It is VITAL that you monitor the temperature status when
  running asusfanctrld and take the apropriate actions if it gets too heated.
  When you are done experimenting a full reboot or poweroff will surely undo
  any settings this script have done using acpi calls.

 WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING

  THIS SCRIPT COULD AND PROBABLY WILL DAMAGE YOUR COMPUTER!!!
  IF YOU DO NOT UNDERSTAND IT FULLY (INCLUDING THE ACPI_CALLS)
  AND WHAT THEY DO SPECIFICALLY TO __YOUR__ COMPUTER YOU SHOULD
  NOT START IT __AT ALL__. AND EVEN THEN BEEWARE THAT IT IS HIGHLY
  EXPERIMENTAL __AT BEST__.

 WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING

# DETAILS
  - Make sure to run this with root permissions
  - Make sure that you have acpi_call kernel module loaded
  - Script executes `\_SB.PCI0.LPCB.EC0.ST98 0x45' ACPI call to set
  the fanspeed to different levels depending on temperature
  - It responds to SIGUSR1 and SIGUSR2 for releasing and taking
  control from the otherwise firmware builtin control routine (auto).

  Example, releasing control to bios/fw would be:
    sudo kill -SIGUSR2 <pidof asusfanctrld.sh>

  - Before the computer is put to sleep/suspend mode, control must be
  released first. That is what asusfanctrlpmhelper.sh is for.
  On Ubuntu 13.04 that is done by placing the pmhelper in /etc/pm/sleep.d/

# ISSUES
  **WARNING! BUG: The asusfanctrlpmhelper script might for now contain something
  that prevents my computer from entering sleep mode. **

# INSTALL
  1. Make sure you have a Asus Zenbook UX32VD
    sudo dmidecode |egrep -i 'asus|ux32vd'
        Version: UX32VD.213
        Manufacturer: ASUSTeK COMPUTER INC.
        Product Name: UX32VD
        SKU Number: ASUS-NotebookSKU
        Manufacturer: ASUSTeK COMPUTER INC.
        Product Name: UX32VD
        Manufacturer: ASUSTeK COMPUTER INC.
  2. Note that I have only tried this on one UX32VD with bios 213.
  3. Install acpi_call module so that it loads automatically at bootup.
  4. Read the code and understand it (read the readme).
  5. Test the program by running it with the debug flag (-d) 
     and monitoring syslog and temperature (using monitortemp.sh).
  6. When you find that you think it works ok and safe then proceed.
  7. Install the acpictrlpmhelper.sh in /etc/pm/sleep.d/
  8. Test suspend and resume (still monitoring as in .5)
  8. Use some way of starting it att bootup.
     Like build an init/upstart script or default to adding it
     before exit 0, in the end of /etc/rc.local.
  9. Reboot and test...
 10. Test Test Test....
     Please Supply feedback and info on updates/forks/other sollutions to me.
      - Emil Lind <emil@sys.nu>
