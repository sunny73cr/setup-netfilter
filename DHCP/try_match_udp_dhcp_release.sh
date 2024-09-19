#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "Set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.">&2; exit 4; fi

SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_valid.sh";
SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";
SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_service_id_is_valid.sh";

if [ ! -x $SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID ]; then
	echo "$0: script dependency failure: $SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID is missing or is not executable.">&2;
	exit 3;
fi

if [ ! -x $SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID ]; then
	echo "$0: script dependency failure: $SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID is missing or is not executable.">&2;
	exit 3;
fi

if [ ! -x $SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID ]; then
	echo "$0: script dependency failure: $SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID is missing or is not executable.">&2;
	exit 3;
fi

print_usage_and_exit() {
	echo "Usage: $0 <arguments>">&2;
	echo "Optional: --client-mac-address XX:XX:XX:XX:XX:XX (where X is a-f, or A-F, or 0-9 - hexadecimal)">&2;
	echo "Note: it is strongly recommended to supply the client mac address, if you know it.">&2;
	echo "">&2;
	echo "Optional: --released-ipv4-address X.X.X.X (where X is 0-255)">&2;
	echo "Note: it is strongly recommended to supply the released address.">&2;
	echo "">&2;
	echo "Optional: --dhcp-service-uid X (where X is 1-65535)">&2;
	echo "Note: it is strongly recommended to supply a service 'socket' user id.">&2;
	echo "Note: this relates to an entry in the /etc/passwd file. It is the user id of a designated DHCP client or server program.">&2;
	echo "Note: without this restriction, DHCPRELEASE packets are permitted to any program."
	echo "">&2;
	echo "Developer / Special use flags">&2;
	echo "--only-validate">&2;
	echo "Skip output / exit after performing validation">&2;
	echo "">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_and_exit; fi

RELEASED_IPV4_ADDRESS="";
CLIENT_MAC_ADDRESS="";
SERVICE_USER_ID="";

ONLY_VALIDATION=0;

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
		--released-ipv4-address)
			if [ $# -lt 2 ]; then
				#not enough argyments
				print_usage_and_exit;
			#if no value, or another argument follows
			elif [ "$2" = "" ] || [ "$(echo "$2" | grep -G '^-')" != "" ]; then
				#if no value
				print_usage_and_exit;
			else
				RELEASED_IPV4_ADDRESS=$2;
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
				SERVICE_USER_ID=$2;
				shift 2;
			fi
		;;
		--only-validation)
			ONLY_VALIDATION=1;
			shift 1;
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
		*) printf "$0: script dependency failure: \"$SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID\" produced a failure exit code.\n"; exit 3 ;;
	esac
fi

if [ -n "$RELEASED_IPV4_ADDRESS" ]; then
	$SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address $RELEASED_IPV4_ADDRESS
	case $? in
		0) ;;
		1) printf "$0: the released ip address is invalid.\n"; exit 2; ;;
		*) printf "$0: script dependency failure: \"$SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced a failure exit code.\n"; exit 3 ;;
	esac
fi

if [ -n "$SERVICE_USER_ID" ]; then
	$SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID --id $SERVICE_USER_ID
	case $? in
		0) ;;
		1) printf "$0: the service user id is invalid. (confirm the /etc/passwd entry)\n"; exit 2; ;;
		*) printf "$0: script dependency failure: \"$SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID\" produced a failure exit code.\n"; exit 3 ;;
	esac
fi

if [ $ONLY_VALIDATION -eq 1 ]; then exit 0; fi

echo "\t#DHCP message length is a minimum of 2000 bits, packet length should be greater than 250 bytes."
echo "\t#Packet length should not be longer than 512 bytes to avoid fragmentation; DHCP messages should be delivered in a single transmission."
echo "\t\tudp length > 250 \\";
echo "\t\tudp length < 512 \\";

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
echo "\t#See RFC1541 - DHCPRELEASE should be 0 sec";
echo "\t\t@ih,64,16 0 \\";

echo "\t#Flags: no flags for DHCPRELEASE, 16 zeroes, it is not broadcasted (See RFC1541)";
echo "\t\t@ih,80,16 0 \\";

echo "\t#CIADDR (Client IP Address)";
echo "\t#In this case, the address being released.";
if [ -n "$RELEASED_IPV4_ADDRESS" ]; then
	echo "\t\t@ih,96,8 $(echo $RELEASED_IPV4_ADDRESS | cut -d '.' -f 1) \\";
	echo "\t\t@ih,104,8 $(echo $RELEASED_IPV4_ADDRESS | cut -d '.' -f 2) \\";
	echo "\t\t@ih,112,8 $(echo $RELEASED_IPV4_ADDRESS | cut -d '.' -f 3) \\";
	echo "\t\t@ih,120,8 $(echo $RELEASED_IPV4_ADDRESS | cut -d '.' -f 4) \\";
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

echo "\t#CHADDR Padding - pad to the full 128 bits - 48 consumed; 80 bits of padding";
echo "\t\t@ih,272,80 0 \\";

echo "\t#Cannot verify beyond the CHADDR as the server host name and boot file name fields may be used for options.";

echo "\t#DHCP Message Type of 7 (Release)";
echo "\t#Cannot confirm - DHCP message format is not strictly ordered"

exit 0;
