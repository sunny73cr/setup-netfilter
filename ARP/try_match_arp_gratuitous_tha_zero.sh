#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_valid.sh";
DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_source_is_banned.sh";
DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";
DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_network_is_valid.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS ]; then
	printf "$0; dependency: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS\" is missing or is not executable.\n">&2;
	exit 3;
fi

if [ ! -x $DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE ]; then
	printf "$0; dependency: \"$DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE\" is missing or is not executable.\n">&2;
	exit 3;
fi

if [ ! -x $DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS ]; then
	printf "$0; dependency: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS\" is missing or is not executable.\n">&2;
	exit 3;
fi

if [ ! -x $DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK ]; then
	printf "$0; dependency: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_description() {
	printf "A program that performs a function.\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
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
	printf " Optional: --source-mac-address XX:XX:XX:XX:XX:XX (where X is a-f, or A-F, or 0-9; hexadecimal)\n">&2;
	printf " Note: it is strongly recommended to supply a source MAC address.\n">&2;
	printf "\n">&2;
	printf " Optional: --requested-address-ipv4 X.X.X.X (where X is 0-255)\n">&2
	printf " Optional: --requested-network-ipv4 X.X.X.X/Y (where X is 0-255, and Y is 1-32)\n">&2;
	printf " Note: it is strongly recommended to supply either an address or a network.\n">&2;
	printf " Note: you cannot supply both an address and a network.\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf " Note: this causes the program to skip validating inputs (if you know they are valid.)\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validation\n">&2;
	printf " Note: this causes the program to exit after validating inputs.\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
SOURCE_MAC_ADDRESS="";
REQUESTED_ADDRESS="";
REQUESTED_NETWORK="";

#FLAGS:
SKIP_VALIDATION=0;
ONLY_VALIDATION=0;

while true; do
	case $1 in
		--source-mac-address)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				SOURCE_MAC_ADDRESS=$2;
				shift 2;
			fi
		;;

		--requested-address)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				REQUESTED_ADDRESS=$2;
				shift 2;
			fi
		;;

		--requested-network)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				REQUESTED_NETWORK=$2;
				shift 2;
			fi
		;;

		--skip-validation)
			SKIP_VALIDATION=1;
			shift 1;
		;;

		--only-validation)
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

#Why, user?
if [ $SKIP_VALIDATION -eq 1 ] && [ $ONLY_VALIDATION -eq 1 ]; then exit 0; fi

if [ $SKIP_VALIDATION -eq 0 ]; then

	if [ -n "$REQUESTED_ADDRESS" ] && [ -n "$REQUESTED_NETWORK" ]; then
		printf "\nAddress claim is ambiguous, you cannot supply both an address and a network.\n">&2;
		print_usage_then_exit;
	fi

	if [ -n "$SOURCE_MAC_ADDRESS" ]; then
		$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS --address "$SOURCE_MAC_ADDRESS"
		case $? in
			0) ;;
			1) printf "\nInvalid --source-mac-address. " >&2; print_usage_then_exit; ;;
			*) printf "$0; dependency: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS\" produced incorrect output\n" >&2; exit 3; ;;
		esac

		$DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE --address "$SOURCE_MAC_ADDRESS"
		case $? in
			1) ;;
			0) printf "\nInvalid --source-mac-address (banned). " >&2; print_usage_then_exit; ;;
			*) printf "$0; dependency: \"$DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE\" produced incorrect output\n" >&2; exit 3; ;;
		esac
	fi

	if [ -n "$REQUESTED_ADDRESS" ]; then
		$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS --address "$REQUESTED_ADDRESS"
		case $? in
			0) ;;
			1) printf "\nInvalid --requested-address. ">&2; print_usage_then_exit; ;;
			*) printf "$0; dependency: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS\" produced incorrect output.\n">&2; exit 3; ;;
		esac
	fi

	if [ -n "$REQUESTED_NETWORK" ]; then
		$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK --address "$REQUESTED_NETWORK"
		case $? in
			0) ;;
			1) printf "\nInvalid --requested-network. ">&2; print_usage_then_exit; ;;
			*) printf "$0; dependency: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK\" produced incorrect output.\n">&2; exit 3; ;;
		esac
	fi
fi

if [ $ONLY_VALIDATION -eq 1 ]; then exit 0; fi

TO_PROBE="";

if [ -n "$REQUESTED_ADDRESS" ]; then
	TO_PROBE="$REQUESTED_ADDRESS";

elif [ -n "$REQUESTED_NETWORK" ]; then
	TO_PROBE="$REQUESTED_NETWORK";

fi

printf "\\t#Hardware Type (1 = Ethernet)\n";
printf "\\t\\tarp htype 1 \\\\\n";

printf "\\t#Hardware Length (6 = MAC address segment count)\n";
printf "\\t\\tarp hlen 6 \\\\\n";

printf "\\t#Protocol Type (0x0800 = IPV4 ethertype)\n";
printf "\\t\\tarp ptype 0x0800 \\\\\n";

printf "\\t#Protocol Length (4 = IPV4 segment count)\n";
printf "\\t\\tarp plen 4 \\\\\n";

printf "\\t#Operation Code (1 = request)\n";
printf "\\t\\tarp operation 1 \\\\\n";

printf "\\t#Source MAC address - who is informing their peers of their MAC address and IP pair\n";
if [ -n "$SOURCE_MAC_ADDRESS" ]; then
	printf "\\t\\tarp saddr ether $SOURCE_MAC_ADDRESS \\\\\n";
else
	printf "\\t\\t#arp saddr ether unknown - please consider the security implications\n";
fi

printf "\\t#Destination MAC address - nobody in particular.\n";
printf "\\t\\tarp daddr ether 00:00:00:00:00:00 \\\\\n";

printf "\\t#Source and Destination IP address - which IP does the MAC address own\n";
if [ -n "$TO_PROBE" ]; then
	printf "\\t\\tarp saddr ip $TO_PROBE \\\\\n";
	printf "\\t\\tarp daddr ip $TO_PROBE \\\\\n";
else
	printf "\\t\\t#arp saddr ip unknown - please consider the security implications\n";
	printf "\\t\\t#arp daddr ip unknown - please consider the security implications\n";
fi

exit 0;
