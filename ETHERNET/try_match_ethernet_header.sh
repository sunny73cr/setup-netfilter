#!/bin/sh

DEPENDENCY_SCRIPT_PATH_VALIDATE_ETHER_TYPE_ID="./SCRIPT_HELPERS/check_layer_2_protocol_id_is_valid.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_VALIDATE_ETHER_TYPE_ID" ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_ETHER_TYPE_ID\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS="./SCRIPT_HELPERS/check_mac_address_is_valid.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS" ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_VALIDATE_VLAN_ID="./SCRIPT_HELPERS/check_vlan_id_is_valid.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_VALIDATE_VLAN_ID" ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_VLAN_ID\" is missing or is not executable." 1>&2;
	exit 2;
fi

check_success () {
	if [ "$?" -ne 0 ]; then
		echo "$0; cannot match on the ethernet header.">&2;
		exit 3;
	fi
}

usage () {
	echo "">&2;
	echo "Usage: $0 <arguments>">&2;
	echo "--ether-type-id <string>">&2;
	echo "Optional: --vlan-id-dot1q <number>">&2;
	echo "Optional: --source-mac-address <string>">&2;
	echo "Optional: --destination-mac-address <string>">&2;
	echo "Note: you must provide either a source or a destination MAC address.">&2;
	exit 2;
}

ETHER_TYPE_ID="";
VLAN_ID_DOT1Q="";
SOURCE_ADDRESS="";
DESTINATION_ADDRESS="";

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--ether-type-id)
			ETHER_TYPE_ID="$2";
			#Not enough parameters
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		
		--vlan-id-dot1q)
			VLAN_ID_DOT1Q="$2";
			#Not enough parameters
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		
		--source-mac-address)
			SOURCE_ADDRESS="$2";
			#Not enough parameters
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		
		--destination-mac-address)
			DESTINATION_ADDRESS="$2";
			#Not enough parameters
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		"" ) break; ;;
		*)
			echo "">&2;
			echo "Unrecognised option: $1 $2">&2;
			usage;
		;;
	esac
done

IS_ETHER_TYPE_VALID=$("$DEPENDENCY_SCRIPT_PATH_VALIDATE_ETHER_TYPE_ID" --id "$ETHER_TYPE_ID");
check_success;

if [ -n "$VLAN_ID_DOT1Q" ]; then
	IS_VLAN_VALID=$("$DEPENDENCY_SCRIPT_PATH_VALIDATE_VLAN_ID" --id "$VLAN_ID_DOT1Q");
	check_success;
fi

if [ -z "$SOURCE_ADDRESS" ] && [ -z "$DESTINATION_ADDRESS" ]; then
	echo "$0; you must provide either a source or a destination address.">&2;
	echo "(try '--source-mac-address <XX:XX:XX:XX:XX:XX>' or '--destination-mac-address <XX:XX:XX:XX:XX:XX>' without quotes)">&2;
	exit 2;
fi

if [ -n "$SOURCE_ADDRESS" ]; then
	IS_SOURCE_MAC_VALID=$($DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS --address "$SOURCE_ADDRESS");
	check_success;
fi

if [ -n "$DESTINATION_ADDRESS" ]; then
	IS_DESTINATION_MAC_VALID=$($DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS --address "$DESTINATION_ADDRESS");
	check_success;
fi

if [ -n "$VLAN_ID_DOT1Q" ]; then	
	echo "\t\tether type 0x8100 \\";
	echo "\t\tvlan type $ETHER_TYPE_ID \\";
	echo "\t\tvlan id $VLAN_ID_DOT1Q \\";
else
	echo "\t\tether type $ETHER_TYPE_ID \\";
fi

if [ -n "$SOURCE_ADDRESS" ]; then
	echo "\t\tether saddr $SOURCE_ADDRESS \\";
else
	echo "\t\t#ether saddr ANY - Please consider the security implications. \\";
fi

if [ -n "$DESTINATION_ADDRESS" ]; then
	echo "\t\tether daddr $DESTINATION_ADDRESS \\";
else
	echo "\t\t#ether daddr ANY - Please consider the security implications. \\";
fi

exit 0;