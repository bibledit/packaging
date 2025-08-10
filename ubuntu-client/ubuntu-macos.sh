#!/bin/bash

# Copyright (©) 2003-2022 Teus Benschop.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


# Exit script on error.
set -e


source ~/scr/sid-ip
export LANG="C"
export LC_ALL="C"


echo Create a tarball for the Linux Client
rm -f ~/Desktop/bibledit-5*.tar.gz
../../linux/tarball-macos.sh


echo Copy the tarball to sid
scp ~/Desktop/bibledit-5*.tar.gz $DEBIANSID:/tmp


echo Copy the debian folder to sid
ssh $DEBIANSID "rm -rf /tmp/debian"
scp -r debian $DEBIANSID:/tmp


echo Copy the sid scripts to sid
scp ubuntu-sid.sh $DEBIANSID:.
scp ubuntu-beta-sid.sh $DEBIANSID:.
echo Run the script ubuntu-sid.sh from $DEBIANSID to continue
echo or:
echo Run the script ubuntu-beta-sid.sh from $DEBIANSID to continue

