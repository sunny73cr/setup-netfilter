#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: Set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.">&2; exit 4; fi

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
	echo "Optional: --is-resuing-ipv4-address">&2;
	echo "This flag indicates that the client is in the bound, renew or rebinding stage">&2;
	echo "">&2;
	echo "Optional: --client-ipv4-address X.X.X.X (where X is 0-255)">&2;
	echo "This option should be used where the client is in the bound, renew or rebinding stage.">&2;
	echo "">&2;
	echo "Optional: --dhcp-service-uid X (where X is 1-65535)">&2;
	echo "Note: it is strongly recommended to supply a service 'socket' user id.">&2;
	echo "Note: this relates to an entry in the /etc/passwd file. It is the user id of a designated DHCP client or server program.">&2;
	echo "Note: without this restriction, DHCP ACK packets are permitted to any program."
	echo "">&2;
	echo "Developer / Special Use Flags:">&2;
	echo "--only-validate">&2;
	echo "Don't print the generated output / exit after validating inputs.">&2
	echo "">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_and_exit; fi

CLIENT_MAC_ADDRESS="";
IS_REUSING_IP_ADDRESS=0;
CLIENT_IPV4_ADDRESS="";
SERVICE_USER_ID="";

ONLY_VALIDATE=0;

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
		--is-reusing-ipv4-address)
			IS_REUSING_IP_ADDRESS=1;
			shift 1;
		;;
		--client-ipv4-address)
			if [ $# -lt 2 ]; then
				#not enough argyments
				print_usage_and_exit;
			elif [ "$2" = "" ] || [ "$(echo "$2" | grep -G '^-')" != "" ]; then
				#if no value
				print_usage_and_exit;
			else
				CLIENT_IP_ADDRESS=$2;
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
		--only-validate)
			ONLY_VALIDATE=1;
			shift 1;
		;;
		"") break; ;;
		*) printf "Unrecognised argument - ">&2; print_usage_then_exit; ;;
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

if [ $IS_REUSING_IPV4_ADDRESS -eq 0 ] && [ -n "$CLIENT_IP_ADDRESS" ]; then
	echo "$0: I cannot assume that you intend to allow a bound/renew/rebind DHCPREQUEST; please retry with the flag --is-reusing-ipv4-address enabled,">&2;
	echo "Alternatively, please omit the client IP address. Note, that the \"requested IP address\" as part of the initial DHCPREQUEST cannot be checked.">&2;
	echo "This is due to the unbound length and unordered nature of a DHCP message.">&2;
	echo "Refer to RFC2131, and RFC2132 for more information.">&2;
	exit 2;
fi

if [ $IS_REUSING_IPV4_ADDRESS -eq 1 ] && [ -z "$CLIENT_IP_ADDRESS" ]; then
	echo "$0: If you intend to allow a bound/renew/rebind DHCPREQUEST; please retry and supply a client IPV4 address/network you allow the client to rebind to,">&2;
	echo "Alternatively, please omit --is-reusing-ipv4-address flag. Note, that the \"requested IP address\" as part of the initial DHCPREQUEST cannot be checked.">&2;
	echo "This is due to the unbound length and unordered nature of a DHCP message.">&2;
	echo "Refer to RFC2131, and RFC2132 for more information.">&2;
	exit 2;
fi

if [ -n "$CLIENT_IPV4_ADDRESS" ]; then
	$SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address $CLIENT_IPV4_ADDRESS
	case $? in
		0) ;;
		1) printf "$0: the client mac address is invalid.\n"; exit 2; ;;
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

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

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

echo "\t#DHCP OP Code of 1 (BOOTREQUEST)";
echo "\t\t@ih,0,8 0x01 \\";

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

if [ $IS_REUSING_IPV4_ADDRESS -eq 1 ]; then
	#client can use unicast reply, and it should do so.

	echo "\t#Flags: broadcast flag is enabled for DHCPDISCOVER";
	echo "\t\t@ih,80,16 0 \\\\";
else
	#client must use broadcast reply. enable the broadcast bit.

	echo "\t#Flags: broadcast flag is enabled for DHCPDISCOVER";
	echo "\t\t@ih,80,1 1 \\\\";

	echo "\t#Followed by 15 zeroes. These must be zeroes as they are reserved for future use.":
	echo "\t#These bits are ignored by servers and relay agents.";
	echo "\t\t@ih,81,15 0 \\\\";
fi

echo "\t#CIADDR (Client IP Address)";
if [ $IS_REUSING_IPV4_ADDRESS -eq 1 ]; then
	if [ -n $CLIENT_IP_ADDRESS ]; then
		echo "\t\t@ih,96,8 $(echo $CLIENT_IP_ADDRESS | cut -d '.' -f 1) \\\\";
		echo "\t\t@ih,104,8 $(echo $CLIENT_IP_ADDRESS | cut -d '.' -f 2) \\\\";
		echo "\t\t@ih,112,8 $(echo $CLIENT_IP_ADDRESS | cut -d '.' -f 3) \\\\";
		echo "\t\t@ih,120,8 $(echo $CLIENT_IP_ADDRESS | cut -d '.' -f 4) \\\\";
	else
		#No address provided? How silly.
		echo "\t\t#@ih,96,32 - Cannot verify renewed address. Please consider the security implications.";
	fi
else
	echo "\t#Initial DHCP Request, client address should be empty.";
	echo "\t\t@ih,96,32 0";
fi

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

echo "\t#DHCP Message Type of 3 (Request)";
echo "\t#Cannot confirm - DHCP message format is not strictly ordered"

exit 0;
