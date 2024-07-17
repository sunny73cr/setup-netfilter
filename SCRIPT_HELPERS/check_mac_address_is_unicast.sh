#!/bin/sh

DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS="./SCRIPT_HELPERS/check_mac_address_is_valid.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS" ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS\" is missing or is not executable.">&2;
	exit 3;
fi

usage () {
	echo "Usage: $0 --address <string>">&2;
	exit 2;
}

ADDRESS="";

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--address )
			ADDRESS="$2";
			#if not enough arguments
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

IS_MAC_ADDRESS_VALID=$("$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS" --address "$ADDRESS");
check_success;

FIRST_OCTET=$(echo "$ADDRESS" | cut -d ':' -f 1);

MASK_FIRST_OCTET=$(( $FIRST_OCTET&1 ));

if [ "$MASK_FIRST_OCTET" -eq 0 ]; then
#the least significant bit in the first octet is not 1.
	exit 0;
else
	echo "$0; the MAC address is not a unicast address.">&2;
	exit 2;
fi
