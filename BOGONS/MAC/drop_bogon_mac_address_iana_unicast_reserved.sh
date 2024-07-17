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
	echo "$0; you must supply an address type. (try '--address-type <source>' or '--address-type <destination>' without quotes)">&2;
	exit 2;
fi

case "$ADDRESS_TYPE" in
	"source") ETHER_ADDRESS_TYPE="saddr"; ;;
	"destination") ETHER_ADDRESS_TYPE="daddr"; ;;
	*)
		echo "$0; unrecognised address type. (try '--address-type <source>' or '--address-type <destination>' without quotes">&2;
		exit 2;
	;;
esac

echo "\t\tether $ETHER_ADDRESS_TYPE >= 00:00:5E:00:00:00 \\";
echo "\t\tether $ETHER_ADDRESS_TYPE <= 00:00:5E:00:00:FF \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"Block Bogon MAC $ADDRESS_TYPE address - IANA OUI Reserved 00:00:5E:00:00:00 to 00:00:5E:00:00:FF - \" \\";
echo "\t\tdrop;";

echo "\t\tether $ETHER_ADDRESS_TYPE >= 00:00:5E:00:03:00 \\";
echo "\t\tether $ETHER_ADDRESS_TYPE <= 00:00:5E:00:51:FF \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"Block Bogon MAC $ADDRESS_TYPE address - IANA OUI Reserved 00:00:5E:00:03:00 to 00:00:5E:00:51:FF - \" \\";
echo "\t\tdrop;";

echo "\t\tether $ETHER_ADDRESS_TYPE >= 00:00:5E:00:52:03 \\";
echo "\t\tether $ETHER_ADDRESS_TYPE <= 00:00:5E:00:52:12 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"Block Bogon MAC $ADDRESS_TYPE address - IANA OUI Reserved 00:00:5E:00:52:03 to 00:00:5E:00:52:12 - \" \\";
echo "\t\tdrop;";

echo "\t\tether $ETHER_ADDRESS_TYPE >= 00:00:5E:00:52:14 \\";
echo "\t\tether $ETHER_ADDRESS_TYPE <= 00:00:5E:00:52:FF \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"Block Bogon MAC $ADDRESS_TYPE address - IANA OUI Reserved 00:00:5E:00:52:14 to 00:00:5E:00:52:FF - \" \\";
echo "\t\tdrop;";

echo "\t\tether $ETHER_ADDRESS_TYPE >= 00:00:5E:00:53:00 \\";
echo "\t\tether $ETHER_ADDRESS_TYPE <= 00:00:5E:00:53:FF \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"Block Bogon MAC $ADDRESS_TYPE address - IANA OUI For use in documentation 00:00:5E:00:00:00 to 00:00:5E:00:00:FF - \" \\";
echo "\t\tdrop;";

echo "\t\tether $ETHER_ADDRESS_TYPE >= 00:00:5E:00:54:00 \\";
echo "\t\tether $ETHER_ADDRESS_TYPE <= 00:00:5E:90:00:FF \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"Block Bogon MAC $ADDRESS_TYPE address - IANA OUI Reserved 00:00:5E:00:54:00 to 00:00:5E:90:00:FF - \" \\";
echo "\t\tdrop;";

echo "\t\tether $ETHER_ADDRESS_TYPE >= 00:00:5E:90:01:01 \\";
echo "\t\tether $ETHER_ADDRESS_TYPE <= 00:00:5E:90:01:FF \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"Block Bogon MAC $ADDRESS_TYPE address - IANA OUI Reserved 00:00:5E:90:01:01 to 00:00:5E:90:01:FF - \" \\";
echo "\t\tdrop;";

echo "\t\tether $ETHER_ADDRESS_TYPE >= 00:00:5E:90:02:00 \\";
echo "\t\tether $ETHER_ADDRESS_TYPE <= 00:00:5E:FF:FF:FF \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"Block Bogon MAC $ADDRESS_TYPE address - IANA OUI Reserved 00:00:5E:90:02:00 to 00:00:5E:90:FF:FF - \" \\";
echo "\t\tdrop;";

exit 0;
