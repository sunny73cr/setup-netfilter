#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "Set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.">&2; exit 4; fi

SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";
SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_valid.sh";
SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_service_id_is_valid.sh";

if [ ! -x $SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID ]; then
	echo "$0: script dependency failure: $SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID is missing or is not executable.">&2;
	exit 3;
fi

if [ ! -x $SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID ]; then
	echo "$0: script dependency failure: $SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID is missing or is not executable.">&2;
	exit 3;
fi

if [ ! -x $SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID ]; then
	echo "$0: script dependency failure: $SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID is missing or is not executable.">&2;
	exit 3;
fi

print_usage_and_exit() {
	echo "Usage: $0 <arguments>">&2;
	echo "Either:">&2;
	echo "1. --server-address-ipv4 X.X.X.X (where X is 0-255)">&2;
	echo "2. no restrictions on the server address.">&2;
	echo "">&2;
	echo "Either:">&2;
	echo "1. --requested-address-ipv4 X.X.X.X (where X is 0-255)">&2;
	echo "2. no restrictions on the client (requested) address.">&2;
	echo "">&2;
	echo "Note: it is strongly recommended to supply both a server and client address.">&2;
	echo "">&2;
	echo "--client-mac-address XX:XX:XX:XX:XX:XX (where X is a-f, or A-F, or 0-9 - hexadecimal)">&2;
	echo "Note: it is strongly recommended to supply the client mac address, if you know it.">&2;
	echo "">&2;
	echo "--dhcp-service-uid X (where X is 1-65535)">&2;
	echo "Note: it is strongly recommended to supply a service 'socket' user id.">&2;
	echo "Note: this relates to an entry in the /etc/passwd file. It is the user id of a designated DHCP client or server program.">&2;
	echo "Note: without this restriction, DHCP ACK packets are permitted to any program."
	echo "">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_and_exit; fi

SERVER_ADDRESS="";
REQUESTED_ADDRESS="";
CLIENT_MAC_ADDRESS="";
SERVICE_USER_ID="";

while true; do
	case $1 in
		--server-address-ipv4)
			#not enough argyments
			if [ $# -lt 2 ]; then
				print_usage_and_exit;
			#if no value, or another argument follows
			elif [ "$2" = "" ] || [ "$(echo "$2" | grep -G '^-')" != "" ]; then
				print_usage_and_exit;
			else
				SERVER_ADDRESS=$2;
				shift 2;
			fi
		;;
		--requested-address-ipv4)
			if [ $# -lt 2 ]; then
				#not enough argyments
				print_usage_and_exit;
			#if no value, or another argument follows
			elif [ "$2" = "" ] || [ "$(echo "$2" | grep -G '^-')" != "" ]; then
				#if no value
				print_usage_and_exit;
			else
				REQUESTED_ADDRESS=$2;
				shift 2;
			fi
		;;
		--client-mac-address)
			if [ $# -lt 2 ]; then
				#not enough argyments
				print_usage_and_exit;
			#if no value, or another argument follows
			elif [ "$2" = "" ] || [ "$(echo "$2" | grep -G '^-')" != "" ]; then
				#if no value
				print_usage_and_exit;
			else
				CLIENT_MAC_ADDRESS=$2;
				shift 2;
			fi
		;;
		--dhcp-service-uid)
			if [ $# -lt 2 ]; then
				#not enough argyments
				print_usage_and_exit;
			elif [ "$2" = "" ] || [ "$(echo "$2" | grep -G '^-')" != "" ]; then
				#if no value
				print_usage_and_exit;
			else
				SERVICE_ID=$2;
				shift 2;
			fi

		;;
		"") break; ;;
		*) printf "Unrecognised argument - ">&2; print_usage_then_exit;
		;;
	esac
done

if [ -n "$SERVER_ADDRESS" ]; then
	$SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address $SERVER_ADDRESS
	case $? in
		0) ;;
		1) printf "$0: the server ip address is invalid.\n"; exit 2; ;;
		*) printf "$0: script dependency failure: \"$SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced an error.\n"; exit 3 ;;
	esac
fi

if [ -n "$REQUESTED_ADDRESS" ]; then
	$SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address $REQUESTED_ADDRESS
	case $? in
		0) ;;
		1) printf "$0: the requested ip address is invalid.\n"; exit 2; ;;
		*) printf "$0: script dependency failure: \"$SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced an error.\n"; exit 3 ;;
	esac
fi

