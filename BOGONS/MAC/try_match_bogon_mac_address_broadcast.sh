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
	echo "$0; you must provide a MAC address 'type' (try '--address-type source' or '--address-type destianation' without quotes.).">&2;
	exit 2;
fi

MAC_ADDRESS_TYPE="";

case "$ADDRESS_TYPE" in
	"source") MAC_ADDRESS_TYPE="saddr"; ;;
	"destination") MAC_ADDRESS_TYPE="daddr"; ;;
	*)
		echo "$0; unrecognised address type (try '--address-type source' or '--address-type destianation' without quotes.)" 1>&2;
		exit 2;
	;;
esac

echo "\t\tether $MAC_ADDRESS_TYPE FF:FF:FF:FF:FF:FF \\";

exit 0;
