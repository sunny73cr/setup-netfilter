#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "Set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.">&2; exit 4; fi

SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_valid.sh";
SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_service_id_is_valid.sh";

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

CLIENT_MAC_ADDRESS="";
SERVICE_USER_ID="";

while true; do
	case $1 in
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

echo "\t#DHCP message length is a minimum of 2000 bits, packet length should be greater than 250 bytes.";
echo "\t#Packet length should not be longer than 512 bytes to avoid fragmentation; DHCP messages should be delivered in a single transmission."
echo "\t\tudp length > 250 \\";
echo "\t\tudp length < 512 \\"

echo "\t#Socket User ID - the program sending or receiving this packet type"
if [ -n "$SERVICE_USER_ID" ]; then
	echo "\t\tmeta skuid $SERVICE_USER_ID \\";
else
	echo "\t\t#meta skuid unknown - please consider the security implications";
fi

echo "\t#DHCP OP Code of 2 (BOOTREPLY)";
echo "\t\t@ih,0,8 0x02 \\";

echo "\t#HTYPE (Hardware Address Type) (1 Ethernet)";
echo "\t\t@ih,8,8 1 \\";

echo "\t#HLEN (Hardware Address Length) (6 Segment MAC)";
echo "\t\t@ih,16,8 6 \\";

echo "\t#HOPS (Client sets to 0, optionally set by relay-agents)";
echo "\t\t@ih,24,8 0 \\";

echo "\t#XID (Transaction ID, random number chosen by client; to associate client and server requests/responses)";
echo "\t\t@ih,32,32 != 0 \\";

echo "\t#SECS (Seconds since the request was made, this is a discover, so no time should have elapsed)";
echo "\t\t@ih,64,16 0 \\";

echo "\t#Flags: broadcast flag is enabled for DHCPNAK";
echo "\t\t@ih,80,1 1 \\\\";

echo "\t#Followed by 15 zeroes. These must be zeroes as they are reserved for future use.":
echo "\t#These bits are ignored by servers and relay agents.";
echo "\t\t@ih,81,15 0 \\\\";

echo "\t#CIADDR (Client IP Address)";
echo "\t\t@ih,96,32 0";

echo "\t#YIADDR (Your IP address) Your (client) IP address";
echo "\t\t@ih,128,32 0 \\";

echo "\t#SIADDR (Server IP address) Returned in DHCPOFFER, DHCPACK, DHCPNAK";
echo "\t\t@ih,160,32 0 \\";

echo "\t#GIADDR (Relay Agent IP address)";
echo "\t\t@ih,192,32 0 \\";

echo "\t#CHADDR (Client Hardware Address)";
#echo "\t\t@ih,224,128 0 \\";
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

echo "\t#CHADDR Padding - pad to the full 128 bits - 48 consumed; 80 bits of padding";
echo "\t\t@ih,272,80 0 \\";

echo "\t#Cannot verify beyond the CHADDR as server host name and boot file name fields may be used for options";

echo "\t#DHCP Message Type of 6 (NAK - Negative Acknowledgement)";
echo "\t#Cannot confirm - DHCP message format is not strictly ordered"

exit 0;
