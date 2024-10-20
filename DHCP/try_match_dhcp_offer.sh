#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_network_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_service_user_id_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_cidr_network_to_base_address.sh";

if [ ! -x $DEPENDENCY_PATH_CIDR_NETWORK_TO_BASE_ADDRESS ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_CIDR_NETWORK_TO_BASE_ADDRESS\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_cidr_network_to_end_address.sh";

if [ ! -x $DEPENDENCY_PATH_CIDR_NETWORK_TO_END_ADDRESS ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_CIDR_NETWORK_TO_END_ADDRESS\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_ipv4_address_to_decimal_number.sh";

if [ ! -x $DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_description() {
	printf "A program that prints part of an NFT rule 'match' section. The match intends to identify DHCP OFFER packets.\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "Dependencies: \n">&2;
	printf "printf\n">&2;
	printf "$DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID\n">&2;
	printf "$DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID\n">&2;
	printf "$DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID\n">&2;
	printf "$DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID\n">&2;
	printf "$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS\n">&2;
	printf "$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS\n">&2;
	printf "$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL\n">&2;
	printf "\n">&2;
}

print_dependencies_then_exit() {
	print_dependencies;
	exit 2;
}

if [ "$1" = "-d" ]; then print_dependencies_then_exit; fi

print_usage() {
	printf "Usage: $0 <parameters>\n">&2;
	printf "Flags used by themselves: \n">&2;
	printf " -e (prints an explanation of the functions' purpose) (exit code 2)\n">&2;
	printf " -h (prints an explanation of the functions' available parameters, and their effect) (exit code 2)\n">&2;
	printf " -d (prints the functions' dependencies: newline delimited list) (exit code 2)\n">&2
	printf " -ehd (prints the above three) (exit code 2)\n">&2;
	printf "\n">&2;
	printf "Parameters:\n">&2;
	printf "\n">&2;
	printf " Optional: --client-mac-address XX:XX:XX:XX:XX:XX (where X is a-f, or A-F, or 0-9 - hexadecimal)\n">&2;
	printf "  Note: it is strongly recommended to supply the client mac address, if you know it.\n">&2;
	printf "\n">&2;
	printf " Optional: --server-ipv4-address X.X.X.X (where X is 0-255)\n">&2;
	printf "  Note: the IPV4 Address offered to the DHCP server that will assign IPV4 Addresses to clients.\n">&2;
	printf "\n">&2;
	printf " Optional: --server-ipv4-network X.X.X.X/Y (where X is 0-255, and Y is 1-32)\n">&2;
	printf "  Note: a contiguous block of IPV4 Address offered to DHCP servers that will assign IPV4 Addresses to clients.\n">&2;
	printf "\n">&2;
	printf " Note: you cannot combine --server-ipv4-address and --server-ipv4-network\n">&2;
	printf "\n">&2;
	printf " Optional: --offered-ipv4-address X.X.X.X (where X is 0-255)\n">&2;
	printf "  Note: the IPV4 Address offered to the network client.\n">&2
	printf "\n">&2
	printf " Optional: --offered-ipv4-network X.X.X.X/Y (where X is 0-255, and Y is 1-32)\n">&2
	printf "  Note: a contiguous block of IPV4 Addresses that could be offered to the network client.\n">&2
	printf "\n">&2
	printf " Note: you cannot combine --offered-ipv4-address and --offered-ipv4-network\n">&2;
	printf "\n">&2;
	printf " Note: it is strongly recommended to supply both a server and client address or network.\n">&2;
	printf "\n">&2;
	printf " Optional: --transaction-id x (where x is 0-4,294,967,296)\n">&2;
	printf "  Note: the identifier of the DHCP transaction.\n">&2;
	printf "\n">&2;
	printf " Optional: --dhcp-service-uid X (where X is 1-65535)\n">&2;
	printf "  Note: it is stronly recommended to supply the user ID that is offered to the DHCP server 'service' listed in the /etc/passwd file.\n">&2;
	printf "  Note: without this restriction, DHCP OFFER packets are permitted to any program.\n";
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf "  Note: causes the program to skip validating inputs (if you know they are valid).\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validate\n">&2;
	printf "  Note: causes the program to exit after validating inputs.\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
CLIENT_MAC_ADDRESS="";
SERVER_IPV4_ADDRESS="";
SERVER_IPV4_NETWORK="";
OFFERED_IPV4_ADDRESS="";
OFFERED_IPV4_NETWORK="";
DHCP_SERVICE_UID="";
TRANSACTION_ID="";

#FLAGS:
SKIP_VALIDATION=0;
ONLY_VALIDATE=0;

while true; do
	case $1 in
		#Approach to parsing arguments:
		#If the length of 'all arguments' is less than 2 (shift reduces this number),
		#since this is an argument parameter and requires a value; the program cannot continue.
		#Else, if the argument was provided, and its 'value' is empty; the program cannot continue.
		#Else, assign the argument, and shift 2 (both the argument indicator and its value / move next)

		--client-mac-address)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				CLIENT_MAC_ADDRESS=$2;
				shift 2;
			fi
		;;

		--server-ipv4-address)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				SERVER_IPV4_ADDRESS=$2;
				shift 2;
			fi
		;;

		--server-ipv4-network)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				SERVER_IPV4_NETWORK=$2;
				shift 2;
			fi
		;;

		--offered-ipv4-address)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				OFFERED_IPV4_ADDRESS=$2;
				shift 2;
			fi
		;;

		--offered-ipv4-network)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				OFFERED_IPV4_NETWORK=$2;
				shift 2;
			fi
		;;

		--transaction-id)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				TRANSACTION_ID=$2;
				shift 2;
			fi
		;;

		--dhcp-service-uid)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				DHCP_SERVICE_UID=$2;
				shift 2;
			fi
		;;

		#Approach to parsing flags:
		#If the flag was provided, toggle on its value; then move next
		#Or shift 1 / remove the flag from the list

		--skip-validation)
			SKIP_VALIDATION=1;
			shift 1;
		;;

		--only-validation)
			ONLY_VALIDATE=1;
			shift 1;
		;;

		#Handle the case of 'end' of arg parsing; where all flags are shifted from the list,
		#or the program was called without any parameters. exit the arg parsing loop.
		"") break; ;;

		#Handle the case where an argument or flag was called that the program does not recognise.
		#This should prefix the 'usage' text with the reason the program failed.
		#The 'Standard Error' file descriptor is used to separate failure output or log messages from actual program output.
		*) printf "\nUnrecognised argument $1. ">&2; print_usage_then_exit; ;;

	esac
