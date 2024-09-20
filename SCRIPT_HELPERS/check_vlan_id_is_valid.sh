#!/bin/sh

print_usage_then_exit () {
	printf "Usage: $0 <arguments>\n">&2
	printf " --id (1-4096)\n">&2;
	printf "\n">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

ID="";

while true; do
	case $1 in
		--id)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				ID=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "Unrecognised argument $1. ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z "$ID" ]; then
	printf "\nMissing --id. ">&2;
	print_usage_then_exit;
fi

if [ "$ID" -lt 1 ]; then
	printf "$0; the vlan id is too low.\n">&2;
	exit 1;
fi

if [ "$ID" -gt 4096 ]; then
	printf "$0; the vlan id is too high.\n">&2;
	exit 1;
fi

exit 0;
