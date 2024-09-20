#!/bin/sh

print_usage_then_exit () {
	echo "Usage: $0 --address <string>">&2;
	exit 2;
}

ADDRESS="";

if [ "$1" = "" ]; then print_usage_then_exit; fi

while true; do
	case "$1" in
		--address)
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
	echo "$0; you must provide an IPV4 address in the form of X.X.X.X (where X is 0-255)">&2;
	exit 1;
fi

if [ -z $(echo "$ADDRESS" | grep -P '^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$') ]; then
	echo "$0; the address does not match the form (X.X.X.X, where X is 0-999).">&2;
	exit 1;
fi

FIRST_OCTET=$(echo "$ADDRESS" | cut -d '.' -f 1);

if [ "$FIRST_OCTET" -gt 255 ]; then exit 1; fi

SECOND_OCTET=$(echo "$ADDRESS" | cut -d '.' -f 2);

if [ "$SECOND_OCTET" -gt 255 ]; then exit 1; fi

THIRD_OCTET=$(echo "$ADDRESS" | cut -d '.' -f 3);

if [ "$THIRD_OCTET" -gt 255 ]; then exit 1; fi

FOURTH_OCTET=$(echo "$ADDRESS" | cut -d '.' -f 4);

if [ "$FOURTH_OCTET" -gt 255 ]; then exit 1; fi

exit 0;
