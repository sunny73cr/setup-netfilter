#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_source_is_banned.sh";

if [ ! -x $DEPENDENCY_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_IS_MAC_ADDRESS_BANNED_AS_DESTINATION="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_destination_is_banned.sh";

if [ ! -x $DEPENDENCY_PATH_IS_MAC_ADDRESS_BANNED_AS_DESTINATION ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_IS_MAC_ADDRESS_BANNED_AS_DESTINATION\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_VALIDATE_IPV4_NETWORK="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_network_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_IPV4_NETWORK ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_IPV4_NETWORK\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_cidr_network_to_base_address.sh";

if [ ! -x $DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_cidr_network_to_end_address.sh";

if [ ! -x $DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_ipv4_address_to_decimal_number.sh";

if [ ! -x $DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_description() {
	printf "A program that prints a portion of an NFT rule match section. The match identifies ARP Gratuitous Requests, where the Target Hardware Address is Duplicated.\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "Dependencies: \n">&2;
	printf "printf\n">&2;
	printf "$DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS\n">&2;
	printf "$DEPENDENCY_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE\n">&2;
	printf "$DEPENDENCY_PATH_IS_MAC_ADDRESS_BANNED_AS_DESTINATION\n">&2;
	printf "$DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS\n">&2;
	printf "$DEPENDENCY_PATH_VALIDATE_IPV4_NETWORK\n">&2;
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
	printf " Optional: --hardware-address-type x (where x is 0-65535)\n">&2;
	printf "  if --hardware-address-type is not provided, the default is 1 (Ethernet)\n">&2;
	printf "\n">&2;
	printf " Optional: --hardware-address-length x (where x is 0-255)\n">&2;
	printf "  if --hardware-address-length is not provided, the default is 6 (6 bytes for a MAC address)\n">&2;
	printf "\n">&2;
	printf " Optional: --protocol-address-type x (where x is 0-65535)\n">&2;
	printf "  if --protocol-address-type is not provided, the default is 0x800 (IPV4 Address)\n">&2;
	printf "\n">&2;
	printf " Optional: --protocol-address-length x (where x is 0-255)\n">&2;
	printf "  if --protocol-address-length is not provided, the default is 4 (4 bytes for an IPV4 address)\n">&2;
	printf "\n">&2;
	printf " Optional: --source-mac-address XX:XX:XX:XX:XX:XX (where X is a-f, or A-F, or 0-9: hexadecimal)\n">&2;
	printf "  the hardware address of the peer that is replying to the destination MAC / IP pair\n">&2;
	printf "\n">&2;
	printf " Optional: --source-ipv4-address X.X.X.X (where X is 0-255)\n">&2
	printf "  the ipv4 address owned by the peer (MAC address) that is replying to the destination MAC / IP pair\n">&2;
	printf "\n">&2;
	printf " Optional: --source-ipv4-network X.X.X.X/Y (where X is 0-255, and Y is 1-32)\n">&2;
	printf "  a contiguous block of IPV4 addresses that could be owned by the peer (MAC address) that is replying to the destinaiton MAC / IP Pair\n">&2;
	printf "\n">&2;
	printf " the arguments --source-ipv4-address and --source-ipv4-network cannot be combined.\n">&2;
	printf "\n">&2;
	printf " Optional: --destination-mac-address XX:XX:XX:XX:XX:XX (where x is a-f, A-F, or 0--9: hexadecimal)\n">&2;
	printf "  the hardware address of the peer that is being replied to.\n">&2;
	printf "\n">&2;
	printf " Optional: --destination-ipv4-address X.X.X.X (where X is 0-255)\n">&2
	printf "  the ipv4 address of the peer that is being replied to.\n">&2;
	printf "\n">&2;
	printf " Optional: --destination-ipv4-network X.X.X.X/Y (where X is 0-255, and Y is 1-32)\n">&2;
	printf "  a contiguous block of IPV4 addresses that can be replied to.\n">&2;
	printf "\n">&2;
	printf " the arguments --destination-ipv4-address and --destination-ipv4-network cannot be combined.\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf "  this causes the program to skip parameter validation (if you know they are valid)\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validate\n">&2;
	printf "  this causes the program to exit after validating parameters.\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
HARDWARE_ADDRESS_TYPE="";
HARDWARE_ADDRESS_LENGTH="";
PROTOCOL_ADDRESS_TYPE="";
PROTOCOL_ADDRESS_LENGTH="";
MAC_ADDRESS_SOURCE="";
SOURCE_IPV4_ADDRESS="";
SOURCE_IPV4_NETWORK="";
MAC_ADDRESS_DESTINATION="";
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

		--hardware-address-type)
			#not enough argynents
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				HARDWARE_ADDRESS_TYPE=$2;
				shift 2;
			fi
		;;

		--hardware-address-length)
			#not enough argynents
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				HARDWARE_ADDRESS_LENGTH=$2;
				shift 2;
			fi
		;;

		--protocol-address-type)
			#not enough argynents
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				PROTOCOL_ADDRESS_TYPE=$2;
				shift 2;
			fi
		;;

		--protocol-address-length)
			#not enough argynents
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				PROTOCOL_ADDRESS_LENGTH=$2;
				shift 2;
			fi
		;;

		--source-mac-address)
			#not enough argynents
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

		--source-ipv4-address)
			#not enough argynents
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

		--source-ipv4-network)
			#not enough argynents
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

		--destination-mac-address)
			#not enough argynents
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#the value is empty
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				MAC_ADDRESS_DESTINATION=$2;
				shift 2;
			fi
		;;

		--destination-ipv4-address)
			#not enough argynents
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

		--destination-ipv4-network)
			#not enough argynents
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
	if [ -n "$HARDWARE_ADDRESS_TYPE" ]; then
		if [ -z "$(echo $HARDWARE_ADDRESS_TYPE | grep '[0-9]{1,5}')" ]; then
			printf "\nInvalid --hardware-address-type (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $HARDWARE_ADDRESS_TYPE -lt 0 ]; then
			printf "\nInvalid --hardware-address-type (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $HARDWARE_ADDRESS_TYPE -gt 65535 ]; then
			printf "\nInvalid --hardware-address-type (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$HARDWARE_ADDRESS_LENGTH" ]; then
		if [ -z "$(echo $HARDWARE_ADDRESS_LENGTH | grep '[0-9]{1,3}')" ]; then
			printf "\nInvalid --hardware-address-length (must be a 1-3 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $HARDWARE_ADDRESS_LENGTH -lt 0 ]; then
			printf "\nInvalid --hardware-address-length (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $HARDWARE_ADDRESS_LENGTH -gt 255 ]; then
			printf "\nInvalid --hardware-address-length (must be less than 256). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$PROTOCOL_ADDRESS_TYPE" ]; then
		if [ -z "$(echo $PROTOCOL_ADDRESS_TYPE | grep '[0-9]{1,5}')" ]; then
			printf "\nInvalid --protocol-address-type (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $PROTOCOL_ADDRESS_TYPE -lt 0 ]; then
			printf "\nInvalid --protocol-address-type (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $PROTOCOL_ADDRESS_TYPE -gt 65535 ]; then
			printf "\nInvalid --protocol-address-type (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$PROTOCOL_ADDRESS_LENGTH" ]; then
		if [ -z "$(echo $PROTOCOL_ADDRESS_LENGTH | grep '[0-9]{1,3}')" ]; then
			printf "\nInvalid --protocol-address-length (must be a 1-3 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $PROTOCOL_ADDRESS_LENGTH -lt 0 ]; then
			printf "\nInvalid --protocol-address-length (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $PROTOCOL_ADDRESS_LENGTH -gt 255 ]; then
			printf "\nInvalid --protocol-address-length (must be less than 256). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$MAC_ADDRESS_SOURCE" ]; then
		$DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS --address "$MAC_ADDRESS_SOURCE";
		case $? in
			0) ;;
			1) printf "\nInvalid --source-mac-address. " >&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS\" produced a failure exit code ($?).\n" >&2; exit 3; ;;
		esac

		$DEPENDENCY_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE --address "$MAC_ADDRESS_SOURCE"
		case $? in
			1) ;;
			0) printf "\nBanned --source-mac-address. " >&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE\" produced a failure exit code ($?).\n" >&2; exit 3; ;;
		esac
	fi

	if [ -n "$SOURCE_IPV4_ADDRESS" ] && [ -n "$SOURCE_IPV4_NETWORK" ]; then
		printf "\nInvalid combination of --source-ipv4-address and --source-ipv4-network. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$SOURCE_IPV4_ADDRESS" ]; then
		$DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS --address "$SOURCE_IPV4_ADDRESS"
		case $? in
			0) ;;
			1) printf "\nInvalid --source-ipv4-address. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS\" produced a failure exit code ($?).\n">&2; exit 3; ;;
		esac
	fi

	if [ -n "$SOURCE_IPV4_NETWORK" ]; then
		$DEPENDENCY_PATH_VALIDATE_IPV4_NETWORK --network "$SOURCE_IPV4_NETWORK"
		case $? in
			0) ;;
			1) printf "\nInvalid --source-ipv4-network. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_IPV4_NETWORK\" produced a failure exit code ($?).\n">&2; exit 3; ;;
		esac
	fi

	if [ -n "$MAC_ADDRESS_DESTINATION" ]; then
		$DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS --address "$MAC_ADDRESS_DESTINATION";
		case $? in
			0) ;;
			1) printf "\nInvalid --destination-mac-address. " >&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS\" produced a failure exit code ($?).\n" >&2; exit 3; ;;
		esac

		$DEPENDENCY_PATH_IS_MAC_ADDRESS_BANNED_AS_DESTINATION --address "$MAC_ADDRESS_DESTINATION"
		case $? in
			1) ;;
			0) printf "\nBanned --destination-mac-address. " >&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_PATH_IS_MAC_ADDRESS_BANNED_AS_DESTINATION\" produced a failure exit code ($?).\n" >&2; exit 3; ;;
		esac
	fi

	if [ -n "$DESTINATION_IPV4_ADDRESS" ] && [ -n "$DESTINATION_IPV4_NETWORK" ]; then
		printf "\nInvalid combination of --destination-ipv4-address and --destination-ipv4-network. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$DESTINATION_IPV4_ADDRESS" ]; then
		$DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS --address "$DESTINATION_IPV4_ADDRESS"
		case $? in
			0) ;;
			1) printf "\nInvalid --destination-ipv4-address. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS\" produced a failure exit code ($?).\n">&2; exit 3; ;;
		esac
	fi

	if [ -n "$DESTINATION_IPV4_NETWORK" ]; then
		$DEPENDENCY_PATH_VALIDATE_IPV4_NETWORK --network "$DESTINATION_IPV4_NETWORK"
		case $? in
			0) ;;
			1) printf "\nInvalid --destination-ipv4-network. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_IPV4_NETWORK\" produced a failure exit code ($?).\n">&2; exit 3; ;;
		esac
	fi
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

