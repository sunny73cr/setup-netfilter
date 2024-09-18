#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "Set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.">&2; exit 4; fi

DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_valid.sh";
DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_source_is_banned.sh";
DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";
DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_network_is_valid.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS" ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS\" is missing or is not executable." 1>&2;
	exit 3;
fi

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE" ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE\" is missing or is not executable." 1>&2;
	exit 3;
fi


if [ ! -x "$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS" ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS\" is missing or is not executable." 1>&2;
	exit 3;
fi


if [ ! -x "$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK" ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK\" is missing or is not executable." 1>&2;
	exit 3;
fi

print_usage_then_exit () {
	echo "Usage: $0 <arguments>">&2;
	echo "ARGUMENTS:">&2;
	echo "Optional: --source-mac-address XX:XX:XX:XX:XX:XX (where X is a-f, or A-F, or 0-9; hexadecimal)">&2;
	echo "Note: it is strongly recommended to supply a source MAC address.">&2;
	echo "">&2;
	echo "Optional: --requested-address-ipv4 X.X.X.X (where X is 0-255)">&2
	echo "Optional: --requested-network-ipv4 X.X.X.X/Y (where X is 0-255, and Y is 1-32)" 1>&2;
	echo "Note: it is strongly recommended to supply either an address or a network.">&2;
	echo "Note: you cannot supply both an address and a network.">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

SOURCE_MAC_ADDRESS="";
REQUESTED_ADDRESS="";
REQUESTED_NETWORK="";

while true; do
	case "$1" in
		--source-mac-address)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -G '^-')" != "" ]; then
				print_usage_then_exit;
			else
				SOURCE_MAC_ADDRESS="$2";
				shift 2;
			fi
		;;

		--requested-address)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -G '^-')" != "" ]; then
				print_usage_then_exit;
			else
				REQUESTED_ADDRESS="$2";
				shift 2;
			fi
		;;

		--requested-network)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -G '^-')" != "" ]; then
				print_usage_then_exit;
			else
				REQUESTED_NETWORK="$2";
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "Unrecognised argument - "; print_usage_then_exit; ;;
	esac
done

if [ -z "$SOURCE_MAC_ADDRESS" ] && [ -z "$REQUESTED_ADDRESS" ] && [ -z "$REQUESTED_NETWORK" ]; then
	echo "$0: you must supply either a source mac address, or a requested address/network.">&2;
	exit 2;
fi

if [ -n "$SOURCE_MAC_ADDRESS" ]; then
	$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS --address "$SOURCE_MAC_ADDRESS"
	case $? in
		0) ;;
		1) echo "$0; source mac address is invalid." >&2; exit 2; ;;
		* ) echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS\" produced incorrect output" >&2; exit 3; ;;
	esac

	$DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE --address "$SOURCE_MAC_ADDRESS"
	case $? in
		1) ;;
		0) echo "$0; source mac address is not permitted." >&2; exit 2; ;;
		*) echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE\" produced incorrect output" >&2; exit 3; ;;
	esac
fi

TO_PROBE="":

if [ -n "$REQUESTED_ADDRESS" ]; then
	$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS --address "$REQUESTED_ADDRESS"
	case $? in
		0) ;;
		1) echo "$0: the ipv4 address you supplied was invalid. Try: X.X.X.X where X is a number from 0-255">&2; exit 2; ;;
		*) echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS\" produced incorrect output.">&2; exit 3; ;;
	esac

	TO_PROBE="$REQUESTED_ADDRESS";
fi

if [ -n "$REQUESTED_NETWORK" ]; then
	$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK --address "$REQUESTED_NETWORK"
	case $? in
		0) ;;
		1) echo "$0: the ipv4 network you supplied was not an address or network in CIDR form.">&2; exit 2; ;;
		*) echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK\" produced incorrect output.">&2; exit 3; ;;
	esac

	TO_PROBE="$REQUESTED_NETWORK";
fi

echo "\t#Hardware Type (1 = Ethernet)";
echo "\t\tarp htype 1 \\";

echo "\t#Hardware Length (6 = MAC address segment count)";
echo "\t\tarp hlen 6 \\";

echo "\t#Protocol Type (0x0800 = IPV4 ethertype)";
echo "\t\tarp ptype 0x0800 \\";

echo "\t#Protocol Length (4 = IPV4 segment count)";
echo "\t\tarp plen 4 \\";

echo "\t#Operation Code (1 = request)";
echo "\t\tarp operation 1 \\";

echo "\t#Source MAC address - who is informing their peers of their MAC address and IP pair";
if [ -n "$SOURCE_MAC_ADDRESS" ]; then
	echo "\t\tarp saddr ether $SOURCE_MAC_ADDRESS \\";
else
	echo "\t\t#arp saddr ether unknown - please consider the security implications";
fi

echo "\t#Destination MAC address - nobody in particular.";
echo "\t\tarp daddr ether 00:00:00:00:00:00 \\";

echo "\t#Source and Destination IP address - which IP does the MAC address own";
if [ -n "$TO_PROBE" ]; then
	echo "\t\tarp saddr ip $TO_PROBE \\";
	echo "\t\tarp daddr ip $TO_PROBE \\";
else
	echo "\t\t#arp saddr ip unknown - please consider the security implications";
	echo "\t\t#arp daddr ip unknown - please consider the security implications";
fi

exit 0;
