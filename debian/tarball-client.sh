#!/bin/bash

# Copyright (©) 2003-2020 Teus Benschop.

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
if [ $? -ne 0 ]; then exit; fi


echo Create a tarball for the Linux Client
../../linux/tarball-macos.sh
if [ $? -ne 0 ]; then exit; fi
echo A tarball was created at $DEBIANSID


echo Copying script to $DEBIANSID
scp tarball-client-sid.sh $DEBIANSID:.
if [ $? -ne 0 ]; then exit; fi
ssh $DEBIANSID "./tarball-client-sid.sh"
if [ $? -ne 0 ]; then exit; fi
