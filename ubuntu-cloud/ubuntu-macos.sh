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


source ~/scr/sid-ip
export LANG="C"
export LC_ALL="C"


echo Create a tarball for Bibledit Cloud
./tarball.sh
if [ $? -ne 0 ]; then exit; fi


echo Copy the Bibledit Cloud tarball to sid
scp ~/Desktop/bibledit-cloud*.tar.gz $DEBIANSID:/tmp
if [ $? -ne 0 ]; then exit; fi


echo Copy the debian folder to sid
ssh $DEBIANSID "rm -rf /tmp/debian"
scp -r debian $DEBIANSID:/tmp


echo Copy the older debian folder to sid
ssh $DEBIANSID "rm -rf /tmp/debian-old"
scp -r debian-old $DEBIANSID:/tmp


echo Copy the beta sid scripts to sid
scp ubuntu-beta-sid.sh $DEBIANSID:.
scp ubuntu-sid.sh $DEBIANSID:.
if [ $? -ne 0 ]; then exit; fi
echo Run the script ubuntu-beta-sid.sh from $DEBIANSID to continue
echo or
echo Run the script ubuntu-sid.sh from $DEBIANSID to continue

