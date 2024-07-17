#!/bin/sh

DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID="./SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID" ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" is missing or is not executable.">&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_CONVERT_DECIMAL_TO_BINARY="./SCRIPT_HELPERS/convert_base10_to_binary.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_CONVERT_DECIMAL_TO_BINARY" ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_DECIMAL_TO_BINARY\" is missing or is not executable">&2;
	exit 3;
fi

usage () {
	echo "Usage: $0 --address <string> --output-bit-order <big-endian|little-endian>">&2;
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
		--output-bit-order )
			BIT_ORDER="$2";
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

if [ -z "$BIT_ORDER" ]; then
	echo "$0; you must provide an output bit order. (try '--output-bit-order big-endian' or '--output-bit-order little-endian' without quotes.)">&2;
	exit 2;
fi

case "$BIT_ORDER" in
	big-endian ) ;;
	little-endian ) ;;
	*)
		echo "$0; unrecognised bit order. (try '--output-bit-order big-endian' or '--output-bit-order little-endian' without quotes.)">&2;
		exit 2;
	;;
esac

OCTET1=$(echo "$ADDRESS" | cut -d '.' -f 1);
OCTET2=$(echo "$ADDRESS" | cut -d '.' -f 2);
OCTET3=$(echo "$ADDRESS" | cut -d '.' -f 3);
OCTET4=$(echo "$ADDRESS" | cut -d '.' -f 4);

OCTET1_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_DECIMAL_TO_BINARY \
--number "$OCTET1" \
--output-bit-order $BIT_ORDER \
--output-bit-length "8");
check_success;

OCTET2_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_DECIMAL_TO_BINARY \
--number "$OCTET2" \
--output-bit-order $BIT_ORDER \
--output-bit-length "8");
check_success;

OCTET3_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_DECIMAL_TO_BINARY \
--number "$OCTET3" \
--output-bit-order $BIT_ORDER \
--output-bit-length "8");
check_success;

OCTET4_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_DECIMAL_TO_BINARY \
--number "$OCTET4" \
--output-bit-order $BIT_ORDER \
--output-bit-length "8");
check_success;

if [ "$BIT_ORDER" = "big-endian" ]; then
	ADDRESS_BINARY="$OCTET4_BINARY$OCTET3_BINARY$OCTET2_BINARY$OCTET1_BINARY";
elif [ "$BIT_ORDER" = "little-endian" ]; then
	ADDRESS_BINARY="$OCTET1_BINARY$OCTET2_BINARY$OCTET3_BINARY$OCTET4_BINARY";
fi

echo "$ADDRESS_BINARY";
exit 0;
