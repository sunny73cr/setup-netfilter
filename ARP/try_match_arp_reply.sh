#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "Set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.">&2; exit 4; fi

DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_valid.sh";
DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";
DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_network_is_valid.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID" ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID\" is missing or is not executable.">&2;
	exit 3;
fi

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID" ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" is missing or is not executable.">&2;
	exit 3;
fi

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID" ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID\" is missing or is not executable.">&2;
	exit 3;
fi

print_usage_then_exit () {
	echo "Usage: $0 <arguments>">&2;
	echo "Optional: --source-address-mac XX:XX:XX:XX:XX:XX (where X is a-f, or A-F, or 0-9; hexadecimal.)">&2;
	echo "Optional: --destination-address-mac XX:XX:XX:XX:XX:XX (where X is a-f, or A-F, or 0-9; hexadecimal.)">&2;
	echo "Note: It is strongly recommended to supply a source or destination MAC Address">&2;
	echo "">&2;
	echo "Optional: --source-address-ipv4 X.X.X.X (where X is 0-255)">&2;
	echo "Optional: --source-network-ipv4 X.X.X.X/Y (where X is 0-255, and Y is 1-32)">&2;
	echo "Note: It is strongly reccomended to supply a source ipv4 address or network.">&2;
	echo "">&2;
	echo "Optional: --destination-address-ipv4 X.X.X.X (where X is 0-255)">&2;
	echo "Optional: --destination-network-ipv4 X.X.X.X/Y (where X is 0-255, and Y is 1-32)">&2;;
	echo "Note: It is strongly reccomended to supply a destination ipv4 address or network.">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

SOURCE_MAC_ADDRESS="";
DESTINATION_MAC_ADDRESS="";

SOURCE_IPV4_ADDRESS="";
SOURCE_IPV4_NETWORK="";

DESTINATION_IPV4_ADDRESS="";
DESTINATION_IPV4_NETWORK="";

while true; do
	case "$1" in
		--source-address-mac)
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
		--destination-address-mac)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -G '^-')" != "" ]; then
				print_usage_then_exit;
			else
				DESTINATION_MAC_ADDRESS="$2";
				shift 2;
			fi
		;;
		--source-address-ipv4)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -G '^-')" != "" ]; then
				print_usage_then_exit;
			else
				SOURCE_ADDRESS_IPV4="$2";
				shift 2;
			fi
		;;
		--source-network-ipv4)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -G '^-')" != "" ]; then
				print_usage_then_exit;
			else
				SOURCE_NETWORK_IPV4="$2";
				shift 2;
			fi
		;;
		--destination-address-ipv4)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -G '^-')" != "" ]; then
				print_usage_then_exit;
			else
				DESTINATION_ADDRESS_IPV4="$2";
				shift 2;
			fi
		;;
		--destination-network-ipv4)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -G '^-')" != "" ]; then
				print_usage_then_exit;
			else
				DESTINATION_NETWORK_IPV4="$2";
				shift 2;
			fi
		;;
		"") break; ;;
		*) echo "Unrecognised argument - ">&2; print_usage_then_exit; ;;
	esac
done

if [ -n "$MAC_ADDRESS_SOURCE" ]; then
	$DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID --address "$MAC_ADDRESS_SOURCE";
	case $? in
		0) ;;
		1) echo "$0; the source mac address is invalid.">&2; exit 2; ;;
		*) echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID\" produced incorrect output.">&2; exit 3; ;;
	esac
fi

if [ -n "$DESTINATION_ADDRESS_MAC" ]; then
	$DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID --address "$DESTINATION_ADDRESS_MAC";
	case $? in
		0) ;;
		1) echo "$0; the destination mac address is invalid.">&2; exit 2; ;;
		*) echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID\" produced incorrect output.">&2; exit 3; ;;
	esac
fi

if [ -n "$SOURCE_ADDRESS_IPV4" ]; then
	$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$SOURCE_ADDRESS_IPV4";
	case $? in
		0) ;;
		1) echo "$0; source ipv4 address is invalid.">&2; exit 2; ;;
		*) echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced incorrect output.">&2; exit 3; ;;
	esac
fi

if [ -n "$SOURCE_NETWORK_IPV4" ]; then
	$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID --network "$SOURCE_NETWORK_IPV4";
	case $? in
		0) ;;
		1) echo "$0; source ipv4 NETWORK is invalid.">&2; exit 2; ;;
		*) echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID\" produced incorrect output.">&2; exit 3; ;;
	esac
fi

if [ -n "$DESTINATION_ADDRESS_IPV4" ]; then
	$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$DESTINATION_ADDRESS_IPV4";
	case $? in
		0) ;;
		1) echo "$0; destination ipv4 address is invalid.">&2; exit 2; ;;
		*) echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced incorrect output.">&2; exit 3; ;;
	esac
fi

if [ -n "$DESTINATION_NETWORK_IPV4" ]; then
	$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID --network "$DESTINATION_NETWORK_IPV4";
	case $? in
		0) ;;
		1) echo "$0; destination ipv4 network is invalid.">&2; exit 2; ;;
		*) echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID\" produced incorrect output.">&2; exit 3; ;;
	esac
fi

echo "\t#Hardware Ethernet (1 = Ethernet)"
echo "\t\tarp htype 1 \\";

echo "\t#Hardware Length (6 = MAC address segment count)"
echo "\t\tarp hlen 6 \\";

echo "\t#Protocol Type (0x0800 = IPV4 ethertype)";
echo "\t\tarp ptype 0x0800 \\";

echo "\t#Protocol Length (4 = IPV4 address segment length)";
echo "\t\tarp plen 4 \\";

echo "\t#ARP OP Code (2 = reply)";
echo "\t\tarp operation 2 \\";

echo "\t#Source MAC address - who is replying to a probe.";
if [ -n "$SOURCE_MAC_ADDRESS" ]; then
	echo "arp saddr ether $MAC_ADDRESS_SOURCE \\";
else
	echo "\t\t#arp saddr ether unknown - please consider the security implications";
fi

echo "\t#Destination MAC address - who is replying to a probe.";
if [ -n "$DESTINATION_ADDRESS_MAC" ]; then
	echo "arp daddr ether $DESTINATION_ADDRESS_MAC \\";
else
	echo "\t\t#arp daddr ether unknown - please consider the security implications";
fi

echo "\t#ARP source ip address - who is replying to a probe.";
if [ -n "$SOURCE_ADDRESS_IPV4" ]; then
	echo "\t\tarp saddr ip $SOURCE_ADDRESS_IPV4 \\":

elif [ -n "$SOURCE_NETWORK_IPV4" ]
	echo "\t\tarp saddr ip $SOURCE_NETWORK_IPV4 \\";

else
	echo "\t\t#arp saddr ip unknown - please consider the security implications";
fi

echo "\t#ARP destination ip address - who is being informed of the IP's owner (hardware address)";
if [ -n "$DESTINATION_ADDRESS_IPV4" ]; then
	echo "\t\tarp daddr ip $DESTINATION_ADDRESS_IPV4 \\":

elif [ -n "$DESTINATION_NETWORK_IPV4" ]
	echo "\t\tarp daddr ip $DESTINATION_NETWORK_IPV4 \\";

else
	echo "\t\t#arp daddr ip unknown - please consider the security implications";
fi

exit 0;
