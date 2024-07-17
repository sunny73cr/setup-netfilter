#!/bin/sh

DEP_SCRIPT_PATH_VALIDATE_PORT="./SCRIPT_HELPERS/check_port_is_valid.sh";

if [ ! -x "$DEP_SCRIPT_PATH_VALIDATE_PORT" ]; then
	echo "$0; dependency script failure: \"$DEP_SCRIPT_PATH_VALIDATE_PORT\" is missing or is not executable.">&2;
	exit 3;
fi

DEP_SCRIPT_PATH_TRY_MATCH_TCP_SYN_SET="./TCP/try_match_tcp_flags_syn_set.sh";

if [ ! -x "$DEP_SCRIPT_PATH_TRY_MATCH_TCP_SYN_SET" ]; then
	echo "$0; dependency script failure: \"$DEP_SCRIPT_PATH_TRY_MATCH_TCP_SYN_SET\" is missing or is not executable.">&2;
	exit 3;
fi

DEP_SCRIPT_PATH_VALIDATE_SERVICE="./SCRIPT_HELPERS/check_service_id_is_valid.sh";

if [ ! -x "$DEP_SCRIPT_PATH_VALIDATE_SERVICE" ]; then
	echo "$0; script dependency failure: \"$DEP_SCRIPT_PATH_VALIDATE_SERVICE\" is missing or is not executable.">&2;
	exit 3;
fi

check_success () {
	if [ "$?" -ne 0 ]; then
		echo "$0; cannot match the TCP synchronise signature.">&2;
		exit 3;
	fi
}

usage () {
	echo "Usage: $0 <arguments>">&2;
	echo "Optional: --source-port <number>">&2;
	echo "Optional: --destination-port <number>">&2;
	echo "Optional: --service-user-id <number>">&2;
	echo "Note: you must set either a source or a destination port.">&2;
	echo "">&2;
	echo "Note: it is strongly recommended to supply a 'service' user ID.">&2;
	echo "To do so, the program using the ports should be assigned a dedicated user account.">&2;
	echo "You can 'extract' the user ID with the utility \"./SCRIPT_HELPERS/get_user_id_by_name.sh --id <number>\"">&2;
	echo "">&2;
	exit 2;
}

SOURCE_PORT="";
DESTINATION_PORT="";

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--source-port)
			SOURCE_PORT="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--destination-port)
			DESTINATION_PORT="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--service-user-id)
			SERVICE_UID="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		"") break; ;;
		*) usage; ;;
	esac
done

if [ -z "$SOURCE_PORT" ] && [ -z "$DESTINATION_PORT" ]; then
	echo "$0; you must provide a source or destination port.">&2;
	exit 2;
fi

if [ -n "$SOURCE_PORT" ]; then
	IS_SOURCE_PORT_VALID=$($DEP_SCRIPT_PATH_VALIDATE_PORT --port "$SOURCE_PORT");
	check_success;
fi

if [ -n "$DESTINATION_PORT" ]; then
	IS_DESTINATION_PORT_VALID=$($DEP_SCRIPT_PATH_VALIDATE_PORT --port "$DESTINATION_PORT");
	check_success;
fi

if [ -n "$SERVICE_ID" ]; then
	IS_SERVICE_ID_VALID=$($DEP_SCRIPT_PATH_VALIDATE_SERVICE --service-user-id "$SERVICE_ID");
	check_success;
fi

echo "\t\tip protocol 6 \\";

if [ -n "$SOURCE_PORT" ]; then
	echo "\t\ttcp sport $SOURCE_PORT \\";
else
	echo "\t\t#tcp sport ANY - Please consider the security implications. \\";
fi

if [ -n "$DESTINATION_PORT" ]; then
	echo "\t\ttcp dport $DESTINATION_PORT \\";
else
	echo "\t\ttcp dport ANY - Please consider the security implications. \\"
fi

echo "\t\tct state new \\";

CMD_TRY_MATCH_TCP_FLAGS_SYN_SET="$DEP_SCRIPT_PATH_TRY_MATCH_TCP_SYN_SET";
$CMD_TRY_MATCH_TCP_FLAGS_SYN_SET;
check_success;

if [ -n "$SERVICE_ID" ]; then
	echo "\t\tmeta skuid $SERVICE_ID \\";
else
	echo "\t\t#meta skuid (Socket User ID) ANY - Please consider the security implications. \\";
fi

exit 0;
