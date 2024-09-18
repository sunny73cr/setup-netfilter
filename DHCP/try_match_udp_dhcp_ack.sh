#!/bin/sh

SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID="./SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";

if [ ! -x $SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID ]; then
	echo "$0: script dependency failure: $SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID is missing or is not executable.">&2;
	exit 3;
fi


SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID="./SCRIPT_HELPERS/check_ipv4_network_is_valid.sh";

if [ ! -x $SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID ]; then
	echo "$0: script dependency failure: $SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID is missing or is not executable.">&2;
	exit 3;
fi

SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID="./SCRIPT_HELPERS/check_service_id_is_valid.sh";

if [ ! -x $SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID ]; then
	echo "$0: script dependency failure: $SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID is missing or is not executable.">&2;
	exit 3;
fi

usage() {
	echo "Usage: $0 <arguments>">&2;
	echo "Either:">&2;
	echo "1. --server-address-ipv4 X.X.X.X (where X is 0-255)">&2;
	echo "2. --server-network-ipv4 X.X.X.X/X (four octets where X is 0-255, and a mask where X is 1-32)">&2;
	echo "3. no restrictions on the server address.">&2;
	echo "">&2;
	echo "Either:">&2;
	echo "1. --requested-address-ipv4 X.X.X.X (where X is 0-255)">&2;
	echo "2. --requested-network-ipv4 X.X.X.X/X (four octets where X is 0-255, and a mask where X is 1-32)">&2;
	echo "3. no restrictions on the client (requested) address.">&2;
	echo "">&2;
	echo "Note: you cannot supply both an address and a network.">&2;
	echo "Note: it is strongly recommended to supply both a server address/network or a client address/network.">&2;
	echo "Note: it is strongly preferred to use a singular IP over a network (or range), in terms of firewall performance and security.">&2;
	echo "">&2;
	echo "--dhcp-service-uid X (where X is 1-65535)">&2;
	echo "Note: it is strongly recommended to supply a service 'socket' user id.">&2;
	echo "Note: this relates to an entry in the /etc/passwd file. It is the user id of a designated DHCP client or server program.">&2;
	echo "Note: without this restriction, DHCP ACK packets are permitted to any program."
	echo "">&2;
	exit 2;
}

if [ "$1" = "" ]; then usage; fi

check_success() {
	if [ "$?" -ne 0 ]; then
		echo "cannot try to match udp dhcp server ackowledgement">&2;
		exit 2;
	fi
}

SERVER_ADDRESS="";
SERVER_NETWORK="";
REQUESTED_ADDRESS="";
REQUESTED_NETWORK="";
SERVICE_USER_ID="";

while true; do
	case $1 in
		--server-address-ipv4)
			SERVER_ADDRESS=$2;
			#not enough argyments
			if [ $# -lt 2 ]; then usage; else shift 2;
		;;
		--server-network-ipv4)
			SERVER_NETWORK=$2;
			#not enough argyments
			if [ $# -lt 2 ]; then usage; else shift 2;
		;;
		--requested-address-ipv4)
			REQUESTED_ADDRESS=$2;
			#not enough argyments
			if [ $# -lt 2 ]; then usage; else shift 2;
		;;
		--requested-network-ipv4)
			REQUESTED_NETWORK=$2;
			#not enough argyments
			if [ $# -lt 2 ]; then usage; else shift 2;
		;;
		--dhcp-service-uid)
			SERVICE_ID=$2;
			#not enough argyments
			if [ $# -lt 2 ]; then usage; else shift 2;
		;;
		"") break; ;;
		*)
			echo "Unrecognised argument: $1 $2">&2:
			exit 2;
		;;
	esac
done

if [ -n $SERVER_ADDRESS ] && [ -n $SERVER_NETWORK ]; then
	echo "$0: packet source is ambiguous: you cannot supply both a client address and network.">&2;
	exit 2;
fi

if [ -n $SERVER_ADDRESS ]; then
	IS_SERVER_ADDRESS_VALID=$($SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address $SERVER_ADDRESS);
	check_success;
fi

if [ -n $SERVER_NETWORK ]; then
	IS_SERVER_NETWORK_VALID=$($SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID --address $SERVER_NETWORK);
	check_success;
fi

