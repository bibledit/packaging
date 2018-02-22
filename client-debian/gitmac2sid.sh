#!/bin/bash

# Copyright (©) 2003-2017 Teus Benschop.

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


DEBIANSOURCE=`dirname $0`
cd $DEBIANSOURCE
DEBIANSOURCE=`pwd`
echo Running script from $DEBIANSOURCE


source ~/scr/sid-ip
echo The IP address of the Debian machine is $DEBIANSID


echo Check that the Debian machine is alive
ping -c 1 $DEBIANSID
if [ $? -ne 0 ]; then exit; fi


echo Pulling last changes
pushd ../../alioth/bibledit-gtk/
if [ $? -ne 0 ]; then exit; fi
git pull --all
if [ $? -ne 0 ]; then exit; fi
git pull --tags
if [ $? -ne 0 ]; then exit; fi
popd


echo Copying Bibledit repository at alioth from macOS to sid
rsync --archive -v --delete ../../alioth/bibledit-gtk $DEBIANSID:.
if [ $? -ne 0 ]; then exit; fi


echo Remove untracked files from the working tree
ssh -tt $DEBIANSID "cd bibledit-gtk; git clean -f"
if [ $? -ne 0 ]; then exit; fi
