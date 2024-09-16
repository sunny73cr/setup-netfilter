#!/bin/sh

DEP_SCRIPT_PATH_VALIDATE_SERVICE="./SCRIPT_HELPERS/check_service_id_is_valid.sh";

if [ ! -x "$DEP_SCRIPT_PATH_VALIDATE_SERVICE" ]; then
	echo "$0; script dependency failure: \"$DEP_SCRIPT_PATH_VALIDATE_SERVICE\" is missing or is not executable.">&2;
	exit 3;
fi

check_success () {
	if [ "$?" -ne 0 ]; then
		echo "$0; cannot generate the rule.">&2;
		exit 3;
	fi
}

usage () {
	echo "">&2;
	echo "Usage: $0 <arguments>">&2;
	echo "optional: --service-user-id <number>">&2;
	echo "">&2;
	echo "Notes:";
	echo "-The service user ID may be applicable when the packet is exiting a client machine.">&2;
	echo "-The service user ID may be applicable when the packet is a response to a client,">&2;
	echo "-The service user ID is not applicable on an intermediary machine, like a router.">&2;
	exit 2;
}

SERVICE_UID="";

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--service-user-id)
			SERVICE_UID="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		"") break; ;;
		*)
			echo "">&2;
			echo "Unrecognised option: $1 $2">&2;
			usage;
		;;
	esac
done

if [ -n "$SERVICE_ID" ]; then
	IS_SERVICE_ID_VALID=$($DEP_SCRIPT_PATH_VALIDATE_SERVICE);
	check_success;
fi

echo "\t\tct state related \\";
if [ -n "$SERVICE_UID" ]; then
	echo "\t\tmeta skuid $SERVICE_UID \\";
fi
echo "icmp type 3 \\";
echo "icmp code 3 \\";
