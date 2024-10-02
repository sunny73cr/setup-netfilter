#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_valid.sh";
SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";
SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_service_id_is_valid.sh";

if [ ! -x $SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID ]; then
	printf "$0: dependency \"$SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID\" is missing or is not executable.">&2;
	exit 3;
fi

if [ ! -x $SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID ]; then
	printf "$0: dependency \"$SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" is missing or is not executable.">&2;
	exit 3;
fi

if [ ! -x $SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID ]; then
	printf "$0: dependency \"$SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID\" is missing or is not executable.">&2;
	exit 3;
fi

print_description() {
	printf "A program that prints part of an NFT rule 'match' section. The match intends to identify DHCP Release packets.\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "printf\n">&2;
	printf "printf\n">&2;
	printf "\n">&2;
}

print_dependencies_then_exit() {
	print_dependencies;
	exit 2;
}

if [ "$1" = "-d" ]; then print_dependencies_then_exit; fi

print_usage() {
	printf "Usage: $0 <parameters>\n">&2;
	printf " -e\n">&2;
	printf " calling the program with the '-e' flag prints an explanation of the scripts' function or purpose.\n">&2;
	printf " The program then exits with a code of 2 (user input error).\n">&2;
	printf "\n">&2;
	printf " -h\n">&2;
	printf " calling the program with the '-h' flag prints an explanation of the scripts' parameters and their effect.\n">&2;
	printf " The program then exits with a code of 2 (user input error).\n">&2;
	printf "\n">&2;
	printf " -d\n">&2;
	printf " callling the program with the '-d' flags prints a (new-line separated, and terminated) list of the programs' dependencies (what it needs to run).\n">&2;
	printf " The program then exits with a code of 2 (user input error).\n">&2;
	printf "\n">&2;
	printf " -ehd\n">&2;
	printf " calling the program with the '-ehd' flag (or, ehd-ucate me) prints the description, the dependencies list, and the usage text.\n">&2;
	printf " The program then exits with a code of 2 (user input error).\n">&2;
	printf "\n">&2;
	printf " Note that calling all scripts in a project with the flag '-ehd', then concatenating their output using file redirection (string > file),\n">&2;
	printf " Is a nice and easy way to maintain documentation for your project.\n">&2;
	printf "\n">&2;
	printf "Parameters:\n">&2;
	printf "\n">&2;
	printf " Optional: --client-mac-address XX:XX:XX:XX:XX:XX (where X is a-f, or A-F, or 0-9 - hexadecimal)">&2;
	printf " Note: it is strongly recommended to supply the client mac address, if you know it.">&2;
	printf "\n">&2;
	printf " Optional: --released-ipv4-address X.X.X.X (where X is 0-255)">&2;
	printf " Note: it is strongly recommended to supply the released address.">&2;
	printf "\n">&2;
	printf " Optional: --dhcp-service-uid X (where X is 1-65535)">&2;
	printf " Note: it is strongly recommended to supply the user ID that is assigned to the DHCP server 'service' listed in the /etc/passwd file.\n">&2;
	printf " Note: without this restriction, DHCPRELEASE packets are permitted to any program."
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf " Note: enabling this flag causes the program to skip validating inputs (if you know they are valid).\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validate\n">&2;
	printf " Note: enabling this flag causes the program to exit after validating inputs.\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
RELEASED_ADDRESS_IPV4="";
CLIENT_MAC_ADDRESS="";
DHCP_SERVICE_UID="";

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

		--released-address-ipv4)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				RELEASED_ADDRESS_IPV4=$2;
				shift 2;
			fi
		;;

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

		--only-validate)
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
		$SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID --address $CLIENT_MAC_ADDRESS
		case $? in
			0) ;;
			1) printf "\nInvalid --client-mac-address. "; print_usage_then_exit; ;;
			*) printf "$0: dependency \"$SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID\" produced a failure exit code.\n"; exit 3; ;;
		esac
	fi

	if [ -n "$RELEASED_ADDRESS_IPV4" ]; then
		$SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address $RELEASED_ADDRESS_IPV4
		case $? in
			0) ;;
			1) printf "\nInvalid --released-address-ipv4. "; print_usage_then_exit; ;;
			*) printf "$0: dependency \"$SCRIPT_DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced a failure exit code.\n"; exit 3; ;;
		esac
	fi

	if [ -n "$SERVICE_USER_ID" ]; then
		$SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID --id $SERVICE_USER_ID
		case $? in
			0) ;;
			1) printf "\nInvalid --dhcp-service-uid. (confirm the /etc/passwd entry). "; print_usage_then_exit; ;;
			*) printf "$0: dependency \"$SCRIPT_DEPENDENCY_PATH_CHECK_SERVICE_USER_ID_IS_VALID\" produced a failure exit code.\n"; exit 3; ;;
		esac
	fi
