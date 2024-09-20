#!/bin/sh

print_usage_then_exit () {
	echo "Usage: $0 --id <string>">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

ID="";

while true; do
	case $1 in
		--id)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -E '^-')" != "" ]; then
				print_usage_then_exit;
			else
				ID=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "Unrecognised argument - ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z "$ID" ]; then
	echo "$0; you must provide an id (--id number, where number is between 1 and 4096).">&2;
	exit 2;
fi

if [ "$ID" -lt 1 ]; then
	echo "$0; the vlan id is too low.">&2;
	exit 1;
fi

if [ "$ID" -gt 4096 ]; then
	echo "$0; the vlan id is too high.">&2;
	exit 1;
fi

exit 0;