if [ -n "$CLIENT_MAC_ADDRESS" ]; then
	$SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID --address $CLIENT_MAC_ADDRESS
	case $? in
		0) ;;
		1) printf "$0: the client mac address is invalid.\n"; exit 2; ;;
		*) printf "$0: script dependency failure: \"$SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID\" produced an error.\n"; exit 3 ;;
	esac
fi

if [ -n "$SERVICE_USER_ID" ]; then
	$SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID --id $SERVICE_USER_ID
	case $? in
		0) ;;
		1) printf "$0: the service user id is invalid. (confirm the /etc/passwd entry)\n"; exit 2; ;;
		*) printf "$0: script dependency failure: \"$SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID\" produced an error.\n"; exit 3 ;;
	esac
fi

echo "\t#DHCP DECLINE message length is most likely to be 2304 bytes, or 288 octets"
echo "\t\tudp length 2304 \\";

echo "\t#Socket User ID - the program sending or receiving this packet type"
if [ -n "$SERVICE_USER_ID" ]; then
	echo "\t\tmeta skuid $SERVICE_USER_ID \\";
else
	echo "\t\t#meta skuid unknown - please consider the security implications";
fi

echo "\t#DHCP OP Code of 1 (BOOTREQUEST)";
echo "\t\t@ih,0,8 0x01 \\";

echo "\t#HTYPE (Hardware Address Type) (1 Ethernet)";
echo "\t\t@ih,8,8 1 \\";

echo "\t#HLEN (Hardware Address Length) (6 Segment MAC)";
echo "\t\t@ih,16,8 6 \\";

echo "\t#HOPS (Client sets to 0, optionally set by relay-agents)";
echo "\t\t@ih,24,8 0 \\";

echo "\t#XID (Transaction ID) client generated random number to associate communications";
echo "\t\t@ih,32,32 != 0 \\";

echo "\t#SECS (Seconds since the request was made)";
echo "\t#See RFC1541 - DHCP DECLINE should be 0 sec";
echo "\t\t@ih,64,16 0 \\";

echo "\t#Flags: no flags for DHCP DECLINE, 16 zeroes, DHCPDECLINE is not broadcasted (See RFC1541)";
echo "\t\t@ih,80,16 0 \\";

echo "\t#CIADDR (Client IP Address)";
echo "\t#In this case, the address being declined.";
if [ -n "$REQUESTED_ADDRESS" ]; then
	echo "\t\t@ih,96,8 $(echo $REQUESTED_ADDRESS | cut -d '.' -f 1) \\";
	echo "\t\t@ih,104,8 $(echo $REQUESTED_ADDRESS | cut -d '.' -f 2) \\";
	echo "\t\t@ih,112,8 $(echo $REQUESTED_ADDRESS | cut -d '.' -f 3) \\";
	echo "\t\t@ih,120,8 $(echo $REQUESTED_ADDRESS | cut -d '.' -f 4) \\";
else
	echo "\t\t#@ih,96,32 unrestricted - please consider the security implications";
fi

echo "\t#YIADDR (Your IP address) Your (client) IP address";
echo "\t\t@ih,128,32 0 \\";

echo "\t#SIADDR (Server IP address) Returned in DHCPOFFER, DHCPACK, DHCPNAK";
echo "\t\t@ih,160,32 0 \\";

echo "\t#GIADDR (Relay Agent IP address)";
echo "\t\t@ih,192,32 0 \\";

echo "\t#CHADDR (Client Hardware Address)";
#echo "\t\t@ih,224,64 0 \\";
echo "\t#Confirm each segment of the MAC address matches";
if [ -n "$CLIENT_MAC_ADDRESS" ]; then
	echo "\t\t@ih,224,8 0x$(echo $CLIENT_MAC_ADDRESS | cut -d ':' -f 1) \\";
	echo "\t\t@ih,232,8 0x$(echo $CLIENT_MAC_ADDRESS | cut -d ':' -f 2) \\";
	echo "\t\t@ih,240,8 0x$(echo $CLIENT_MAC_ADDRESS | cut -d ':' -f 3) \\";
	echo "\t\t@ih,248,8 0x$(echo $CLIENT_MAC_ADDRESS | cut -d ':' -f 4) \\";
	echo "\t\t@ih,256,8 0x$(echo $CLIENT_MAC_ADDRESS | cut -d ':' -f 5) \\";
	echo "\t\t@ih,264,8 0x$(echo $CLIENT_MAC_ADDRESS | cut -d ':' -f 6) \\";
else
	echo "\t\t#@ih,224,64 unrestricted - please consider the security implications"
fi

echo "\t#DHCP Message Type of 4 (Decline)";
echo "\t#Cannot confirm - DHCP message format is not strictly ordered"

exit 0;
