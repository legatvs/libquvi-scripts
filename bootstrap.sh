#!/bin/sh
#
# libquvi-scripts
# Copyright (C) 2012  Toni Gundogdu <legatvs@gmail.com>
#
# This file part of libquvi-scripts <http://quvi.sourceforge.net/>.
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public
# License as published by the Free Software Foundation, either
# version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General
# Public License along with this program.  If not, see
# <http://www.gnu.org/licenses/>.
#
set -e

source=.gitignore
cachedir=autom4te.cache

cleanup()
{
  echo "WARNING
This will remove the files specified in the $source file. This will also
remove the $cachedir/ directory with all of its contents.
  Bail out now (^C) or hit enter to continue."
  read n1
  [ -f Makefile ] && make distclean
  for file in `cat $source`; do # Remove files only.
    [ -e "$file" ] && [ -f "$file" ] && rm -f "$file"
  done
  [ -e "$cachedir" ] && rm -rf "$cachedir"
  rmdir -p config.aux 2>/dev/null
  exit 0
}

help()
{
  echo "Usage: $0 [-c|-h] [top_srcdir]
-c  Make the source tree 'maintainer clean'
-h  Show this help and exit
Run without options to (re)generate the configuration files."
  exit 0
}

while [ $# -gt 0 ]
do
  case "$1" in
    -c) cleanup;;
    -h) help;;
    *) break;;
  esac
  shift
done

mkdir -p m4

echo "Generate configuration files..."
autoreconf -if && echo "You can now run 'configure'"
