#!/bin/sh
#
# gen-ver.sh for libquvi-scripts
# Copyright (C) 2012  Toni Gundogdu
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301  USA
#
dir=`dirname $0`
o=
# flags:
m= # dump major and minor only
c= # strip off the 'v' prefix

# VERSION file is part of the dist tarball.
from_VERSION_file()
{
  o=`cat "$dir/VERSION" 2>/dev/null`
}

from_git_describe()
{
  [ -d "$dir/.git" -o -f "$dir/.git" ] && {
    o=`git describe --match "v[0-9]*" --abbrev=4 HEAD 2>/dev/null`
  }
}

make_vn_mm()
{
  j=`expr "$o" : 'v\([0-9]\)'`
  n=`expr "$o" : 'v[0-9]\.\([0-9]*[0-9]\)'`
  o="v$j.$n"
}

dump_vn()
{
  [ -n "$m" ] && make_vn_mm
  [ -n "$c" ] && o=${o#v} # strip off the 'v' prefix.
  echo $o
  exit 0
}

help()
{
  echo "$0 [OPTIONS]
-h  Show this help and exit
-c  Strip off the 'v' prefix from the output
-m  Output the major.minor -pair only"
  exit 0
}

while [ $# -gt 0 ]
do
  case "$1" in
    -m) m=1;;
    -c) c=1;;
    -h) help;;
     *) break;;
  esac
  shift
done

from_VERSION_file
[ -z "$o" ] && from_git_describe
[ -n "$o" ] && dump_vn
exit 1

# vim: set ts=2 sw=2 tw=72 expandtab:
