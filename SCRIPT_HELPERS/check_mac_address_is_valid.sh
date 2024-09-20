#!/bin/sh

print_usage_then_exit () {
	echo "Usage: $0 --address <string>">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

ADDRESS="";

while true; do
	case "$1" in
		--address )
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -E '^-')" != "" ]; then
				print_usage_then_exit;
			else
				ADDRESS=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "Unrecognised argument - ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z "$ADDRESS" ]; then
	echo "$0; you must provide a MAC address (--address XX:XX:XX:XX:XX:XX, where X is a-f, or A-F, or 0-9: hexadecimal)">&2;
	exit 2;
fi

REGEX='^[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}$';

if [ -n "$(echo "$ADDRESS" | grep -E $REGEX)" ]; then
	exit 0;
else
	exit 1;
fi;
