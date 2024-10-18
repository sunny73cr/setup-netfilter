#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_valid.sh";
DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_source_is_banned.sh";
DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";
DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_network_is_valid.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS" ]; then
	printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS\" is missing or is not executable.\n">&2;
	exit 3;
fi

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE" ]; then
	printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE\" is missing or is not executable.\n">&2;
	exit 3;
fi

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS" ]; then
	printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS\" is missing or is not executable.\n">&2;
	exit 3;
fi

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK" ]; then
	printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_description() {
	printf "A program that prints part of an NFT rule 'match' section. The match intends to identify ARP Probe packets.\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "Dependencies: \n">&2;
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
	printf "Flags used by themselves: \n">&2;
	printf "-e (prints an explanation of the functions' purpose) (exit code 2)\n">&2;
	printf "-h (prints an explanation of the functions' available parameters, and their effect) (exit code 2)\n">&2;
	printf "-d (prints the functions' dependencies: newline delimited list) (exit code 2)\n">&2
	printf "-ehd (prints the above three) (exit code 2)\n">&2;
	printf "\n">&2;
	printf "Parameters:\n">&2;
	printf "\n">&2;
	printf " Optional: --source-mac-address XX:XX:XX:XX:XX:XX (where X is a-f, A-F, 0-9, or hexadecimal)\n">&2;
	printf "   Options:\n">&2;
	printf "    1. the mac address of the probing device.\n">&2;
	printf "    2. no restrictions on source address.\n">&2;
	printf "\n">&2;
	printf "    Note: it is strongly recommended to supply a source MAC address.\n">&2;
	printf "\n">&2;
	printf " Optional: --probed-address-ipv4 X.X.X.X (where X is 0-255)\n">&2
	printf " Optional: --probed-network-ipv4 X.X.X.X/Y (where X is 0-255, and Y is 1-32)\n">&2;
	printf " Note: it is strongly recommended to supply either an address or a network.\n">&2;
	printf " Note: you cannot supply both an address and a network.\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf " Note: Enabling this flag causes the program to skip validation (if you know the inputs are valid.)\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validation\n">&2;
	printf " Note: Enabling this flag causes the program to exit after performing validation.\n">&2;
	printf "\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
MAC_ADDRESS_SOURCE="";
PROBED_ADDRESS="";
PROBED_NETWORK="";

#FLAGS:
SKIP_VALIDATION=0;
ONLY_VALIDATION=0;

while true; do
	case $1 in
		#Approach to parsing arguments:
		#If the length of 'all arguments' is less than 2 (shift reduces this number),
		#since this is an argument parameter and requires a value; the program cannot continue.
		#Else, if the argument was provided, and its 'value' is empty; the program cannot continue.
		#Else, assign the argument, and shift 2 (both the argument indicator and its value / move next)

		--source-mac-address)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				MAC_ADDRESS_SOURCE=$2;
				shift 2;
			fi
		;;

		--probed-address-ipv4)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				PROBED_ADDRESS=$2;
				shift 2;
			fi
		;;

		--probed-network-ipv4)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				PROBED_NETWORK=$2;
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
			ONLY_VALIDATION=1;
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

#WHy, user?
if [ $SKIP_VALIDATION -eq 1 ] && [ $ONLY_VALIDATION -eq 1 ]; then exit 0; fi

if [ $SKIP_VALIDATION -eq 0 ]; then
	if [ -n "$MAC_ADDRESS_SOURCE" ]; then
		$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS --address "$MAC_ADDRESS_SOURCE";
		case $? in
			0) ;;
			1) printf "\nInvalid --source-mac-address. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS\"\n">&2; exit 3; ;;
		esac

		$DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE --address "$MAC_ADDRESS_SOURCE"
		case $? in
			1) ;;
			0) printf "\nInvalid --source-mac-address (banned). ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE\" produced incorrect output\n">&2; exit 3; ;;
		esac
	fi

	if [ -n "$PROBED_ADDRESS" ]; then
		$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS --address "$PROBED_ADDRESS"
		case $? in
			0) ;;
			1) printf "\nInvalid --probed-address-ipv4. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS\" produced incorrect output.\n">&2; exit 3; ;;
		esac
	fi

	if [ -n "$PROBED_NETWORK" ]; then
		$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK --address "$PROBED_NETWORK"
		case $? in
			0) ;;
			1) printf "\nInvalid --proved-network-ipv4. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK\" produced incorrect output.\n">&2; exit 3; ;;
		esac
	fi
fi

if [ $ONLY_VALIADTION -eq 1 ]; then exit 0; fi

TO_PROBE="";

if [ -n "$PROBED_ADDRESS" ]; then
	TO_PROBE="$PROBED_ADDRESS";
fi

if [ -n "$PROBED_NETWORK" ]; then
	TO_PROBE="$PROBED_NETWORK";
fi

printf "\\t#Hardware Type (1 = Ethernet)\n";
printf "\\t\\tarp htype 1 \\\\\n";

printf "\\t#Hardware Length (6 = MAC segment count)\n";
printf "\\t\\tarp hlen 6 \\\\\n";

printf "\\t#Protocol Type (0x0800 = 'IPV4' ethertype\n";
printf "\\t\\tarp ptype 0x0800 \\\\\n";

printf "\\t#Protocol Length (4 = IPV4 segment count)\n";
printf "\\t\\tarp plen 4 \\\\\n";

printf "\\t#Operation code (1 = request)\n";
printf "\\t\\tarp operation 1 \\\\\n";

printf "\\t#ARP source MAC - who is asking\n";
if [ -n "$MAC_ADDRESS_SOURCE" ]; then
	printf "\\t\\tarp saddr ether $MAC_ADDRESS_SOURCE \\\\\n";
else
	printf "\\t\\t#arp saddr ether unknown - please consider the security implications\n";
fi

printf "\\t#ARP destination mac - who to ask (unknown in a 'probe')\n";
printf "\\t\\tarp daddr ether 00:00:00:00:00:00 \\\\\n";

printf "\\t#ARP source ip address - who is asking (not yet assigned in a 'probe')\n";
printf "\\t\\tarp saddr ip 0.0.0.0 \\\\\n";

printf "\\t#ARP destination ip address - who to ask (for their mac address)\n";
if [ -n "$TO_PROBE" ]; then
	printf "\\t\\tarp daddr ip $TO_PROBE \\\\\n";
else
	printf "\\t\\t#arp daddr ip unknown - please consider the security implications\n";
fi

exit 0;

