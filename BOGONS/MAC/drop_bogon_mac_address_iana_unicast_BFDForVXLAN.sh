#!/bin/sh

usage () {
	echo "Usage: $0 --address-type <source|destination>">&2;
	exit 2;
}

while true; do
	case "$1" in
		--address-type )
			ADDRESS_TYPE="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		"" ) break; ;;
		*) usage; ;;
	esac
done;

if [ -z "$ADDRESS_TYPE" ]; then
	echo "$0; you must supply an address type. (try '--address-type source' or '--address-type destination' without quotes)">&2;
	exit 2;
fi

case "$ADDRESS_TYPE" in
	source) ETHER_ADDRESS_TYPE="saddr"; ;;
	destination) ETHER_ADDRESS_TYPE="daddr"; ;;
	*)
		echo "$0; unrecognised address type. (try '--address-type source' or '--address-type destination' without quotes)">&2;
		exit 2;
	;;
esac

echo "\t\tether $ETHER_ADDRESS_TYPE = 00:00:5E:00:52:02 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"Block Bogon MAC $ADDRESS_TYPE address IANA OUI BFD For VXLAN 00:00:5E:00:52:02 - \" \\";
echo "\t\tdrop;";

exit 0;