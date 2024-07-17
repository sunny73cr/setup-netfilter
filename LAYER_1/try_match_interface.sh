#!/bin/sh

DEP_SCRIPT_PATH_VALIDATE_IFACE_BY_NAME="./SCRIPT_HELPERS/check_interface_exists_by_name.sh";

if [ ! -x "$DEP_SCRIPT_PATH_VALIDATE_IFACE_BY_NAME" ]; then
	echo "$0; script dependency failure: \"$DEP_SCRIPT_PATH_VALIDATE_IFACE_BY_NAME\" is missing or is not executable.">&2;
	exit 3;
fi

DEP_SCRIPT_PATH_VALIDATE_VLAN_ID="./SCRIPT_HELPERS/check_vlan_id_is_valid.sh";

if [ ! -x "$DEP_SCRIPT_PATH_VALIDATE_VLAN_ID" ]; then
	echo "$0; script dependency failure: \"$DEP_SCRIPT_PATH_VALIDATE_VLAN_ID\" is missing or is not executable.">&2;
	exit 3;
fi

check_success () {
	if [ "$?" -ne 0 ]; then
		echo "$0; cannot match on the interface.">&2;
		exit 3;
	fi
}

usage () {
	echo "">&2;
	echo "Usage: $0 <arguments>">&2;
	echo "--direction <in|out>">&2;
	echo "--interface-name <string>">&2;
	echo "optional: --vlan-id-dot1q <number>">&2;
	exit 2;
}

DIRECTION="";
INTERFACE_NAME="";
VLAN_ID_DOT1Q="";

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--direction )
			DIRECTION="$2";
			#not enough arguments
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--interface-name )
			INTERFACE_NAME="$2";
			#not enough arguments
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--vlan-id-dot1q )
			VLAN_ID_DOT1Q="$2";
			#not enough arguments
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

case "$DIRECTION" in
	"in") ;;
	"out") ;;
	*)
		echo "$0; unrecognised direction. you must supply a direction. (try '--direction in' or '--direction out' without quotes.)">&2;
		exit 2;
	;;
esac

if [ -n "$IS_VLAN_VALID" ]; then
	IS_VLAN_VALID=$($DEP_SCRIPT_PATH_VALIDATE_VLAN_ID --id "$VLAN_ID_DOT1Q");
	check_success;
fi

IS_IFACE_VALID=$($DEP_SCRIPT_PATH_VALIDATE_IFACE_BY_NAME --name "$INTERFACE_NAME");
check_success;

if [ $DIRECTION = "in" ]; then
	echo "\t\tmeta iifname $INTERFACE_NAME \\";
	exit 0;
elif [ $DIRECTION = "out" ]; then
	echo "\t\tmeta oifname $INTERFACE_NAME \\";
	exit 0;
fi