if [ -n $CLIENT_ADDRESS ] && [ -n $CLIENT_NETWORK ]; then
	echo "$0: packet destination is ambiguous: you cannot supply both a client address and network.">&2;
	exit 2;
fi

if [ -n $REQUESTED_ADDRESS ]; then
	IS_REQUESTED_ADDRESS_VALID=$($SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address $REQUESTED_ADDRESS);
	check_success;
fi

if [ -n $REQUESTED_NETWORK ]; then
	IS_REQUESTED_NETWORK_VALID=$($SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID --address $REQUESTED_NETWORK);
	check_success;
fi

if [ -n $SERVICE_USER_ID ]; then
	IS_SERVICE_USER_ID_VALID=$($SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID --id $SERVICE_USER_ID);
	check_success;
fi

echo "\t\tudp length < 1500 \\";

if [ -n $SERVICE_USER_ID ]; then
	echo "\t\tmeta skuid $SERVICE_USER_ID \\";
else
	echo "\t\t#meta skuid unknown - please consider the security implications";
fi

echo "\t\tDHCP OP Code of 2 (BOOTREPLY)";
echo "\t\t@ih,0,8 0x02 \\";

echo "\t\t#HTYPE (Hardware Address Type) (1 Ethernet)";
echo "\t\t@ih,8,8 1 \\";

echo "\t\t#HLEN (Hardware Address Length) (6 Segment MAC)";
echo "\t\t@ih,16,8 6 \\";

echo "\t\t#HOPS (Client sets to 0, optionally set by relay-agents)";
echo "\t\t@ih,24,8 0 \\";

echo "\t\t#XID (Transaction ID, random number chosen by client; to associate client and server requests/responses)";
echo "\t\t@ih,32,32 != 0 \\";

echo "\t\t#SECS (Seconds since the request was made)";
echo "\t\t#@ih,64,16 \\";

echo "\t\t#Flags";
echo "\t\t#The broadcast bit";
echo "\t\t@ih,80,1 0 \\";

echo "\t\t#, followed by 15 zeroes. These must be zeroes as they are reserved for future use.":
echo "\t\t#These bits are ignored by servers and relay agents.";
echo "\t\t@ih,81,15 0 \\";

echo "\t\t#CIADDR (Client IP Address)";
echo "\t\t#Filled in by client in DHCPREQUEST if verifying previously allocated configuration parameters.";
echo "\t\t@ih,96,32 0 \\";

echo "\t\t#YIADDR (Your IP address) Your (client) IP address";
echo "\t\t@ih,128,8 $(echo $REQUESTED_ADDRESS | cut -d '.' -f 1) \\";
echo "\t\t@ih,136,8 $(echo $REQUESTED_ADDRESS | cut -d '.' -f 2) \\";
echo "\t\t@ih,144,8 $(echo $REQUESTED_ADDRESS | cut -d '.' -f 3) \\";
echo "\t\t@ih,152,8 $(echo $REQUESTED_ADDRESS | cut -d '.' -f 4) \\";

echo "\t\t#SIADDR (Server IP address) Returned in DHCPOFFER, DHCPACK, DHCPNAK";
echo "\t\t@ih,160,8 $(echo $SERVER_ADDRESS | cut -d '.' -f 1) \\";
echo "\t\t@ih,168,8 $(echo $SERVER_ADDRESS | cut -d '.' -f 2) \\";
echo "\t\t@ih,176,8 $(echo $SERVER_ADDRESS | cut -d '.' -f 3) \\";
echo "\t\t@ih,184,8 $(echo $SERVER_ADDRESS | cut -d '.' -f 4) \\";

echo "\t\t#GIADDR (Relay Agent IP address)";
echo "\t\t@ih,192,32 0 \\";

echo "\t\t#CHADDR (Client Hardware Address)";
echo "\t\t#In the case of ethernet, zero. Can be used for things such as Bluetooth.";
echo "\t\t#@ih,224,64 0 \\";

echo "\t\t#SNAME (Server name) optional server host name, null terminated string.";
echo "\t\t@ih,288,512 0 \\";

echo "\t\t#File (Boot file name), null terminated string.";
echo "\t\t#\"generic\" name, or null in DHCPDISCOVER";
echo "\t\t#Fully-qualified name in DHCPOFFER";
echo "\t\t#@ih,800,1024 0 \\";

echo "\t\t#DHCP Message Type of 5 (Acknowledge)";

exit 0;
