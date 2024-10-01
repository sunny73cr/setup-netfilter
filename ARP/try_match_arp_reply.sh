#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_valid.sh";
DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";
DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_network_is_valid.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID" ]; then
	printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID\" is missing or is not executable.\n">&2;
	exit 3;
fi

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID" ]; then
	printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" is missing or is not executable.\n">&2;
	exit 3;
fi

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID" ]; then
	printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID\" is missing or is not executable.\n">&2;
	exit 3;
fi


print_description() {
	printf "A program that prints a part of an NFT rule match section. This match identifies ARP Reply packets.\n">&2;
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
	printf " Optional: --source-address-mac XX:XX:XX:XX:XX:XX (where X is a-f, or A-F, or 0-9; hexadecimal.)\n">&2;
	printf " Optional: --destination-address-mac XX:XX:XX:XX:XX:XX (where X is a-f, or A-F, or 0-9; hexadecimal.)\n">&2;
	printf " Note: It is strongly recommended to supply a source or destination MAC Address\n">&2;
	printf "\n">&2;
	printf " Optional: --source-address-ipv4 X.X.X.X (where X is 0-255)\n">&2;
	printf " Optional: --source-network-ipv4 X.X.X.X/Y (where X is 0-255, and Y is 1-32)\n">&2;
	printf " Note: It is strongly reccomended to supply a source ipv4 address or network.\n">&2;
	printf "\n">&2;
	printf " Optional: --destination-address-ipv4 X.X.X.X (where X is 0-255)\n">&2;
	printf " Optional: --destination-network-ipv4 X.X.X.X/Y (where X is 0-255, and Y is 1-32)\n">&2;;
	printf " Note: It is strongly reccomended to supply a destination ipv4 address or network.\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf " Note: enabling this flag causes the program to skip validation (if you know the inputs are valid).\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validate\n">&2;
	printf " Note: enabling this flag causes the program to exit after validating inputs.\n">&2;
	printf "\n">&2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
SOURCE_MAC_ADDRESS="";
DESTINATION_MAC_ADDRESS="";
SOURCE_IPV4_ADDRESS="";
SOURCE_IPV4_NETWORK="";
DESTINATION_IPV4_ADDRESS="";
DESTINATION_IPV4_NETWORK="";

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

		--source-address-mac)
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

		--destination-address-mac)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				DESTINATION_MAC_ADDRESS=$2;
				shift 2;
			fi
		;;

		--source-address-ipv4)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				SOURCE_IPV4_ADDRESS=$2;
				shift 2;
			fi
		;;

		--source-network-ipv4)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				SOURCE_IPV4_NETWORK=$2;
				shift 2;
			fi
		;;

		--destination-address-ipv4)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				DESTINATION_IPV4_ADDRESS=$2;
				shift 2;
			fi
		;;

		--destination-network-ipv4)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				DESTINATION_IPV4_NETWORK=$2;
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

#Why, user?
if [ $SKIP_VALIDATION -eq 1 ] && [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

if [ $SKIP_VALIDATION -eq 0 ]; then
	if [ -n "$MAC_ADDRESS_SOURCE" ]; then
		$DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID --address "$MAC_ADDRESS_SOURCE";
		case $? in
			0) ;;
			1) printf "\nInvalid --source-mac-address. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID\" produced incorrect output.\n">&2; exit 3; ;;
		esac
	fi

	if [ -n "$DESTINATION_ADDRESS_MAC" ]; then
		$DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID --address "$DESTINATION_ADDRESS_MAC";
		case $? in
			0) ;;
			1) printf "\nInvalid --destination-mac-address. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID\" produced incorrect output.\n">&2; exit 3; ;;
		esac
	fi

	if [ -n "$SOURCE_ADDRESS_IPV4" ]; then
		$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$SOURCE_ADDRESS_IPV4";
		case $? in
			0) ;;
			1) printf "\nInvalid --source-address-ipv4. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced incorrect output.\n">&2; exit 3; ;;
		esac
	fi

	if [ -n "$SOURCE_NETWORK_IPV4" ]; then
		$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID --network "$SOURCE_NETWORK_IPV4";
		case $? in
			0) ;;
			1) printf "\nInvalid --source-network-ipv4. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID\" produced incorrect output.\n">&2; exit 3; ;;
		esac
	fi

	if [ -n "$DESTINATION_ADDRESS_IPV4" ]; then
		$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$DESTINATION_ADDRESS_IPV4";
		case $? in
			0) ;;
			1) printf "\nInvalid --destination-address-ipv4. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced incorrect output.\n">&2; exit 3; ;;
		esac
	fi

	if [ -n "$DESTINATION_NETWORK_IPV4" ]; then
		$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID --network "$DESTINATION_NETWORK_IPV4";
		case $? in
			0) ;;
			1) printf "\nInvalid --destination-network-ipv4. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID\" produced incorrect output.\n">&2; exit 3; ;;
		esac
	fi
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

printf "\\t#Hardware Ethernet (1 = Ethernet)\n";
printf "\\t\\tarp htype 1 \\\\\n";

printf "\\t#Hardware Length (6 = MAC address segment count)\n";
printf "\\t\\tarp hlen 6 \\\\\n";

printf "\\t#Protocol Type (0x0800 = IPV4 ethertype)\n";
printf "\\t\\tarp ptype 0x0800 \\\\\n";

printf "\\t#Protocol Length (4 = IPV4 address segment length)\n";
printf "\\t\\tarp plen 4 \\\\\n";

printf "\\t#ARP OP Code (2 = reply)\n";
printf "\\t\\tarp operation 2 \\\\\n";

printf "\\t#Source MAC address - who is replying to a probe.\n";
if [ -n "$SOURCE_MAC_ADDRESS" ]; then
	printf "arp saddr ether $MAC_ADDRESS_SOURCE \\\\\n";
else
	printf "\\t\\t#arp saddr ether unknown - please consider the security implications\n";
fi

printf "\\t#Destination MAC address - who is replying to a probe.\n";
if [ -n "$DESTINATION_ADDRESS_MAC" ]; then
	printf "arp daddr ether $DESTINATION_ADDRESS_MAC \\\\\n";
else
	printf "\\t\\t#arp daddr ether unknown - please consider the security implications\n";
fi

printf "\\t#ARP source ip address - who is replying to a probe.\n";
if [ -n "$SOURCE_ADDRESS_IPV4" ]; then
	printf "\\t\\tarp saddr ip $SOURCE_ADDRESS_IPV4 \\\\\n":

elif [ -n "$SOURCE_NETWORK_IPV4" ]
	printf "\\t\\tarp saddr ip $SOURCE_NETWORK_IPV4 \\\\\n";

else
	printf "\\t\\t#arp saddr ip unknown - please consider the security implications\n";
fi

printf "\\t#ARP destination ip address - who is being informed of the IP's owner (hardware address)\n";
if [ -n "$DESTINATION_ADDRESS_IPV4" ]; then
	printf "\\t\\tarp daddr ip $DESTINATION_ADDRESS_IPV4 \\\\\n":

elif [ -n "$DESTINATION_NETWORK_IPV4" ]
	printf "\\t\\tarp daddr ip $DESTINATION_NETWORK_IPV4 \\\\\n";

else
	printf "\\t\\t#arp daddr ip unknown - please consider the security implications\n";
fi

exit 0;
