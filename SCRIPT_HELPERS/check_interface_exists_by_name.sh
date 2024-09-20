#!/bin/sh

print_usage_then_exit () {
	echo "Usage: $0 --name <string>" 1>&2;
	exit 2;
}

NAME="";

if [ "$1" = "" ]; then print_usage_then_exit; fi

while true; do
	case "$1" in
		--name)
			#not enough argyments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#value is empty
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -E '^-')" != "" ]; then
				print_usage_then_exit;
			else
				NAME=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "Unrecognised argument - ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z "$NAME" ]; then
	echo "$0; you must provide a name (--name <string>).">&2;
	exit 2;
fi

ALL_INTERFACE_DESCRIPTIONS_BRIEF=$(ip -br link show);

INTERFACE_DESCRIPTIONS_FILTERED_BY_NAME=$(echo "$ALL_INTERFACE_DESCRIPTIONS_BRIEF" | grep $NAME);

if [ -n "$INTERFACE_DESCRIPTIONS_FILTERED_BY_NAME" ]; then
	exit 0;
else
	echo "$0; that interface does not exist.">&2;
	exit 1;
fi
