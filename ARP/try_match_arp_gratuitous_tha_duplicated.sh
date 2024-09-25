#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory first.">&2; exit 4; fi

DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_valid.sh";
DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_source_is_banned.sh";
DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";
DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_network_is_valid.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS ]; then
	printf "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS\" is missing or is not executable.\n">&2;
	exit 3;
fi

if [ ! -x $DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE ]; then
	printf "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE\" is missing or is not executable.\n">&2;
	exit 3;
fi

if [ ! -x $DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS ]; then
	printf "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS\" is missing or is not executable.\n">&2;
	exit 3;
fi

if [ ! -x $DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK ]; then
	printf "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_usage () {
	printf "Usage: $0 <arguments>\n">&2;
	printf " Optional: --source-mac-address XX:XX:XX:XX:XX:XX (where X is a-f, or A-F, or 0-9: hexadecimal)\n">&2;
	printf " Note: it is strongly recommended to supply a source MAC address.\n">&2;
	printf "\n">&2;
	printf " Optional: --requested-address-ipv4 X.X.X.X (where X is 0-255)\n">&2
	printf " Optional: --requested-network-ipv4 X.X.X.X/Y (where X is 0-255, and Y is 1-32)\n">&2;
	printf " Note: it is strongly recommended to supply either an address or a network.\n">&2;
	printf " Note: you cannot supply both an address and a network.\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validate\n">&2;
	printf " Note: this causes the program to skip parameter validation (if you know they are valid)\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validate\n">&2;
	printf " Note: this causes the program to exit after validating parameters.\n">&2;
	printf "\n">&2;
}

print_usage_then_exit () {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

describe_script () {
	printf "$0: a script to match a packet where the content indicates it is likely a \"Gratuitous ARP\" packet; where the target hardware address is duplicated in the 'arp ether saddr' and 'arp ether daddr' fields.\n">&2;
	printf "\n">&2;
}

describe_script_then_exit () {
	describe_script;
	exit 2;
}

if [ "$1" = "-e" ]; then describe_script_then_exit; fi

if [ "$1" = "-eh" ]; then describe_script; print_usage; exit 2; fi

MAC_ADDRESS_SOURCE="";
REQUESTED_ADDRESS="";
REQUESTED_NETWORK="";
SKIP_VALIDATE=0;
ONLY_VALIDATE=0;

while true; do
	case $1 in
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
		--requested-address)
			#not enough argynents
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
			#not enough argynents
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
		--skip-validate)
			SKIP_VALIDATE=1;
			shift 1;
		;;
		--only-validate)
			ONLY_VALIDATE=1;
			shift 1;
		;;
		"") break; ;;
		*) printf "\nUnrecognised argument $1. "; print_usage_then_exit; ;;
	esac
done

#Why, user?
if [ $SKIP_VALIDATE -eq 1 ] && [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

if [ $SKIP_VALIDATE -eq 0 ]; then

	if [ -n "$REQUESTED_ADDRESS" ] && [ -n "$REQUESTED_NETWORK" ]; then
		printf "\nAddress claim is ambiguous; you cannot supply both an address and a network.\n\n">&2;
		print_usage_then_exit;
	fi

	if [ -n "$MAC_ADDRESS_SOURCE" ]; then
		$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS --address "$MAC_ADDRESS_SOURCE";
		case $? in
			0) ;;
			1) printf "\nInvalid --source-mac-address. " >&2; print_usage_then_exit; ;;
			*) printf "$0; dependency: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS\" produced a failure exit code.\n" >&2; exit 3; ;;
		esac

		$DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE --address "$MAC_ADDRESS_SOURCE"
		case $? in
			1) ;;
			0) printf "$0; source mac address is not permitted.\n" >&2; exit 2; ;;
			*) printf "$0; dependency: \"$DEPENDENCY_SCRIPT_PATH_IS_MAC_ADDRESS_BANNED_AS_SOURCE\" produced a failure exit code.\n" >&2; exit 3; ;;
		esac
	fi

	if [ -n "$REQUESTED_ADDRESS" ]; then
		$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS --address "$REQUESTED_ADDRESS"
		case $? in
			0) ;;
			1) printf "\nInvalid --requested-address. ">&2; print_usage_then_exit; ;;
			*) printf "$0; dependency: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS\" produced a failure exit code.\n">&2; exit 3; ;;
		esac
	fi

	if [ -n "$REQUESTED_NETWORK" ]; then
		$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK --address "$REQUESTED_NETWORK"
		case $? in
			0) ;;
			1) printf "\nInvalid --requested-network. ">&2; print_usage_then_exit; ;;
			*) printf "$0; dependency: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_NETWORK\" produced a failure exit code.\n">&2; exit 3; ;;
		esac
	fi
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

if [ -n "$REQUESTED_ADDRESS" ]; then
	TO_PROBE=$REQUESTED_ADDRESS;
fi

if [ -n "$REQUESTED_NETWORK" ]; then
	TO_PROBE=$REQUESTED_NETWORK;
fi

printf "\\t#Hardware Type (1 = Ethernet)\n";
printf "\\t\\tarp htype 1 \\\\\n";

printf "\\t#Hardware Length (6 = MAC address segment count)\n";
printf "\\t\\tarp hlen 6 \\\\\n";

printf "\\t#Protocol Type (0x0800 = IPV4 ethertype)\n";
printf "\\t\\tarp ptype 0x0800 \\\\\n";

printf "\\t#Protocol Length (4 = IPV4 address segment count)\n";
printf "\\t\\tarp plen 4 \\\\\n";

printf "\\t#ARP OP Code (1 = request)\n";
printf "\\t\\tarp operation 1 \\\\\n";

printf "\\t#Source and Destination MAC address - who is informing their peers\n";
if [ -n "$MAC_ADDRESS_SOURCE" ]; then
	printf "\\t\\tarp saddr ether $MAC_ADDRESS_SOURCE \\\\\n";
	printf "\\t\\tarp daddr ether $MAC_ADDRESS_SOURCE \\\\\n";
else
	printf "\\t\\t#arp saddr ether unknown - please consider the security implications\n";
	printf "\\t\\t#arp daddr ether unknown - please consider the security implications\n";
fi

printf "\\t#Source and Destination IP address - who is informing their peers\n";
if [ -n "$TO_PROBE" ]; then
	printf "\\t\\tarp saddr ip $TO_PROBE \\\\\n";
	printf "\\t\\tarp daddr ip $TO_PROBE \\\\\n";
else
	printf "\\t\\t#arp saddr ip unknown - please consider the security implications\n";
	printf "\\t\\t#arp daddr ip unknown - please consider the security implications\n";
fi

exit 0;
