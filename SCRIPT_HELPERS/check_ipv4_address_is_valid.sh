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
	echo "$0; you must provide an IPV4 address (--address <string>).">&2;
	exit 2;
fi

if [ -z $(echo "$ADDRESS" | grep -P '^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$') ]; then
	echo "$0; the address does not match the IPV4 address pattern (X.X.X.X).">&2;
	exit 2;
fi

FIRST_OCTET=$(echo "$ADDRESS" | cut -d '.' -f 1);

if [ "$FIRST_OCTET" -gt 255 ]; then
	echo "$0; the first octet is too high.">&2;
	exit 2;
fi

SECOND_OCTET=$(echo "$ADDRESS" | cut -d '.' -f 2);

if [ "$SECOND_OCTET" -gt 255 ]; then
	echo "$0; the second octet is too high.">&2;
	exit 2;
fi

THIRD_OCTET=$(echo "$ADDRESS" | cut -d '.' -f 3);

if [ "$THIRD_OCTET" -gt 255 ]; then
	echo "$0; the third octet is too high.">&2;
	exit 2;
fi

FOURTH_OCTET=$(echo "$ADDRESS" | cut -d '.' -f 4);

if [ "$FOURTH_OCTET" -gt 255 ]; then
	echo "$0; the fourth octet is too high.">&2;
	exit 2;
fi

exit 0;
