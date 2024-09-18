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
	echo "Use case: a network client needs to check if an IP address is reserved by a peer.">&2;
	echo "">&2;
	echo "--source-mac-address XX:XX:XX:XX:XX:XX (where X is a-f, A-F, 0-9, or hexadecimal)">&2;
	echo "Options:">&2;
	echo "1. the mac address of the probing device">&2;
	echo "2. no restrictions on source address."
	echo "Note: it is strongly recommended to supply a source MAC address.">&2;
	echo "">&2;
	echo "--probed-address">&2
	echo "Options:">&2
	echo "--probed-address-ipv4 X.X.X.X (where X is 0-255)">&2
	echo "--probed-network-ipv4 X.X.X.X/Y (where X is 0-255, and Y is 1-32)" 1>&2;
	echo "Note: it is strongly recommended to supply either an address or a network.">&2;
	echo "Note: you cannot supply both an address and a network.">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

MAC_ADDRESS_SOURCE="";
PROBED_ADDRESS="";
PROBED_NETWORK="";

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
				MAC_ADDRESS_SOURCE=$2;
				shift 2;
			fi
		;;

		--probed-address)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -G '^-')" != "" ]; then
				print_usage_then_exit;
			else
				PROBED_ADDRESS=$2;
				shift 2;
			fi
		;;

		--probed-network)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -G '^-')" != "" ]; then
				print_usage_then_exit;
			else
				PROBED_NETWORK=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "Unrecognised argument - "; print_usage_then_exit; ;;
	esac
done

if [ -n "$MAC_ADDRESS_SOURCE" ]; then
	$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS --address "$MAC_ADDRESS_SOURCE";
	case $? in
		0) ;;
		1) echo "$0; source mac address is invalid." >&2;						exit 2; ;;
		*) echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS\"" >&2;  exit 3; ;;
	esac

	$DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE --address "$MAC_ADDRESS_SOURCE"
	case $? in
		1) ;;
		0) echo "$0; source mac address is not permitted." >&2; 									    exit 2; ;;
		*) echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE\" produced incorrect output" >&2; exit 3; ;;
	esac
fi

TO_PROBE="":

if [ -n "$PROBED_ADDRESS" ]; then
	$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS --address "$PROBED_ADDRESS"
	case $? in
		0) ;;
		1) echo "$0: the ipv4 address you supplied was invalid. Try: X.X.X.X where X is a number from 0-255">&2; 		  exit 2; ;;
		*) echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS\" produced incorrect output.">&2; exit 3; ;;
	esac

	TO_PROBE="$PROBED_ADDRESS";
fi

if [ -n "$PROBED_NETWORK" ]; then
	$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK --address "$PROBED_NETWORK"
	case $? in
		0) ;;
		1) echo "$0: the ipv4 network you supplied was not an address or network in CIDR form.">&2; 				  exit 2; ;;
		*) echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK\" produced incorrect output.">&2; exit 3; ;;
	esac

	TO_PROBE="$PROBED_NETWORK";
fi

echo "\t#Hardware Type (1 = Ethernet)"
echo "\t\tarp htype 1 \\";

echo "\t#Hardware Length (6 = MAC segment count)"
echo "\t\tarp hlen 6 \\";

echo "\t#Protocol Type (0x0800 = 'IPV4' ethertype";
echo "\t\tarp ptype 0x0800 \\";

echo "\t#Protocol Length (4 = IPV4 segment count)"
echo "\t\tarp plen 4 \\";

echo "\t#Operation code (1 = request)"
echo "\t\tarp operation 1 \\";

echo "\t#ARP source MAC - who is asking";
if [ -n "$MAC_ADDRESS_SOURCE" ]; then
	echo "\t\tarp saddr ether $MAC_ADDRESS_SOURCE \\";
else
	echo "\t\t#arp saddr ether unknown - please consider the security implications";
fi

echo "\t#ARP destination mac - who to ask (unknown in a 'probe')";
echo "\t\tarp daddr ether 00:00:00:00:00:00 \\";

echo "\t#ARP source ip address - who is asking (not yet assigned in a 'probe')";
echo "\t\tarp saddr ip 0.0.0.0 \\";

echo "\t#ARP destination ip address - who to ask (for their mac address)";
if [ -n "$TO_PROBE" ]; then
	echo "\t\tarp daddr ip $TO_PROBE \\";
else
	echo "\t\t#arp daddr ip unknown - please consider the security implications";
fi

exit 0;
