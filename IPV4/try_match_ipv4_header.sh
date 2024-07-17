#!/bin/sh

DEPENDENCY_SCRIPT_PATH_CHECK_LAYER_4_PROTOCOL_IS_VALID="./SCRIPT_HELPERS/check_layer_4_protocol_id_is_valid.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_CHECK_LAYER_4_PROTOCOL_IS_VALID" ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_LAYER_4_PROTOCOL_IS_VALID\" is missing or is not executable.";
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS="./SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS" ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK="./SCRIPT_HELPERS/check_ipv4_network_is_valid.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK" ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK\" is missing or is not executable." 1>&2;
	exit 3;
fi

check_success () {
	if [ "$?" -ne 0 ]; then
		echo "$0; cannot match on the IPV4 header.">&2;
		exit 3;
	fi
}

usage () {
	echo "">&2;
	echo "Usage: $0 <arguments>" 1>&2;
	echo "--protocol-id <number>">&2;
	echo "Optional: --source-ipv4-address <X.X.X.X>">&2;
	echo "Optional: --source-ipv4-network <X.X.X.X/X>">&2;
	echo "Optional: --destination-ipv4-address <X.X.X.X>">&2;
	echo "Optional: --destination-ipv4-network <X.X.X.X/X>">&2;
	echo "Note: you should provide either a source or destination IP address or network.">&2;
	exit 2;
}

PROTOCOL="";
SOURCE_ADDRESS="";
DESTINATION_ADDRESS="";

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--protocol-id)
			PROTOCOL="$2";
			#not enough arguments
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--source-ipv4-address)
			SOURCE_ADDRESS="$2";
			#not enough arguments
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--source-ipv4-network)
			SOURCE_NETWORK="$2";
			#not enough arguments
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--destination-ipv4-address)
			DESTINATION_ADDRESS="$2";
			#not enough arguments
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--destination-ipv4-network)
			DESTINATION_NETWORK="$2";
			#not enough arguments
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

IS_PROTOCOL_VALID=$($DEPENDENCY_SCRIPT_PATH_CHECK_LAYER_4_PROTOCOL_IS_VALID --id "$PROTOCOL");
check_success;

if \
[ -z "$SOURCE_ADDRESS" ] && \
[ -z "$SOURCE_NETWORK" ] && \
[ -z "$DESTINATION_ADDRESS" ] && \
[ -z "$DESTINATION_NETWORK" ]; \
then
	echo "$0; you must provide either a source or destination IP address or network.">&2;
	echo "Try '--source-ipv4-address <X.X.X.X>' or '--source-ipv4-network <X.X.X.X/X>' without quotes.">&2;
	echo "Try '--destination-ipv4-address <X.X.X.X>' or '--destination-ipv4-network <X.X.X.X/X>' without quotes.">&2;
	exit 2;
fi

if [ -n "$SOURCE_ADDRESS" ] && [ -n "$SOURCE_NETWORK" ]; then
	echo "$0; you cannot supply both a source IPV4 address and an IPV4 network.">&2;
	exit 2;
fi

if [ -n "$SOURCE_ADDRESS" ]; then
	IS_SOURCE_ADDRESS_VALID=$("$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS" --address "$SOURCE_ADDRESS");
	check_success;
	
elif [ -n "$SOURCE_NETWORK" ]; then
	IS_SOURCE_NETWORK_VALID=$("$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK" --network "$SOURCE_NETWORK");
	check_success;
fi

if [ -n "$DESTINATION_ADDRESS" ] && [ -n "$DESTINATION_NETWORK" ]; then
	echo "$0; you cannot supply both a source IPV4 address and an IPV4 network.">&2;
	exit 2;
fi

if [ -n "$DESTINATION_ADDRESS" ]; then
	IS_DESTINATION_ADDRESS_VALID=$($DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS --address "$DESTINATION_ADDRESS");
	check_success;
elif [ -n "$DESTINATION_NETWORK" ]; then
	IS_DESTINATION_NETWORK_VALID=$("$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK" --network "$DESTINATION_NETWORK");
	check_success;
fi

echo "\t\tip version 4 \\";

echo "\t\tip protocol $PROTOCOL \\";

if [ -n "$SOURCE_ADDRESS" ]; then
	echo "\t\tip saddr $SOURCE_ADDRESS \\";
elif [ -n "$SOURCE_NETWORK" ]; then
	echo "\t\tip saddr \"$SOURCE_NETWORK\" \\";
else
	echo "\t\t#ip saddr ANY - Please consider the security implications. \\";
fi

if [ -n "$DESTINATION_ADDRESS" ]; then
	echo "\t\tip daddr $DESTINATION_ADDRESS \\";
elif [ -n "$DESTINATION_NETWORK" ]; then
	echo "\t\tip daddr \"$DESTINATION_NETWORK\" \\";
else
	echo "\t\t#ip daddr ANY - Please consider the security implications. \\";
fi
