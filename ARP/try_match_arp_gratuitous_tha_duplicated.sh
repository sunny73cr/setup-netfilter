#!/bin/sh

DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS="./SCRIPT_HELPERS/check_mac_address_is_valid.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS" ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE="./SCRIPT_HELPERS/check_mac_address_source_is_banned.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE" ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE\" is missing or is not executable." 1>&2;
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

usage () {
	echo "Usage: $0 <arguments>">&2;
	echo "ARGUMENTS:">&2;
	echo "optional: --source-mac-address <string>">&2;
	echo "Note: it is strongly recommended to supply a source MAC address.">&2;
	echo "">&2;
	echo "optional: --requested-address-ipv4 <X.X.X.X eg. 10.0.0.1>">&2
	echo "optional: --requested-network-ipv4 <X.X.X.X/X eg. 10.0.0.0/8 or 10.0.0.1/32>" 1>&2;
	echo "Note: it is strongly recommended to supply either an address or a network.">&2;
	echo "Note: you cannot supply both an address and a network.">&2;
	exit 2;
}

if [ "$1" = "" ]; then usage; fi

MAC_ADDRESS_SOURCE="";
REQUESTED_ADDRESS="";
REQUESTED_NETWORK="";

while true; do
	case "$1" in
		--source-mac-address)
			MAC_ADDRESS_SOURCE="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;

		--requested-address)
			REQUESTED_ADDRESS="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;

		--requested-network)
			REQUESTED_NETWORK="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		"") break; ;;
		*) usage; ;;
	esac
done

if [ -z "$MAC_ADDRESS_SOURCE" ] && [ -z "$REQUESTED_ADDRESS" ] && [ -z "$REQUESTED_NETWORK" ]; then
	echo "$0: you must supply either a source mac address, or a requested address/network.">&2;
	exit 2;
fi

if [ -n "$MAC_ADDRESS_SOURCE" ]; then
	IS_SOURCE_MAC_VALID=$($DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS --address "$MAC_ADDRESS_SOURCE");

	case $IS_SOURCE_MAC_VALID in
		"true" ) ;;
		"false" )
			echo "$0; source mac address is invalid." >&2;
			exit 2;
		;;
		* )
			echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS\" produced incorrect output" >&2;
			exit 3;
		;;
	esac

	IS_SOURCE_MAC_BANNED=$($DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE --address "$MAC_ADDRESS_SOURCE");

	case $IS_SOURCE_MAC_BANNED in
		"true" )
			echo "$0; source mac address is not permitted." >&2;
			exit 2;
		;;
		"false" ) ;;
		* )
			echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE\" produced incorrect output" >&2;
			exit 3;
		;;
	esac
fi

TO_PROBE="":

if [ -n "$REQUESTED_ADDRESS" ]; then
	IS_REQUESTED_ADDRESS_VALID=$($DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS --address "$REQUESTED_ADDRESS");

	case "$IS_REQUESTED_ADDRESS_VALID" in
		"true") ;;
		"false")
			echo "$0: the ipv4 address you supplied was invalid. Try: X.X.X.X where X is a number from 0-255">&2;
			exit 2;
		;;
		*)
			echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS\" produced incorrect output.">&2;
			exit 3;
		;;
	esac

	TO_PROBE="$REQUESTED_ADDRESS";
fi

if [ -n "$REQUESTED_NETWORK" ]; then
	IS_REQUESTED_NETWORK_VALID=$($DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK --address "$REQUESTED_NETWORK");

	case "$IS_REQUESTED_NETWORK_VALID" in
		"true") ;;
		"false")
			echo "$0: the ipv4 network you supplied was not an address or network in CIDR form.">&2;
			exit 2;
		;;
		*)
			echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK\" produced incorrect output.">&2;
			exit 3;
		;;
	esac

	TO_PROBE="$REQUESTED_NETWORK";
fi

echo "\t\tarp htype 1 \\";
echo "\t\tarp hlen 6 \\";

echo "\t\tarp ptype 0x0800 \\";
echo "\t\tarp plen 4 \\";

echo "\t\tarp operation 1 \\";

if [ -n "$MAC_ADDRESS_SOURCE" ]; then
	echo "\t\tarp saddr ether $MAC_ADDRESS_SOURCE \\";
	echo "\t\tarp daddr ether $MAC_ADDRESS_SOURCE \\";
else
	echo "\t\t#arp saddr ether unknown - please consider the security implications";
fi

if [ -n "$TO_PROBE" ]; then
	echo "\t\tarp saddr ip $TO_PROBE \\";
	echo "\t\tarp daddr ip $TO_PROBE \\";
else
	echo "\t\t#arp daddr ip unknown - please consider the security implications";
fi

exit 0;