#assign defaults

if [ -z "$HARDWARE_ADDRESS_TYPE" ]; then
	HARDWARE_ADDRESS_TYPE=1;
fi

if [ -z "$HARDWARE_ADDRESS_LENGTH" ]; then
	HARDWARE_ADDRESS_LENGTH=6;
fi

if [ -z "$PROTOCOL_ADDRESS_TYPE" ]; then
	PROTOCOL_ADDRESS_TYPE=0x0800;
fi

if [ -z "$PROTOCOL_ADDRESS_LENGTH" ]; then
	PROTOCOL_ADDRESS_LENGTH=4;
fi

#nft expects a raw hexadecimal value with a 0x prefix; format the mac address
MAC_ADDRESS_SOURCE_CLEANED="";
if [ -n "$MAC_ADDRESS_SOURCE" ]; then
	MAC_ADDRESS_SOURCE_NO_COLONS=$(echo $MAC_ADDRESS_SOURCE | sed 's/://g');
	MAC_ADDRESS_SOURCE_CLEANED="0x$MAC_ADDRESS_SOURCE_NO_COLONS";
fi

#nft expects a raw hexadecimal value with a 0x prefix; format the mac address
MAC_ADDRESS_DESTINATION_CLEANED="";
if [ -n "$MAC_ADDRESS_DESTINATION" ]; then
	MAC_ADDRESS_DESTINATION_NO_COLONS=$(echo $MAC_ADDRESS_DESTINATION | sed 's/://g');
	MAC_ADDRESS_DESTINATION_CLEANED="0x$MAC_ADDRESS_DESTINATION_NO_COLONS";
