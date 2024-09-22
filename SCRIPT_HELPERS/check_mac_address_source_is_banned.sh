#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory first.\n">&2; exit 4; fi

SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_valid.sh";

SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_BROADCAST="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_broadcast.sh";

SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_MULTICAST="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_multicast.sh";

if [ ! -x $SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID ]; then
	printf "$0: dependency: \"$SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID\" is missing or is not executable.\n">&2;
	exit 3;
fi

if [ ! -x $SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_BROADCAST ]; then
	printf "$0: dependency: \"$SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_BROADCAST\" is missing or is not executable.\n">&2;
	exit 3;
fi

if [ ! -x $SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_MULTICAST ]; then
	printf "$0: dependency: \"$SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_MULTICAST\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_usage_then_exit () {
	printf "Usage: $0 <arguments>\n">&2;
	printf "\n">&2;
	printf " --address XX:XX:XX:XX:XX:XX (where X is a-f, A-F, or 0-9: hexadecimal.)\n">&2;
	printf "\n">&2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

ADDRESS=$2;

while true; do
	case $1 in
		--address)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				ADDRESS=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "\nUnrecognised argument $1. ">&2; print_usage_then_exit; ;;
	esac
done;

if [ -z "$ADDRESS" ]; then
	printf "\nMissing --address. ">&2;
	print_usage_then_exit;
fi

$SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID --address $ADDRESS;
case $? in
	0) ;;
	1) printf "\nInvalid --address. ">&2; print_usage_then_exit; ;;
	*) printf "$0: dependency \"SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID\" produced a failure exit code.\n">&2; exit 3; ;;
esac

$SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_BROADCAST --address $ADDRESS;
case $? in
	1) ;;
	0) printf "Invalid source mac address.\n">&2; exit 0; ;;
	*) printf "$0: dependency \"SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_BROADCAST\" produced a failure exit code.\n">&2; exit 3; ;;
esac

$SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_MULTICAST --address $ADDRESS;
case $? in
	1) ;;
	0) printf "\nInvalid source mac address.\n">&2; exit 0; ;;
	*) printf "$0: dependency \"SCRIPT_DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_MULTICAST\" produced a failure exit code.\n">&2; exit 3; ;;
esac

#not banned
exit 1;