fi

if [ $ONLY_VALIDATION -eq 1 ]; then exit 0; fi

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

printf "\\t#DHCP OP Code of 1 (BOOTREQUEST)\n";
printf "\\t\\t@ih,0,8 0x01 \\\\\n";

printf "\\t#HTYPE (Hardware Address Type) (1 Ethernet)\n";
printf "\\t\\t@ih,8,8 1 \\\\\n";

printf "\\t#HLEN (Hardware Address Length) (6 Segment MAC)\n";
printf "\\t\\t@ih,16,8 6 \\\\\n";

printf "\\t#HOPS (Client sets to 0, optionally set by relay-agents)\n";
printf "\\t\\t@ih,24,8 0 \\\\\n";

printf "\\t#XID (Transaction ID) client generated random number to associate communications\n";
printf "\\t\\t@ih,32,32 != 0 \\\\\n";

printf "\\t#SECS (Seconds since the request was made)\n";
printf "\\t#See RFC1541 - DHCPRELEASE should be 0 sec\n";
printf "\\t\\t@ih,64,16 0 \\\\\n";

printf "\\t#Flags: no flags for DHCPRELEASE, 16 zeroes, it is not broadcasted (See RFC1541)\n";
printf "\\t\\t@ih,80,16 0 \\\\\n";

printf "\\t#CIADDR (Client IP Address)\n";
printf "\\t#In this case, the address being released.\n";
if [ -n "$RELEASED_ADDRESS_IPV4" ]; then
	printf "\\t\\t@ih,96,8 $(echo $RELEASED_ADDRESS_IPV4 | cut -d '.' -f 1) \\\\\n";
	printf "\\t\\t@ih,104,8 $(echo $RELEASED_ADDRESS_IPV4 | cut -d '.' -f 2) \\\\\n";
	printf "\\t\\t@ih,112,8 $(echo $RELEASED_ADDRESS_IPV4 | cut -d '.' -f 3) \\\\\n";
	printf "\\t\\t@ih,120,8 $(echo $RELEASED_ADDRESS_IPV4 | cut -d '.' -f 4) \\\\\n";
else
	printf "\\t\\t#@ih,96,32 unrestricted - please consider the security implications\n";
fi

printf "\\t#YIADDR (Your IP address) Your (client) IP address\n";
printf "\\t\\t@ih,128,32 0 \\\\\n";

printf "\\t#SIADDR (Server IP address) Returned in DHCPOFFER, DHCPACK, DHCPNAK\n";
printf "\\t\\t@ih,160,32 0 \\\\\n";

printf "\\t#GIADDR (Relay Agent IP address)\n";
printf "\\t\\t@ih,192,32 0 \\\\\n";

printf "\\t#CHADDR (Client Hardware Address)\n";
#printf "\\t\\t@ih,224,64 0 \\\\\n";
printf "\\t#Confirm each segment of the MAC address matches\n";
if [ -n "$CLIENT_MAC_ADDRESS" ]; then
	printf "\\t\\t@ih,224,8 0x$(echo $CLIENT_MAC_ADDRESS | cut -d ':' -f 1) \\\\\n";
	printf "\\t\\t@ih,232,8 0x$(echo $CLIENT_MAC_ADDRESS | cut -d ':' -f 2) \\\\\n";
	printf "\\t\\t@ih,240,8 0x$(echo $CLIENT_MAC_ADDRESS | cut -d ':' -f 3) \\\\\n";
	printf "\\t\\t@ih,248,8 0x$(echo $CLIENT_MAC_ADDRESS | cut -d ':' -f 4) \\\\\n";
	printf "\\t\\t@ih,256,8 0x$(echo $CLIENT_MAC_ADDRESS | cut -d ':' -f 5) \\\\\n";
	printf "\\t\\t@ih,264,8 0x$(echo $CLIENT_MAC_ADDRESS | cut -d ':' -f 6) \\\\\n";
else
	printf "\\t\\t#@ih,224,64 unrestricted - please consider the security implications\n";
fi

printf "\\t#CHADDR Padding - pad to the full 128 bits - 48 consumed; 80 bits of padding\n";
printf "\\t\\t@ih,272,80 0 \\\\\n";

printf "\\t#Cannot verify beyond the CHADDR as the server host name and boot file name fields may be used for options.\n";

printf "\\t#DHCP Message Type of 7 (Release)\n";
printf "\\t#Cannot confirm - DHCP message format is not strictly ordered\n";

exit 0;