fi

SOURCE_IPV4_ADDRESS_DECIMAL="";
if [ -n "$SOURCE_IPV4_ADDRESS" ]; then
	SOURCE_IPV4_ADDRESS_DECIMAL=$($DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL --address $SOURCE_IPV4_ADDRESS);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" produced a failure exit code ($?).\n">&2; exit 3; ;;
	esac
fi

#find the base and end address of the supplied IPV4 network, and convert them to decimal
#this allows for matching what is in the packet to a range of decimal numbers that correlate to addresses
SOURCE_IPV4_NETWORK_BASE_ADDRESS="";
SOURCE_IPV4_NETWORK_BASE_ADDRESS_DECIMAL="";
SOURCE_IPV4_NETWORK_END_ADDRESS="";
SOURCE_IPV4_NETWORK_END_ADDRESS_DECIMAL="";
if [ -n "$SOURCE_IPV4_NETWORK" ]; then
	SOURCE_IPV4_NETWORK_BASE_ADDRESS=$($DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS --network $SOURCE_IPV4_NETWORK);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS\" produced a failure exit code ($?).\n">&2; exit 3; ;;
	esac

	SOURCE_IPV4_NETWORK_BASE_ADDRESS_DECIMAL=$($DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL --address $SOURCE_IPV4_NETWORK_BASE_ADDRESS);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" produced a failure exit code ($?).\n">&2; exit 3; ;;
	esac

	SOURCE_IPV4_NETWORK_END_ADDRESS=$($DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS --network $SOURCE_IPV4_NETWORK);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS\" produced a failure exit code ($?).\n">&2; exit 3; ;;
	esac

	SOURCE_IPV4_NETWORK_END_ADDRESS_DECIMAL=$($DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL --address $SOURCE_IPV4_NETWORK_END_ADDRESS);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" produced a failure exit code ($?).\n">&2; exit 3; ;;
	esac
