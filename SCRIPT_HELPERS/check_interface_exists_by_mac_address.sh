#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "Set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.">&2; exit 4; fi

DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_valid.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID ]; then
	printf "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_usage_then_exit () {
	printf "Usage: $0 --address XX:XX:XX:XX:XX:XX (where X is a-f, or A-F, or 0-9: hexadecimal)">&2;
	exit 2;
}

ADDRESS="";

if [ "$1" = "" ]; then print_usage_then_exit; fi

while true; do
	case $1 in
		--address)
			#if not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#value is empty
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				ADDRESS=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "Unrecognised argument - ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z "$ADDRESS" ]; then
	printf "$0: you must provide a mac address.\n">&2;
	exit 2;
fi

$DEPENDENCY_SCRIPT_PATH_CHECK_MAC_ADDRESS_IS_VALID --address "$ADDRESS"
case $? in
	0) ;;
	1) printf "$0: the mac address you supplied is invalid. Format is XX:XX:XX:XX:XX:XX (where X is a-f, or A-F, or 0-9: hexadecimal)\n">&2; exit 2; ;;
	*) printf "$0: script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS\" produced a failure exit code.\n">&2; exit 3; ;;
esac

ALL_INTERFACE_DESCRIPTIONS_BRIEF=$(ip -br link show);

INTERFACE_DESCRIPTIONS_FILTERED_BY_NAME=$(echo "$ALL_INTERFACE_DESCRIPTIONS_BRIEF" | grep "$ADDRESS");

if [ -n "$INTERFACE_DESCRIPTIONS_FILTERED_BY_NAME" ]; then
	exit 0;
else
	printf "$0: that interface does not exist.\n">&2;
	exit 1;
fi