done;

if [ $SKIP_VALIDATION -eq 1 ] && [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

if [ $SKIP_VALIDATION -eq 0 ]; then
	if [ -n "$CLIENT_MAC_ADDRESS" ]; then
		$DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID --address $CLIENT_MAC_ADDRESS
		case $? in
			0) ;;
			1) printf "\nInvalid --client-mac-address. \n">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID\" produced a failure exit code ($?).\n">&2; exit 3; ;;
		esac
	fi

	if [ -n "$SERVER_IPV4_ADDRESS" ] && [ -n "$SERVER_IPV4_NETWORK" ]; then
		printf "\nInvalid combination of --server-ipv4-address and --server-ipv4-network. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$SERVER_IPV4_ADDRESS" ]; then
		$DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address $SERVER_IPV4_ADDRESS
		case $? in
			0) ;;
			1) printf "\nInvalid --server-ipv4-address. \n">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced a failure exit code ($?).\n">&2; exit 3; ;;
		esac
	fi

	if [ -n "$SERVER_IPV4_NETWORK" ]; then
		$DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID --network $SERVER_IPV4_NETWORK;
		case $? in
			0) ;;
			1) printf "\nInvalid --server-ipv4-network. \n">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID\" produced a failure exit code ($?).\n">&2; exit 3; ;;
		esac
	fi

	if [ -n "$OFFERED_IPV4_ADDRESS" ] && [ -n "$OFFERED_IPV4_NETWORK" ]; then
		printf "\nInvalid combination of --offered-ipv4-address and --offered-ipv4-network. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$OFFERED_IPV4_ADDRESS" ]; then
		$DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address $OFFERED_IPV4_ADDRESS;
		case $? in
			0) ;;
			1) printf "\nInvalid --offered-ipv4-address. \n">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced a failure exit code ($?).\n">&2; exit 3; ;;
		esac
	fi

	if [ -n "$OFFERED_IPV4_NETWORK" ]; then
		$DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID --network $OFFERED_IPV4_NETWORK;
		case $? in
			0) ;;
			1) printf "\nInvalid --offered-ipv4-network. \n">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID\" produced a failure exit code ($?).\n">&2; exit 3; ;;
		esac
	fi

	if [ -n "$TRANSACTION_ID" ]; then
		if [ -z "$(echo $TRANSACTION_ID | grep '[0-9]\{1,10\}')" ]; then
			printf "\nInvalid --transaction-id (must be a 1-10 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $TRANSACTION_ID -lt 0 ]; then
			printf "\nInvalid --transaction-id (must be greater than or equal to 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $TRANSACTION_ID -gt 4294967295 ]; then
			printf "\nInvalid --transaction-id (must be less than 4294967296). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$SERVICE_USER_ID" ]; then
		$DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID --id $SERVICE_USER_ID
		case $? in
			0) ;;
			1) printf "\nInvalid --dhcp-service-uid. (confirm the /etc/passwd entry). \n">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced a failure exit code ($?).\n">&2; exit 3; ;;
		esac
	fi
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

