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

DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_BASE10="./SCRIPT_HELPERS/convert_binary_to_base10.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_BASE10" ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_BASE10\" is missing or is not executable.">&2;
	exit 3;
fi

check_success () {
	if [ "$?" -ne 0 ]; then
		echo "$0; cannot convert the address to decimal.">&2;
		exit 3;
	fi
}

usage () {
	echo "Usage: $0 --address <X.X.X.X>">&2;
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

ADDRESS_BASE10=$($DEPENDENCY_SCRIPT_PATH_CONVERT_BINARY_TO_BASE10 \
--binary "$ADDRESS_BINARY" \
--input-bit-order "little-endian");
check_success;

echo $ADDRESS_BASE10;
exit 0;
