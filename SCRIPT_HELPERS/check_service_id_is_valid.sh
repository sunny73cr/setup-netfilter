#!/bin/sh

usage () {
	echo "Usage: $0 --service-user-id <number>">&2;
	exit 2;
}

SERVICE_ID="";

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--service-user-id)
			SERVICE_ID="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		"") break; ;;
		*)
			echo "">&2;
			echo "Unrecognised option: $1 $2">&2;
			usage;
		;;
	esac
done;

if [ -z "$SERVICE_ID" ]; then
	echo "$0; you must provide a service user id.">&2;
	exit 2;
fi

NUMBER_REGEX='[0-9]+';

IS_NUMBER=$(echo "$SERVICE_ID" | grep -E '[0-9]+');

if [ "$IS_NUMBER" = "" ]; then
	echo "$0; the service user id must be a number.">&2;
	exit 2;
fi

if [ "$SERVICE_ID" -eq "0" ]; then
	echo "$0; the service user id must not be zero.">&2;
	exit 2;
fi

SERVICE_REGEX="^[a-zA-Z]+:x:$SERVICE_ID";

SERVICES_MATCHING_USER_ID=$(cat /etc/passwd | grep -E "$SERVICE_REGEX");

if [ -z "$SERVICES_MATCHING_USER_ID" ]; then
	echo "$0; the Service User ID is not valid.">&2;
	exit 2;
else
	exit 0;
fi

