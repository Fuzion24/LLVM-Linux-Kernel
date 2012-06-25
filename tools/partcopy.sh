#!/bin/sh
##############################################################################
# Copyright (c) 2012 Behan Webster
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to 
# deal in the Software without restriction, including without limitation the 
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
# sell copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
##############################################################################


usage() {
	cat <<ENDHELP
Usage: `basename $0` [options] <sd-card-image> <partition-name> <from-path> <to-path>
    <sd-card-image>   A file image of an SD card
    <partition-name>  The partition or volume name to which to copy files on the SD card image
    <from-path>       The path from which to copy files
    <to-path>         The path to which to copy files in the named partition on the SD card image

    --delete          Means delete what was at the to-path previously

    This utility can be used to copy files into an existing SD card image.
ENDHELP
	exit -1
}

error() {
	echo "E: $*"
	return 1
}

while [ $# -gt 0 ] ; do
	case "$1" in
	-d*|--delete) DELETE=--delete;;
	--shell) DROPTOSHELL=1;;
	-v*|--verbose) VERBOSE=--verbose;;
	--) shift; break;;
	-*|--help) usage;;
	*) break;;
	esac
	shift
done
[ $# -lt 3 ] && usage
SDCARD=$1
PARTNAME=$2
FROM=$3
TO=${4:-/}

KPARTX=/sbin/kpartx
[ -x $KPARTX ] || error "$KPARTX not found (you may need to install the package)"

# Clean up mount and looped partitions
end() {
	FILENAME=`basename "$SDCARD"`
	DEV=`sudo losetup -a | grep "($FILENAME)" | sed -e 's|^/dev/||; s|:.*$||'`
	MP=`mount | awk '/'$DEV'/ {print $3}'`
	[ -n "$MP" ] && sudo umount "$MP" && rmdir "$MP"
	sudo $KPARTX -d $SDCARD >/dev/null
	exit 0
}
trap end INT

MAPPED=`sudo $KPARTX -av $SDCARD | awk '{print $3}'`
for DEV in $MAPPED ; do
	DEV=/dev/mapper/$DEV
	[ -n "$VERBOSE" ] && echo $DEV
	if [ `file -sL $DEV | grep -c $PARTNAME` -gt 0 ] ; then
		MP=`mktemp -d`
		sudo mount $DEV $MP
		sudo mkdir -p $MP/$TO
		sudo rsync -a $VERBOSE $DELETE $FROM/ $MP/$TO
		[ -n "$DROPTOSHELL" ] && echo $MP && sh
	fi
done
end
