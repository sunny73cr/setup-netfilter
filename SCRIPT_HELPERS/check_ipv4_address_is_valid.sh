#!/bin/sh

print_usage_then_exit () {
	printf "Usage: $0 <arguments>\n">&2;
	printf "--address X.X.X.X (where X is 0-255)\n">&2;
	exit 2;
}

ADDRESS="";

if [ "$1" = "" ]; then print_usage_then_exit; fi

while true; do
	case "$1" in
		--address)
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

if [ -z $(echo "$ADDRESS" | grep -P '^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$') ]; then
	printf "$0; the address does not match the form (X.X.X.X, where X is 0-999).\n">&2;
	exit 1;
fi

FIRST_OCTET=$(echo "$ADDRESS" | cut -d '.' -f 1);

if [ "$FIRST_OCTET" -gt 255 ]; then
	printf "$0: first octet is too high.\n">&2;
	exit 1;
fi

SECOND_OCTET=$(echo "$ADDRESS" | cut -d '.' -f 2);

if [ "$SECOND_OCTET" -gt 255 ]; then
	printf "$0: second octet is too high.\n">&2;
	exit 1;
fi

THIRD_OCTET=$(echo "$ADDRESS" | cut -d '.' -f 3);

if [ "$THIRD_OCTET" -gt 255 ]; then
	printf "$0: third octet is too high.\n">&2;
	exit 1;
fi

FOURTH_OCTET=$(echo "$ADDRESS" | cut -d '.' -f 4);

if [ "$FOURTH_OCTET" -gt 255 ]; then
	printf "$0: fourth octet is too high.\n">&2;
	exit 1;
fi

exit 0;
