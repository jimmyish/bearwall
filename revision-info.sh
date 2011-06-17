#!/bin/bash

CHECK_ONLY=0

# Check for any command line options (which we don't want !)
if [ $# -gt "0" ] ; then
	case "$1" in
		-c)
			CHECK_ONLY=1
			;;
		*)
			echo "Invalid Option!"
			exit 1
			;;
	esac
fi

VN=`git rev-parse HEAD`

# Not sure if we need to do the following, but the example I found
# did this, so why not
git update-index -q --refresh

MODS=`git diff-index --name-only HEAD` 

if [ ! -z "$MODS" ] ; then
	if [ $CHECK_ONLY == 1 ] ; then
		echo "Tree contains modified files, commit before release"	
		exit 1
	fi

	VN=$VN-mod
fi

if [ $CHECK_ONLY == 1 ] ; then
	exit 0
else
	echo $VN
fi