fi

DESTINATION_IPV4_ADDRESS_DECIMAL="";
if [ -n "$DESTINATION_IPV4_ADDRESS" ]; then
	DESTINATION_IPV4_ADDRESS_DECIMAL=$($DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL --address $DESTINATION_IPV4_ADDRESS);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" produced a failure exit code ($?).\n">&2; exit 3; ;;
	esac
fi

#find the base and end address of the supplied IPV4 network, and convert them to decimal
#this allows for matching what is in the packet to a range of decimal numbers that correlate to addresses
DESTINATION_IPV4_NETWORK_BASE_ADDRESS="";
DESTINATION_IPV4_NETWORK_BASE_ADDRESS_DECIMAL="";
DESTINATION_IPV4_NETWORK_END_ADDRESS="";
DESTINATION_IPV4_NETWORK_END_ADDRESS_DECIMAL="";
if [ -n "$DESTINATION_IPV4_NETWORK" ]; then
	DESTINATION_IPV4_NETWORK_BASE_ADDRESS=$($DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS --network $DESTINATION_IPV4_NETWORK);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS\" produced a failure exit code ($?).\n">&2; exit 3; ;;
	esac

	DESTINATION_IPV4_NETWORK_BASE_ADDRESS_DECIMAL=$($DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL --address $DESTINATION_IPV4_NETWORK_BASE_ADDRESS);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" produced a failure exit code ($?).\n">&2; exit 3; ;;
	esac

	DESTINATION_IPV4_NETWORK_END_ADDRESS=$($DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS --network $DESTINATION_IPV4_NETWORK);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS\" produced a failure exit code ($?).\n">&2; exit 3; ;;
	esac

	DESTINATION_IPV4_NETWORK_END_ADDRESS_DECIMAL=$($DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL --address $DESTINATION_IPV4_NETWORK_END_ADDRESS);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" produced a failure exit code ($?).\n">&2; exit 3; ;;
	esac
fi

OFFSET_MARKER="ll";
#LinkLayer Offset / Ethernet Header Offset + Ethernet Header Length = 144
BIT_OFFSET_ARP_HARDWARE_ADDRESS_TYPE=144;
BIT_OFFSET_ARP_PROTOCOL_ADDRESS_TYPE=$(($BIT_OFFSET_ARP_HARDWARE_ADDRESS_TYPE+16));
BIT_OFFSET_ARP_HARDWARE_ADDRESS_LENGTH=$(($BIT_OFFSET_ARP_PROTOCOL_ADDRESS_TYPE+16));
BIT_OFFSET_ARP_PROTOCOL_ADDRESS_LENGTH=$(($BIT_OFFSET_ARP_HARDWARE_ADDRESS_LENGTH+8));
BIT_OFFSET_ARP_OPERATION=$(($BIT_OFFSET_ARP_PROTOCOL_ADDRESS_LENGTH+8));
BIT_OFFSET_ARP_SENDING_HARDWARE_ADDRESS=$(($BIT_OFFSET_ARP_OPERATION+16));
BIT_OFFSET_ARP_SENDING_PROTOCOL_ADDRESS=$(($BIT_OFFSET_ARP_SENDING_HARDWARE_ADDRESS+48));
BIT_OFFSET_ARP_TARGET_HARDWARE_ADDRESS=$(($BIT_OFFSET_ARP_SENDING_PROTOCOL_ADDRESS+32));
BIT_OFFSET_ARP_TARGET_PROTOCOL_ADDRESS=$(($BIT_OFFSET_ARP_TARGET_HARDWARE_ADDRESS+48));

