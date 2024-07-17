#!/bin/sh

DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID="./SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID" ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" is missing or is not executable.">&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY="./SCRIPT_HELPERS/convert_ipv4_address_to_binary.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY" ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" is missing or is not executable.">&2;
	exit 3;
fi

check_success () {
	if [ "$?" -ne 0 ]; then
		echo "$0; cannot confirm is the address is within the range.">&2;
		exit 3;
	fi
}

usage () {
	echo "Usage: $0 --address <X.X.X.X> --range <X.X.X.X-X.X.X.X>">&2;
	exit 2;
}

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--address )
			ADDRESS="$2";
			#if not enough arguments
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--range )
			NETWORK="$2";
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

IS_IPV4_ADDRESS_VALID=$($DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$ADDRESS");
check_success;

ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$ADDRESS" \
--output-bit-order "little-endian");
check_success;

RANGE_START_ADDRESS=$(echo $RANGE | cut -d '-' -f 1);

IS_START_IPV4_ADDRESS_VALID=$($DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$RANGE_START_ADDRESS");
check_success;

RANGE_START_ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$RANGE_START_ADDRESS" \
--output-bit-order "little-endian");
check_success;

RANGE_END_ADDRESS=$(echo $RANGE | cut -d '-' -f 2);

IS_END_IPV4_ADDRESS_VALID=$($DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$RANGE_END_ADDRESS");
check_success;

RANGE_END_ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$RANGE_END_ADDRESS" \
--output-bit-order "little-endian");
check_success;

#
# Using lexicographical comparison helps to avoid converting the addresses to decimal.
#

#If addresses appear out of order, re-order them
if [ "$RANGE_START_ADDRESS_BINARY" > "$RANGE_END_ADDRESS_BINARY" ]; then
	TEMP="$RANGE_START_ADDRESS_BINARY";
	RANGE_START_ADDRESS_BINARY=$RANGE_END_ADDRESS_BINARY;
	RANGE_END_ADDRESS_BINARY=$TEMP;
fi

# Less than base address or greater than end address
if \
[ "$ADDRESS_BINARY" \< "$RANGE_START_ADDRESS_BINARY" ] || \
[ "$ADDRESS_BINARY" \> "$RANGE_END_ADDRESS_BINARY" ]; then
	echo "$0; the address is not contained within the range.">&2;
	exit 2;
else
	exit 0;
fi