CLIENT_MAC_ADDRESS_CLEANED="";
#nft expects hexadecimal format; format the MAC address
if [ -n "$CLIENT_MAC_ADDRESS" ]; then
	CLIENT_MAC_ADDRESS_CLEANED="0x$(echo $CLIENT_MAC_ADDRESS | sed 's/://g')";
fi

OFFERED_IPV4_ADDRESS_DECIMAL="";
if [ -n "$OFFERED_IPV4_ADDRESS" ]; then
	OFFERED_IPV4_ADDRESS_DECIMAL=$($DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL --address $OFFERED_IPV4_ADDRESS);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" produced a failure exit code ($?).">&2; exit 3; ;;
	esac
fi

OFFERED_IPV4_NETWORK_BASE_ADDRESS="";
OFFERED_IPV4_NETWORK_BASE_ADDRESS_DECIMAL="";
OFFERED_IPV4_NETWORK_END_ADDRESS="";
OFFERED_IPV4_NETWORK_END_ADDRESS_DECIMAL="";
if [ -n "$OFFERED_IPV4_NETWORK" ]; then
	OFFERED_IPV4_NETWORK_BASE_ADDRESS=$($DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS --network $OFFERED_IPV4_NETWORK);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS\" produced a failure exit code ($?).">&2; exit 3; ;;
	esac

	OFFERED_IPV4_NETWORK_BASE_ADDRESS_DECIMAL=$($DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL --address $OFFERED_IPV4_NETWORK_BASE_ADDRESS);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" produced a failure exit code ($?).">&2; exit 3; ;;
	esac

	OFFERED_IPV4_NETWORK_END_ADDRESS=$($DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS --network $OFFERED_IPV4_NETWORK);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS\" produced a failure exit code ($?).">&2; exit 3; ;;
	esac

	OFFERED_IPV4_NETWORK_END_ADDRESS_DECIMAL=$($DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL --address $OFFERED_IPV4_NETWORK_END_ADDRESS);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" produced a failure exit code ($?).">&2; exit 3; ;;
	esac

fi

SERVER_IPV4_ADDRESS_DECIMAL="";
if [ -n "$SERVER_IPV4_ADDRESS" ]; then
	SERVER_IPV4_ADDRESS_DECIMAL=$($DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL --address $SERVER_IPV4_ADDRESS);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" produced a failure exit code ($?).">&2; exit 3; ;;
	esac
fi

