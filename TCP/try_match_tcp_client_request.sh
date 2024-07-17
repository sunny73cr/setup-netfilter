#!/bin/sh

DEP_SCRIPT_PATH_TRY_MATCH_INTERFACE="./LAYER_1/try_match_interface.sh";

if [ ! -x "$DEP_SCRIPT_PATH_TRY_MATCH_INTERFACE" ]; then
	echo "$0; script dependency failure: \"$DEP_SCRIPT_PATH_TRY_MATCH_INTERFACE\" is missing or is not executable."
	exit 3;
fi

DEP_SCRIPT_PATH_TRY_MATCH_ETHERNET_HEADER="./ETHERNET/try_match_ethernet_header.sh";

if [ ! -x "$DEP_SCRIPT_PATH_TRY_MATCH_ETHERNET_HEADER" ]; then
	echo "$0; script dependency failure: \"$DEP_SCRIPT_PATH_TRY_MATCH_ETHERNET_HEADER\" is missing or is not executable."
	exit 3;
fi

DEP_SCRIPT_PATH_TRY_MATCH_IPV4_HEADER="./IPV4/try_match_ipv4_header.sh";

if [ ! -x "$DEP_SCRIPT_PATH_TRY_MATCH_IPV4_HEADER" ]; then
	echo "$0; script dependency failure: \"$DEP_SCRIPT_PATH_TRY_MATCH_IPV4_HEADER\" is missing or is not executable."
	exit 3;
fi

DEP_SCRIPT_PATH_TRY_MATCH_TCP_SYN="./TCP/try_match_tcp_syn.sh";

if [ ! -x "$DEP_SCRIPT_PATH_TRY_MATCH_TCP_SYN" ]; then
	echo "$0; script dependency failure: \"$DEP_SCRIPT_PATH_TRY_MATCH_TCP_SYN\" is missing or is not exectuable.";
	exit 3;
fi

check_success () {
	if [ "$?" -ne 0 ]; then
		echo "$0; cannot generate the rule.">&2;
		exit 3;
	fi
}

usage () {
	echo "">&2;
	echo "Usage: $0 <arguments>">&2;
	echo "--direction <in|out>">&2;
	echo "--interface-name <string>">&2;
	echo "optional: --vlan-id-dot1q <number>">&2;
	echo "">&2;
	echo "optional: --client-mac-address <XX:XX:XX:XX:XX:XX>">&2;
	echo "optional: --client-ipv4-address <X.X.X.X>">&2;
	echo "optional: --client-ipv4-network <X.X.X.X/X>">&2;
	echo "optional: --client-port <number>">&2;
	echo "">&2;
	echo "optional: --server-mac-address <XX:XX:XX:XX:XX:XX>">&2;
	echo "optional: --server-ipv4-address <X.X.X.X>">&2;
	echo "optional: --server-ipv4-network <X.X.X.X/X>">&2;
	echo "optional: --server-port <number>">&2;
	echo "">&2;
	echo "optional: --service-user-id <number>">&2;
	echo "">&2;
	echo "Notes:";
	echo "-It is strongly recommended to supply a server IP or network.">&2;
	echo "-Additionally, supplying a client IP or network greatly increases security.">&2;
	echo "-You cannot supply both an IP address and an IP network.">&2;
	echo "-The service user ID may be applicable when the packet is exiting a client machine.">&2;
	echo "-The service user ID may be applicable when the packet is a response to a client,">&2;
	echo "-The service user ID is not applicable on an intermediary machine, like a router.">&2;
	exit 2;
}

DIRECTION="";
INTERFACE_NAME="";
VLAN_ID="";
CLIENT_MAC="";
CLIENT_IP="";
CLIENT_NETWORK="";
CLIENT_PORT="";
SERVER_MAC="";
SERVER_IP="";
SERVER_NETWORK="";
SERVER_PORT="";
SERVICE_UID="";

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--direction)
			DIRECTION="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--interface-name)
			INTERFACE_NAME="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--vlan-id-dot1q)
			VLAN_ID_DOT1Q="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--client-mac-address)
			CLIENT_MAC="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--client-ip-address)
			CLIENT_IP="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--client-ip-network)
			CLIENT_NETWORK="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--client-port)
			CLIENT_PORT="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--server-mac-address)
			SERVER_MAC="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--server-ip-address)
			SERVER_IP="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--server-ip-network)
			SERVER_NETWORK="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--server-port)
			SERVER_PORT="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--service-user-id)
			SERVICE_UID="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		"") break; ;;
		*)
			echo "">&2;
			echo "Unrecognised option: $1 $2">&2;
			usage;
		;;
	esac
done

if [ -n "$SERVICE_ID" ]; then
	IS_SERVICE_ID_VALID=$($DEP_SCRIPT_PATH_VALIDATE_SERVICE);
	check_success;
fi

