#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.\n">&2; exit 4; fi

DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_valid.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS\" is missing or is not executable.">&2;
	exit 3;
fi

print_usage_then_exit () {
	echo "Usage: $0 --address XX:XX:XX:XX:XX:XX (where X is a-f, A-F, 0-9: hexadecimal)">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

ADDRESS="";

while true; do
	case $1 in
		--address )
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
		*) printf "Unrecognised argument - ">&2; print_usage_then_exit; ;;
	esac
done

$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS --address "$ADDRESS";
case $? in
	0) ;;
	1) printf "$0: you provided an invalid mac address. It must be in the form XX:XX:XX:XX:XX:XX, where X is a-f, or A-F, or 0-9: hexadecimal.\n">&2; exit 2; ;;
	*) printf "$0: script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_MAC_ADDRESS\" produced a failure exit code.\n">&2 exit 3; ;;
esac

FIRST_OCTET=$(echo "$ADDRESS" | cut -d ':' -f 1);

MASK_FIRST_OCTET=$(( $FIRST_OCTET&1 ));

if [ "$MASK_FIRST_OCTET" -ne 0 ]; then
#the least significant bit in the first octet is 1.
	exit 0;
else
	exit 1;
fi