printf "\\t#Match Hardware Type (1 = Ethernet)\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ARP_HARDWARE_ADDRESS_TYPE,16 $HARDWARE_ADDRESS_TYPE \\\\\n";

printf "\\t#Match Protocol Type (0x0800 = IPV4 ethertype)\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ARP_PROTOCOL_ADDRESS_TYPE,16 $PROTOCOL_ADDRESS_TYPE \\\\\n";

printf "\\t#Match Hardware Length (6 = MAC address segment count)\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ARP_HARDWARE_ADDRESS_LENGTH,8 $HARDWARE_ADDRESS_LENGTH \\\\\n";

printf "\\t#Match Protocol Length (4 = IPV4 address segment count)\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ARP_PROTOCOL_ADDRESS_LENGTH,8 $PROTOCOL_ADDRESS_LENGTH \\\\\n";

printf "\\t#Match ARP OP Code (1 = request)\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ARP_OPERATION,16 1 \\\\\n";

if [ -n "$MAC_ADDRESS_SOURCE" ]; then
	printf "\\t#Match Sending Hardware Address - who is informing their peers\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ARP_SENDING_HARDWARE_ADDRESS,48 $MAC_ADDRESS_SOURCE_CLEANED \\\\\n";
else
	printf "\\t\\t#ARP Sending Hardware Address unrestricted - please consider the security implications\n";
fi

if [ -n "$SOURCE_IPV4_ADDRESS" ] || [ -n "$SOURCE_IPV4_NETWORK" ]; then
	printf "\\t#Match Sending Protocol Address - who is informing their peers\n";
fi

if [ -n "$SOURCE_IPV4_ADDRESS" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ARP_SENDING_PROTOCOL_ADDRESS,32 $SOURCE_IPV4_ADDRESS_DECIMAL \\\\\n";
fi

if [ -n "$SOURCE_IPV4_NETWORK_BASE_ADDRESS_DECIMAL" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ARP_SENDING_PROTOCOL_ADDRESS,32 >= $SOURCE_IPV4_NETWORK_BASE_ADDRESS_DECIMAL \\\\\n";
fi

if [ -n "$SOURCE_IPV4_NETWORK_END_ADDRESS_DECIMAL" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ARP_SENDING_PROTOCOL_ADDRESS,32 <= $SOURCE_IPV4_NETWORK_END_ADDRESS_DECIMAL \\\\\n";
fi

if [ -z "SOURCE_IPV4_ADDRESS" ] && [ -z "$SOURCE_IPV4_NETWORK" ]; then
	printf "\\t\\t#ARP Sending Protocol address unrestricted - consider the security implications.\n";
fi

if [ -n "$MAC_ADDRESS_DESTINATION_CLEANED" ]; then
	printf "\\t#Match Target Hardware Address - who is informing their peers\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ARP_TARGET_HARDWARE_ADDRESS,48 $MAC_ADDRESS_DESTINATION_CLEANED \\\\\n";
else
	printf "\\t\\t#ARP Target Hardware Address unrestricted - please consider the security implications\n";
fi

if [ -n "$DESTINATION_IPV4_ADDRESS" ] || [ -n "$DESTINATION_IPV4_NETWORK" ]; then
	printf "\\t#Match Target Protocol Address - who is informing their peers\n";
fi

if [ -n "$DESTINATION_IPV4_ADDRESS_DECIMAL" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ARP_TARGET_PROTOCOL_ADDRESS,32 $DESTINATION_IPV4_ADDRESS_DECIMAL \\\\\n";
fi

if [ -n "$DESTINATION_IPV4_NETWORK_BASE_ADDRESS_DECIMAL" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ARP_TARGET_PROTOCOL_ADDRESS,32 >= $DESTINATION_IPV4_NETWORK_BASE_ADDRESS_DECIMAL \\\\\n";
fi

if [ -n "$DESTINATION_IPV4_NETWORK_END_ADDRESS_DECIMAL" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ARP_TARGET_PROTOCOL_ADDRESS,32 <= $DESTINATION_IPV4_NETWORK_END_ADDRESS_DECIMAL \\\\\n";
fi

if [ -z "DESTINATION_IPV4_ADDRESS" ] && [ -z "$DESTINATION_IPV4_NETWORK" ]; then
	printf "\\t\\t#ARP Target Protocol address unrestricted - consider the security implications.\n";
fi

exit 0;
