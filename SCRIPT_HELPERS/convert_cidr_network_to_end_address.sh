#!/bin/sh

DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID="./SCRIPT_HELPERS/check_ipv4_network_is_valid.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID" ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID\" is missing or is not executable.">&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY="./SCRIPT_HELPERS/convert_ipv4_address_to_binary.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY" ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" is missing or is not executable.">&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_DECIMAL="./SCRIPT_HELPERS/convert_binary_to_base10.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_DECIMAL" ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_DECIMAL\" is missing or is not executable">&2;
	exit 3;
fi

check_success () {
	if [ "$?" -ne 0 ]; then
		echo "$0; cannot find the base address.">&2;
		exit 3;
	fi
}

usage () {
	echo "Usage: $0 --network <string>">&2;
	exit 2;
}

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--network )
			ADDRESS="$2";
			#if not enough arguments
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		"" ) break; ;;
		*)
			echo "">&2;
			echo "Unrecognised option: $1 $2">&2;
			usage;
		;;
	esac
done

IS_IPV4_NETWORK_VALID=$($DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID --network "$ADDRESS");
check_success;

MASK=$(echo "$ADDRESS" | cut -d '/' -f 2);

if [ "$MASK" -eq 0 ]; then
	echo "$0; mask should not be zero.">&2;
	exit 2;
fi

ADDRESS=$(echo "$ADDRESS" | cut -d '/' -f 1);

if [ "$MASK" -eq 32 ]; then
	echo "$ADDRESS";
	exit 0;
fi

##
# Convert the address to binary.
# Cut the address where its mask ends
# Set the remaining bits to one.
# Convert the address into decimal.
#
#			                 |'One' these bits.
# Network Decimal: 	192.168.5.1/16   | -------------->
# Binary: 		11000000.10101000.00000101.00000001
# Mask:   		11111111.11111111.00000000.00000000
#
# End Address Decimal:	192.168.255.255/16
# Binary:		11000000.10101000.11111111.11111111
# Mask:			11111111.11111111.00000000.00000000
##

ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$ADDRESS" \
--output-bit-order "little-endian");
check_success;

ADDRESS_BINARY_MASKED=$(echo $ADDRESS_BINARY | cut -c "1-$MASK");

SPACE_LEFT=$((32-$MASK));

THIRTY_TWO_ONES="11111111111111111111111111111111";

ONE_FILL=$(echo "$THIRTY_TWO_ONES" | cut -c "1-$SPACE_LEFT");

ADDRESS_BINARY_END="$ADDRESS_BINARY_MASKED$ONE_FILL";

ADDRESS_END_BINARY_OCTET1=$(echo "$ADDRESS_BINARY_END" | cut -c "1-8");
ADDRESS_END_BINARY_OCTET2=$(echo "$ADDRESS_BINARY_END" | cut -c "9-16");
ADDRESS_END_BINARY_OCTET3=$(echo "$ADDRESS_BINARY_END" | cut -c "17-24");
ADDRESS_END_BINARY_OCTET4=$(echo "$ADDRESS_BINARY_END" | cut -c "25-32");

ADDRESS_END_DECIMAL_OCTET1=$($DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_DECIMAL \
--binary "$ADDRESS_END_BINARY_OCTET1" \
--input-bit-order "little-endian");
check_success;

ADDRESS_END_DECIMAL_OCTET2=$($DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_DECIMAL \
--binary "$ADDRESS_END_BINARY_OCTET2" \
--input-bit-order "little-endian");
check_success;

ADDRESS_END_DECIMAL_OCTET3=$($DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_DECIMAL \
--binary "$ADDRESS_END_BINARY_OCTET3" \
--input-bit-order "little-endian");
check_success;

ADDRESS_END_DECIMAL_OCTET4=$($DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_DECIMAL \
--binary "$ADDRESS_END_BINARY_OCTET4" \
--input-bit-order "little-endian");
check_success;

ADDRESS_DECIMAL_END="$ADDRESS_END_DECIMAL_OCTET1.$ADDRESS_END_DECIMAL_OCTET2.$ADDRESS_END_DECIMAL_OCTET3.$ADDRESS_END_DECIMAL_OCTET4";

echo $ADDRESS_DECIMAL_END;
exit 0;
