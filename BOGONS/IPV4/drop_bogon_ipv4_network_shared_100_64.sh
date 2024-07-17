#!/bin/sh

usage () {
	echo "Usage: $0 --address-type <source|destination>" 1>&2;
	exit 2;
}

ADDRESS_TYPE="";

while true; do
	case "$1" in
		--address-type )
			ADDRESS_TYPE="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		"" ) break; ;;
		*) usage; ;;
	esac
done

if [ -z "$ADDRESS_TYPE" ]; then
	echo "$0; you must provide a MAC address (try '--address-type source' or '--address-type destianation' without quotes.).">&2;
	exit 2;
fi

IP_ADDRESS_TYPE="";

case "$ADDRESS_TYPE" in
	"source") IP_ADDRESS_TYPE="saddr"; ;;
	"destination") IP_ADDRESS_TYPE="daddr"; ;;
	*)
		echo "$0; unrecognised address type (try '--address-type source' or '--address-type destianation' without quotes.)" 1>&2;
		exit 2;
	;;
esac

echo "\t\tip $IP_ADDRESS_TYPE 100.64.0.0/10 \\";
echo "\t\tlog prefix \"Block Bogon IPV4 $ADDRESS_TYPE address - Shared network 100.64.0.0 - 100.127.255.255 - \" \\";
echo "\t\tlog level warn \\";
echo "\t\tlog flags skuid flags ether \\";
echo "\t\tdrop;";