SERVER_IPV4_NETWORK_BASE_ADDRESS="";
SERVER_IPV4_NETWORK_BASE_ADDRESS_DECIMAL="";
SERVER_IPV4_NETWORK_END_ADDRESS="";
SERVER_IPV4_NETWORK_END_ADDRESS_DECIMAL="";
if [ -n "$SERVER_IPV4_NETWORK" ]; then
	SERVER_IPV4_NETWORK_BASE_ADDRESS=$($DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS --network $SERVER_IPV4_NETWORK);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS\" produced a failure exit code ($?).">&2; exit 3; ;;
	esac

	SERVER_IPV4_NETWORK_BASE_ADDRESS_DECIMAL=$($DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL --address $SERVER_IPV4_NETWORK_BASE_ADDRESS);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" produced a failure exit code ($?).">&2; exit 3; ;;
	esac

	SERVER_IPV4_NETWORK_END_ADDRESS=$($DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS --network $SERVER_IPV4_NETWORK);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS\" produced a failure exit code ($?).">&2; exit 3; ;;
	esac

	SERVER_IPV4_NETWORK_END_ADDRESS_DECIMAL=$($DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL --address $SERVER_IPV4_NETWORK_END_ADDRESS);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" produced a failure exit code ($?).">&2; exit 3; ;;
	esac

fi

printf "\\t#DHCP message length is a minimum of 2000 bits, packet length should be greater than 250 bytes.\n";
printf "\\t#Packet length should not be longer than 512 bytes to avoid fragmentation; DHCP messages should be delivered in a single transmission.\n";
printf "\\t\\tudp length > 250 \\\\\n";
printf "\\t\\tudp length < 512 \\\\\n";

printf "\\t#Socket User ID - the program sending or receiving this packet type\n";
if [ -n "$SERVICE_USER_ID" ]; then
	printf "\\t\\tmeta skuid $SERVICE_USER_ID \\\\\n";
else
	printf "\\t\\t#meta skuid unknown - please consider the security implications\n";
fi

OFFSET_MARKER="ih";
BIT_OFFSET_HEADER_BEGIN=0;
BIT_OFFSET_OP_CODE=$BIT_OFFSET_HEADER_BEGIN;
BIT_OFFSET_HARDWARE_ADDRESS_TYPE=$(($BIT_OFFSET_OP_CODE+8));
BIT_OFFSET_HARDWARE_ADDRESS_LENGTH=$(($BIT_OFFSET_HARDWARE_ADDRESS_TYPE+8));
BIT_OFFSET_HOPS=$(($BIT_OFFSET_HARDWARE_ADDRESS_LENGTH+8));
BIT_OFFSET_XID=$(($BIT_OFFSET_HOPS+8));
BIT_OFFSET_SECONDS=$(($BIT_OFFSET_XID+32));
BIT_OFFSET_FLAGS=$(($BIT_OFFSET_SECONDS+16));
BIT_OFFSET_CLIENT_IP_ADDRESS=$(($BIT_OFFSET_FLAGS+16));
BIT_OFFSET_YOUR_IP_ADDRESS=$(($BIT_OFFSET_CLIENT_IP_ADDRESS+32));
BIT_OFFSET_SERVER_IP_ADDRESS=$(($BIT_OFFSET_YOUR_IP_ADDRESS+32));
BIT_OFFSET_GATEWAY_IP_ADDRESS=$(($BIT_OFFSET_SERVER_IP_ADDRESS+32));
BIT_OFFSET_CLIENT_HARDWARE_ADDRESS=$(($BIT_OFFSET_GATEWAY_IP_ADDRESS+32));
BIT_OFFSET_HARDWARE_ADDRESS_PADDING=$(($BIT_OFFSET_CLIENT_HARDWARE_ADDRESS+48));

printf "\\t#DHCP OP Code of 2 (BOOTREPLY)\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_OP_CODE,8 0x02 \\\\\n";

printf "\\t#HTYPE (Hardware Address Type) (1 Ethernet)\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_HARDWARE_ADDRESS_TYPE,8 1 \\\\\n";

printf "\\t#HLEN (Hardware Address Length) (6 Segment MAC)\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_HARDWARE_ADDRESS_LENGTH,8 6 \\\\\n";

printf "\\t#HOPS (Client sets to 0, optionally set by relay-agents)\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_HOPS,8 0 \\\\\n";

if [ -n "$TRANSACTION_ID" ]; then
	printf "\\t#XID (Transaction ID) client generated random number to associate communications\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_XID,32 $TRANSACTION_ID \\\\\n";
