#!/bin/sh

DEPENDENCY_SCRIPT_PATH_VALIDATE_PORT="./SCRIPT_HELPERS/check_port_is_valid.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_VALIDATE_PORT ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_PORT\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEP_SCRIPT_PATH_VALIDATE_SERVICE="./SCRIPT_HELPERS/check_service_id_is_valid.sh";

if [ ! -x "$DEP_SCRIPT_PATH_VALIDATE_SERVICE" ]; then
	echo "$0; script dependency failure: \"$DEP_SCRIPT_PATH_VALIDATE_SERVICE\" is missing or is not executable.">&2;
	exit 3;
fi

check_success () {
	if [ "$?" -ne 0 ]; then
		echo "$0; cannot match udp session start.">&2;
		exit 3;
	fi
}

usage () {
	echo "Usage: $0 --source-port <number> --destination-port <number>" 1>&2;
	exit 2;
}

if [ -z "$1" ] || [ "$1" = "-h" ]; then
	usage;
	exit 2;
fi

SOURCE_PORT="";
DESTINATION_PORT="";
SERVICE_UID="";

while true; do
	case "$1" in
		--source-port )
			SOURCE_PORT="$2";
			shift 2;
		;;
		--destination-port )
			DESTINATION_PORT="$2";
			shift 2;
		;;
		--service-user-id )
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
done;

IS_SOURCE_PORT_VALID=$($DEPENDENCY_SCRIPT_PATH_VALIDATE_PORT --port "$SOURCE_PORT" --port-label "source");
check_success;

IS_DESTINATION_PORT_VALID=$($DEPENDENCY_SCRIPT_PATH_VALIDATE_PORT --port "$DESTINATION_PORT" --port-label "destination");
check_success;

IS_SERVICE_ID_VALID=$($DEP_SCRIPT_PATH_VALIDATE_SERVICE --service-user-id "$SERVICE_UID");
check_success;

echo "\t\tip protocol 17 \\";

echo "\t\tudp sport $SOURCE_PORT \\";

echo "\t\tudp dport $DESTINATION_PORT \\";

echo "\t\tct state established \\";

if [ -n "$SERVICE_UID" ]; then
	echo "\t\tmeta skuid $SERVICE_UID \\";
fi

exit 0;
