#!/bin/sh

print_usage_then_exit () {
	printf "Usage: $0 <arguments>\n">&2
	printf " --address XX:XX:XX:XX:XX:XX (where X is a-f, A-F, 0-9)\n">&2;
	printf "\n">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

ADDRESS="";

while true; do
	case $1 in
		--address )
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				ADDRESS=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "Unrecognised argument $1. ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z "$ADDRESS" ]; then
	printf "\nMissing --address. ">&2;
	print_usage_then_exit;
fi

REGEX='^[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}$';

if [ -n "$(echo "$ADDRESS" | grep -E $REGEX)" ]; then
	exit 0;
else
	exit 1;
fi;
