#!/bin/sh

print_usage_then_exit () {
	printf "Usage: $0 <arguments>\n">&2;
	printf "--name value.\n">&2;
	printf "\n">&2;
	exit 2;
}

NAME="";

if [ "$1" = "" ]; then print_usage_then_exit; fi

while true; do
	case $1 in
		--name)
			#not enough argyments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#value is empty
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				NAME=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "Unrecognised argument $1. ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z "$NAME" ]; then
	printf "\nMissing --name. ">&2;
	print_usage_then_exit;
fi

ALL_INTERFACE_DESCRIPTIONS_BRIEF=$(ip -br link show);

INTERFACE_DESCRIPTIONS_FILTERED_BY_NAME=$(echo "$ALL_INTERFACE_DESCRIPTIONS_BRIEF" | grep $NAME);

if [ -n "$INTERFACE_DESCRIPTIONS_FILTERED_BY_NAME" ]; then
	exit 0;
else
	printf "$0: that interface does not exist.\n">&2;
	exit 1;
fi
