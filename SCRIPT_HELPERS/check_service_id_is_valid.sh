#!/bin/sh

print_usage_and_exit () {
	printf "Usage: $0 <argument>\n">&2
	printf " --service-user-id (0-65535)\n">&2;
	printf "\n">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_and_exit; fi

SERVICE_USER_ID="";

while true; do
	case $1 in
		--id)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				SERVICE_USER_ID=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "Unrecognised argument $1. ">&2; print_usage_and_exit; ;;
	esac
done;

if [ -z "$SERVICE_USER_ID" ]; then
	printf "\nMissing --id. ">&2;
	print_usage_then_exit;
fi

if [ "$(echo $SERVICE_USER_ID | grep -E '^[0-9]{1,5}$')" = "" ]; then
	printf "$0; the service user id must be a number between 0 and 65535\n">&2;
	exit 1;
fi

if [ -z "$(cat /etc/passwd | grep -E "^[\-_a-zA-Z]{1,32}:x:$SERVICE_USER_ID")" ]; then
	printf "$0: the service user id was not found in /etc/passwd\n">&2;
	exit 1;
else
	exit 0;
fi
