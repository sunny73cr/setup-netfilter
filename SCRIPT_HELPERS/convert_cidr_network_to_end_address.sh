#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.\n">&2; exit 4; fi

DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_network_is_valid.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID ]; then
	echo "$0; dependency: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID\" is missing or is not executable.">&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_ipv4_address_to_binary.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY ]; then
	echo "$0; dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" is missing or is not executable.">&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_DECIMAL="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_binary_to_base10.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_DECIMAL ]; then
	echo "$0; dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_DECIMAL\" is missing or is not executable.">&2;
	exit 3;
fi

print_usage_then_exit () {
	printf "Usage: $0 <arguments>\n">&2
	printf " --network X.X.X.X/Y (where X is 0-255, and Y is 1-32)\n">&2;
	printf "\n">&2
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

while true; do
	case "$1" in
		--network )
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
	echo "\nMissing --address. ">&2;
	print_usage_then_exit;
fi

$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID --network "$ADDRESS"
case $? in
	0) ;;
	1) printf "\nInvalid --address. ">&2; print_usage_then_exit; ;;
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID\" produced a failure exit code.">&2; exit 3; ;;
esac

MASK=$(echo "$ADDRESS" | cut -d '/' -f 2);

if [ "$MASK" -eq 0 ]; then
	echo "\nInvalid CIDR network mask. ">&2;
	print_usage_then_exit;
fi

ADDRESS=$(echo "$ADDRESS" | cut -d '/' -f 1);

if [ "$MASK" -eq 32 ]; then
	echo "\nInvalid CIDR network mask. ">&2;
	print_usage_then_exit;
fi

##
# Convert the address to binary.
# One the bits that are not masked.
# Convert the address into decimal.
#
#			                 |'One' these bits.
# Network Decimal: 	192.168.5.1/16   | -------------->
# Binary: 		11000000.10101000.00000101.00000001
# Mask:   		11111111.11111111.00000000.00000000
#
# End Address Decimal: 192.168.255.255/16
# Binary:		11000000.10101000.11111111.11111111
# Mask:			11111111.11111111.00000000000000000
##

ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$ADDRESS" \
--output-bit-order "little-endian");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" produced a failure exit code.">&2; exit 3; ;;
esac

ADDRESS_BINARY_MASKED=$(echo $ADDRESS_BINARY | cut -c "1-$MASK");

THIRTY_TWO_ONES="11111111111111111111111111111111";

ONE_FILL=$(echo "$THIRTY_TWO_ONES" | cut -c "1-$((32-$MASK))");

ADDRESS_BASE_BINARY="$ADDRESS_BINARY_MASKED$ONE_FILL";

ADDRESS_BASE_DECIMAL_OCTET1=$($DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_DECIMAL \
--binary "$(echo "$ADDRESS_BASE_BINARY" | cut -c "1-8")" \
--input-bit-order "little-endian");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_DECIMAL\" produced a failure exit code.">&2; exit 3; ;;
esac

ADDRESS_BASE_DECIMAL_OCTET2=$($DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_DECIMAL \
--binary "$(echo "$ADDRESS_BASE_BINARY" | cut -c "9-16")" \
--input-bit-order "little-endian");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_DECIMAL\" produced a failure exit code.">&2; exit 3; ;;
esac

ADDRESS_BASE_DECIMAL_OCTET3=$($DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_DECIMAL \
--binary "$(echo "$ADDRESS_BASE_BINARY" | cut -c "17-24")" \
--input-bit-order "little-endian");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_DECIMAL\" produced a failure exit code.">&2; exit 3; ;;
esac

ADDRESS_BASE_DECIMAL_OCTET4=$($DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_DECIMAL \
--binary "$(echo "$ADDRESS_BASE_BINARY" | cut -c "25-32")" \
--input-bit-order "little-endian");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_DECIMAL\" produced a failure exit code.">&2; exit 3; ;;
esac

printf "$ADDRESS_BASE_DECIMAL_OCTET1.$ADDRESS_BASE_DECIMAL_OCTET2.$ADDRESS_BASE_DECIMAL_OCTET3.$ADDRESS_BASE_DECIMAL_OCTET4";

exit 0;