CMD_TRY_MATCH_INTERFACE="$DEP_SCRIPT_PATH_TRY_MATCH_INTERFACE";
CMD_TRY_MATCH_INTERFACE="$CMD_TRY_MATCH_INTERFACE --direction $DIRECTION";
CMD_TRY_MATCH_INTERFACE="$CMD_TRY_MATCH_INTERFACE --interface-name $INTERFACE_NAME";
if [ -n "$VLAN_ID_DOT1Q" ]; then
	CMD_TRY_MATCH_INTERFACE="$CMD_TRY_MATCH_INTERFACE --vlan-id-dot1q $VLAN_ID_DOT1Q";
fi
INTERFACE_MATCH=$($CMD_TRY_MATCH_INTERFACE);
check_success

#Static IPV4 matching for now.
#TODO: detect IPV4 or IPV6 addresses and alter ether type accordingly.
ETHER_TYPE="0x0800";

CMD_TRY_MATCH_ETHERNET_HEADER="$DEP_SCRIPT_PATH_TRY_MATCH_ETHERNET_HEADER";
CMD_TRY_MATCH_ETHERNET_HEADER="$CMD_TRY_MATCH_ETHERNET_HEADER --ether-type-id $ETHER_TYPE";
if [ -n "$VLAN_ID_DOT1Q" ]; then
	CMD_TRY_MATCH_ETHERNET_HEADER="$CMD_TRY_MATCH_ETHERNET_HEADER --vlan-id-dot1q $VLAN_ID_DOT1Q";
fi
if [ -n "$CLIENT_MAC" ]; then
	CMD_TRY_MATCH_ETHERNET_HEADER="$CMD_TRY_MATCH_ETHERNET_HEADER --source-mac-address $CLIENT_MAC";
fi
if [ -n "$SERVER_MAC" ]; then
	CMD_TRY_MATCH_ETHERNET_HEADER="$CMD_TRY_MATCH_ETHERNET_HEADER --destination-mac-address $SERVER_MAC";
fi
ETHERNET_MATCH=$($CMD_TRY_MATCH_ETHERNET_HEADER);
check_success

#Static IPV4 matching for now.
#TODO: detect IPV4 or IPV6 addresses and alter ether type accordingly.
IP_VERSION="4";

case "$IP_VERSION" in
	"4")
		CMD_TRY_MATCH_IPV4_HEADER="$DEP_SCRIPT_PATH_TRY_MATCH_IPV4_HEADER";
		CMD_TRY_MATCH_IPV4_HEADER="$CMD_TRY_MATCH_IPV4_HEADER --protocol-id 6";
		if [ -n "$CLIENT_IP" ]; then
			CMD_TRY_MATCH_IPV4_HEADER="$CMD_TRY_MATCH_IPV4_HEADER --source-ipv4-address $CLIENT_IP";
		elif [ -n "$CLIENT_NETWORK" ]; then
			CMD_TRY_MATCH_IPV4_HEADER="$CMD_TRY_MATCH_IPV4_HEADER --source-ipv4-network $CLIENT_NETWORK";
		else
			echo "$0; critical failure">&2;
			exit 3;
		fi
		if [ -n "$SERVER_IP" ]; then
			CMD_TRY_MATCH_IPV4_HEADER="$CMD_TRY_MATCH_IPV4_HEADER --destination-ipv4-address $SERVER_IP";
		elif [ -n "$SERVER_NETWORK" ]; then
			CMD_TRY_MATCH_IPV4_HEADER="$CMD_TRY_MATCH_IPV4_HEADER --destination-ipv4-network $SERVER_NETWORK";
		else
			echo "$0; critical failure">&2;
			exit 3;
		fi
		IP_MATCH=$($CMD_TRY_MATCH_IPV4_HEADER);
		check_success
	;;
	"6")
		echo "$0; ipv6 addressing is not yet supported.">&2;
		exit 4;
	;;
	*)
		echo "$0; critical failure.">&2;
		exit 4;
	;;
esac

CMD_TRY_MATCH_TCP_SYN="$DEP_SCRIPT_PATH_TRY_MATCH_TCP_SYN";
if [ -n "$CLIENT_PORT" ]; then
	CMD_TRY_MATCH_TCP_SYN="$CMD_TRY_MATCH_TCP_SYN --source-port $CLIENT_PORT";
fi
if [ -n "$SERVER_PORT" ]; then
	CMD_TRY_MATCH_TCP_SYN="$CMD_TRY_MATCH_TCP_SYN --destination-port $SERVER_PORT";
fi
if [ -n "$SERVICE_UID" ]; then
	CMD_TRY_MATCH_TCP_SYN="$CMD_TRY_MATCH_TCP_SYN --service-user-id $SERVICE_UID";
fi
PROTOCOL_MATCH=$($CMD_TRY_MATCH_TCP_SYN);
check_success

#Check packet content here, if unecrypted.

echo "$INTERFACE_MATCH";
echo "$ETHERNET_MATCH";
echo "$IP_MATCH";
echo "$PROTOCOL_MATCH";
