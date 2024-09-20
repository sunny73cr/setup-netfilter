#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.\n">&2; exit 4; fi

DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" is missing or is not executable.">&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_CONVERT_DECIMAL_TO_BINARY="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_base10_to_binary.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CONVERT_DECIMAL_TO_BINARY ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_DECIMAL_TO_BINARY\" is missing or is not executable">&2;
	exit 3;
fi

print_usage_then_exit () {
	echo "Usage: $0 --address <string> --output-bit-order <big-endian|little-endian>">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

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
		--output-bit-order)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				BIT_ORDER=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "Unrecognised argument $1. ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z "$ADDRESS" ]; then
	printf "\nMissing --address. ">&2
fi

$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$ADDRESS"
case $? in
	0) ;;
	1) printf "\nInvalid --address. ">&2; print_usage_then_exit; ;;
	*) printf "$0: dependency \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced a failure exit code.\n">&2; exit 3; ;;
esac

if [ -z "$BIT_ORDER" ]; then
	echo "\nMissing --bit-order. ">&2;
	print_usage_then_exit;
fi

case "$BIT_ORDER" in
	big-endian ) ;;
	little-endian ) ;;
	*) printf "\nInvalid --bit-order. ">&2; print_usage_then_exit; ;;
esac

OCTET1_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_DECIMAL_TO_BINARY \
--number "$(echo "$ADDRESS" | cut -d '.' -f 1)" \
--output-bit-order $BIT_ORDER \
--output-bit-length "8");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_DECIMAL_TO_BINARY\" produced a failure exit code.">&2; exit 3; ;;
esac

OCTET2_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_DECIMAL_TO_BINARY \
--number "$(echo "$ADDRESS" | cut -d '.' -f 2)" \
--output-bit-order $BIT_ORDER \
--output-bit-length "8");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_DECIMAL_TO_BINARY\" produced a failure exit code.">&2; exit 3; ;;
esac

OCTET3_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_DECIMAL_TO_BINARY \
--number "$(echo "$ADDRESS" | cut -d '.' -f 3)" \
--output-bit-order $BIT_ORDER \
--output-bit-length "8");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_DECIMAL_TO_BINARY\" produced a failure exit code.">&2; exit 3; ;;
esac

OCTET4_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_DECIMAL_TO_BINARY \
--number "$(echo "$ADDRESS" | cut -d '.' -f 4)" \
--output-bit-order $BIT_ORDER \
--output-bit-length "8");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_DECIMAL_TO_BINARY\" produced a failure exit code.">&2; exit 3; ;;
esac

if [ "$BIT_ORDER" = "big-endian" ]; then
	printf "$OCTET4_BINARY$OCTET3_BINARY$OCTET2_BINARY$OCTET1_BINARY";
else
	printf "$OCTET1_BINARY$OCTET2_BINARY$OCTET3_BINARY$OCTET4_BINARY";
fi

exit 0;
