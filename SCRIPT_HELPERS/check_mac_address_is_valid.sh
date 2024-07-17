#!/bin/sh

usage () {
	echo "Usage: $0 --address <string>">&2;
	exit 2;
}

ADDRESS="";

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--address )
			ADDRESS="$2";
			#if not enough arguments
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		"" ) break; ;;
		*)
			echo "">&2;
			echo "Unrecognised option: $1 $2">&2;
			usage;
		;;
	esac
done

if [ -z "$ADDRESS" ]; then
	echo "$0; you must provide a MAC address (--address <string>)">&2;
	exit 2;
fi

REGEX='^[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}$';

if [ -n "$(echo "$ADDRESS" | grep -P $REGEX)" ]; then
	exit 0;
else
	echo "$0; the MAC address is not valid.">&2;
	exit 2;
fi;
