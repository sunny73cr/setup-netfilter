#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.\n">&2; exit 4; fi

DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID ]; then
	printf "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_ipv4_address_to_binary.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY ]; then
	printf "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_BASE10="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_binary_to_base10.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_BASE10 ]; then
	printf "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_BASE10\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_usage_then_exit() {
	printf "Usage: $0 <argument>\.">&2
	printf " --address X.X.X.X (where X is 0-255)\n">&2;
	printf "\n">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

while true; do
	case "$1" in
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
		*) printf "Unrecognised argument $1. ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z "$ADDRESS" ]; then
	printf "\nMissing --address. ">&2;
	print_status_then_exit;
fi

$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$ADDRESS"
case $? in
	0) ;;
	1) printf "\nInvalid --address. ">&2; print_usage_then_exit; ;;
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced a failure exit code.\n">&2;
esac

ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$ADDRESS" \
--output-bit-order "little-endian");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" produced a failure exit code.\n">&2;
esac

ADDRESS_BASE10=$($DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_BASE10 \
--binary "$ADDRESS_BINARY" \
--input-bit-order "little-endian");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_BASE10\" produced a failure exit code.\n">&2;
esac

printf "$ADDRESS_BASE10";

exit 0;