else
	printf "\\t#TransactionID is not restricted - consider the implications.\n";
fi

printf "\\t#SECS (Seconds since the request was made)\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_SECONDS,16 0 \\\\\n";

printf "\\t#Flags: Broadcast flag set for DHCP OFFER, 15 bits off following, DHCPOFFER is broadcasted (See RFC1541)\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FLAGS,1 1 \\\\\n";
printf "\\t\\t@$OFFSET_MARKER,$(($BIT_OFFSET_FLAGS+1)),15 0 \\\\\n";

printf "\\t#DHCP OFFER follows DISCOVER, this is the first allocation, and client IP address should be 0 (is not yet known)\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CLIENT_IP_ADDRESS,32 0\n";

if [ -n "$OFFERED_IPV4_ADDRESS" ] || [ -n "$OFFERED_IPV4_NETWORK" ]; then
	printf "\\t#Match YIADDR (Your IP Address)\n";
fi

if [ -n "$OFFERED_IPV4_ADDRESS" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_YOUR_IP_ADDRESS,32 $OFFERED_IPV4_ADDRESS_DECIMAL \\\\\n";
fi

if [ -n "$OFFERED_IPV4_NETWORK_BASE_ADDRESS_DECIMAL" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_YOUR_IP_ADDRESS,32 >= $OFFERED_IPV4_NETWORK_BASE_ADDRESS_DECIMAL \\\\\n";
fi

if [ -n "$OFFERED_IPV4_NETWORK_END_ADDRESS_DECIMAL" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_YOUR_IP_ADDRESS,32 <= $OFFERED_IPV4_NETWORK_END_ADDRESS_DECIMAL \\\\\n";
fi

if [ -z "$OFFERED_IPV4_ADDRESS" ] && [ -z "$OFFERED_IPV4_NETWORK" ]; then
	printf "\\t\\t#Your address/network unrestricted - please consider the secrity implications.\n";
fi

if [ -n "$SERVER_IPV4_ADDRESS" ] || [ -n "$SERVER_IPV4_NETWORK" ]; then
	printf "\\t#Match SIADDR (Server IP Address)\n";
fi

if [ -n "$SERVER_IPV4_ADDRESS" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_SERVER_IP_ADDRESS,32 $SERVER_IPV4_ADDRESS_DECIMAL \\\\\n";
fi

if [ -n "$SERVER_IPV4_NETWORK_BASE_ADDRESS_DECIMAL" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_SERVER_IP_ADDRESS,32 >= $SERVER_IPV4_NETWORK_BASE_ADDRESS_DECIMAL \\\\\n";
fi

if [ -n "$SERVER_IPV4_NETWORK_END_ADDRESS_DECIMAL" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_SERVER_IP_ADDRESS,32 <= $SERVER_IPV4_NETWORK_END_ADDRESS_DECIMAL \\\\\n";
fi

if [ -z "$SERVER_IPV4_ADDRESS" ] && [ -z "$SERVER_IPV4_NETWORK" ]; then
	printf "\\t\\t#Server address/network unrestricted - please consider the secrity implications.\n";
fi

printf "\\t#Match Gateway IP Address (Relay Agent IP address)\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_GATEWAY_IP_ADDRESS,32 0 \\\\\n";

if [ -n "$CLIENT_MAC_ADDRESS" ]; then
	printf "\\t#Match CHADDR (Client Hardware Address)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CLIENT_HARDWARE_ADDRESS,48 $CLIENT_MAC_ADDRESS_CLEANED \\\\\n";
else
	printf "\\t\\t#Client Hardware Address unrestricted - please consider the security implications\n";
fi

printf "\\t#CHADDR Padding - pad to the full 128 bits - 48 consumed; 80 bits of padding\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_HARDWARE_ADDRESS_PADDING,80 0 \\\\\n";

printf "\\t#Cannot verify beyond the CHADDR as the server host name and boot file name fields may be used for options.\n";

printf "\\t#DHCP Message Type of 2 (OFFER)\n";
printf "\\t#Cannot confirm - DHCP message format is not strictly ordered\n";

exit 0;
