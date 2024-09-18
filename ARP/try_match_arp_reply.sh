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

usage () {
	echo "Usage: $0 <arguments>">&2;
	echo "Optional: --source-address-mac <XX:XX:XX:XX:XX:XX eg. 02:00:00:00:00:01>">&2;
	echo "Optional: --destination-address-mac <XX:XX:XX:XX:XX:XX eg. 02:00:00:00:00:02>">&2;
	echo "Note: It is strongly recommended to supply a source or destination MAC Address">&2;
	echo "">&2;

	echo "Optional: --source-address-ipv4 <X.X.X.X eg. 10.0.0.1>">&2;
	echo "Optional: --source-network-ipv4 <X.X.X.X/X eg. 10.0.0.0/8>">&2;
	echo "Note: It is strongly reccomended to supply a source ipv4 address or network.">&2;
	echo "">&2;

	echo "Optional: --destination-address-ipv4 <X.X.X.X eg. 10.0.0.1>">&2;
	echo "Optional: --destination-network-ipv4 <X.X.X.X/X eg. 10.0.0.0/8>">&2;;
	echo "Note: It is strongly reccomended to supply a destination ipv4 address or network.">&2;
	exit 2;
}

if [ "$1" = "" ]; then usage; fi

SOURCE_ADDRESS_MAC="";
DESTINATION_MAC_ADDRESS="";

SOURCE_IPV4_ADDRESS="";
SOURCE_IPV4_NETWORK="";

DESTINATION_IPV4_ADDRESS="";
DESTINATION_IPV4_NETWORK="";

while true; do
	case "$1" in
		--source-address-mac)
			SOURCE_ADDRESS_MAC="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--destination-address-mac)
			DESTINATION_ADDRESS_MAC="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--source-address-ipv4)
			SOURCE_ADDRESS_IPV4="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--source-network-ipv4)
			SOURCE_NETWORK_IPV4="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--destination-address-ipv4)
			DESTINATION_ADDRESS_IPV4="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--destination-network-ipv4)
			DESTINATION_NETWORK_IPV4="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		"") break; ;;
		*) usage; ;;
	esac
done

if [ -n "$SOURCE_ADDRESS_MAC" ]; then
	IS_SOURCE_MAC_VALID=$($DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID --address "$SOURCE_ADDRESS_MAC");

	case "$IS_SOURCE_MAC_VALID" in
		"true") ;;
		"false")
			echo "$0; the source mac address is invalid.">&2;
			exit 2;
		;;
		*)
			echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID\" produced incorrect output.">&2;
			exit 3;
		;;
	esac
fi

if [ -n "$DESTINATION_ADDRESS_MAC" ]; then
	IS_DESTINATION_MAC_VALID=$($DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID --address "$DESTINATION_ADDRESS_MAC");

	case "$IS_DESTINATION_MAC_VALID" in
		"true") ;;
		"false")
			echo "$0; the destination mac address is invalid.">&2;
			exit 2;
		;;
		*)
			echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID\" produced incorrect output.">&2;
			exit 3;
		;;
	esac
fi

if [ -n "$SOURCE_ADDRESS_IPV4" ]; then
	IS_SOURCE_ADDRESS_IPV4_VALID=$($DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$SOURCE_ADDRESS_IPV4");

	case "$IS_SOURCE_ADDRESS_IPV4_VALID" in
		"true") ;;
		"false")
			echo "$0; source ipv4 address is invalid.">&2;
			exit 2;
		;;
		*)
			echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced incorrect output.">&2;
			exit 3;
		;;
	esac
fi

if [ -n "$SOURCE_NETWORK_IPV4" ]; then
	IS_SOURCE_NETWORK_IPV4_VALID=$($DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID --network "$SOURCE_NETWORK_IPV4");

	case "$IS_SOURCE_NETWORK_IPV4_VALID" in
		"true") ;;
		"false")
			echo "$0; source ipv4 NETWORK is invalid.">&2;
			exit 2;
		;;
		*)
			echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID\" produced incorrect output.">&2;
			exit 3;
		;;
	esac
fi

if [ -n "$DESTINATION_ADDRESS_IPV4" ]; then
	IS_DESTINATION_ADDRESS_IPV4_VALID=$($DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$DESTINATION_ADDRESS_IPV4");

	case "$IS_DESTINATION_ADDRESS_IPV4_VALID" in
		"true") ;;
		"false")
			echo "$0; destination ipv4 address is invalid.">&2;
			exit 2;
		;;
		*)
			echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced incorrect output.">&2;
			exit 3;
		;;
	esac
fi

if [ -n "$DESTINATION_NETWORK_IPV4" ]; then
	IS_DESTINATION_NETWORK_IPV4_VALID=$($DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID --network "$DESTINATION_NETWORK_IPV4");

	case "$IS_DESTINATION_NETWORK_IPV4_VALID" in
		"true") ;;
		"false")
			echo "$0; destination ipv4 network is invalid.">&2;
			exit 2;
		;;
		*)
			echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID\" produced incorrect output.">&2;
			exit 3;
		;;
	esac
fi

echo "\t\tarp htype 1 \\";
echo "\t\tarp hlen 6 \\";

echo "\t\tarp ptype 0x0800 \\";
echo "\t\tarp plen 4 \\";

echo "\t\tarp operation 2 \\";

if [ -n "$SOURCE_ADDRESS_MAC" ]; then
	echo "arp saddr ether $SOURCE_ADDRESS_MAC \\";
else
	echo "\t\t#arp saddr ether unknown - please consider the security implications";
fi

if [ -n "$DESTINATION_ADDRESS_MAC" ]; then
	echo "arp daddr ether $DESTINATION_ADDRESS_MAC \\";
else
	echo "\t\t#arp daddr ether unknown - please consider the security implications";
fi

if [ -n "$SOURCE_ADDRESS_IPV4" ]; then
	echo "\t\tarp saddr ip $SOURCE_ADDRESS_IPV4 \\":

elif [ -n "$SOURCE_NETWORK_IPV4" ]
	echo "\t\tarp saddr ip $SOURCE_NETWORK_IPV4 \\";

else
	echo "\t\t#arp saddr ip unknown - please consider the security implications";
fi

if [ -n "$DESTINATION_ADDRESS_IPV4" ]; then
	echo "\t\tarp daddr ip $DESTINATION_ADDRESS_IPV4 \\":

elif [ -n "$DESTINATION_NETWORK_IPV4" ]
	echo "\t\tarp daddr ip $DESTINATION_NETWORK_IPV4 \\";

else
	echo "\t\t#arp daddr ip unknown - please consider the security implications";
fi

exit 0;
