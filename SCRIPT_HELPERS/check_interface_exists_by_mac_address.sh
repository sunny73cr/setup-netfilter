#!/bin/sh

DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS="./SCRIPT_HELPERS/check_mac_address_is_valid.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS" ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS\" is missing or is not executable." 1>&2;
	exit 3;
fi

check_success () {
	if [ "$?" -ne 0 ]; then
		echo "$0; cannot confirm if the interface is valid.">&2;
		exit 2;
	fi
}

usage () {
	echo "Usage: $0 --address <XX:XX:XX:XX:XX:XX>" 1>&2;
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

ALL_INTERFACE_DESCRIPTIONS_BRIEF=$(ip -br link show);

INTERFACE_DESCRIPTIONS_FILTERED_BY_NAME=$(echo "$ALL_INTERFACE_DESCRIPTIONS_BRIEF" | grep "$ADDRESS");

if [ -n "$INTERFACE_DESCRIPTIONS_FILTERED_BY_NAME" ]; then
	exit 0;
else
	echo "$0; that interface does not exist.">&2;
	exit 2;
fi
