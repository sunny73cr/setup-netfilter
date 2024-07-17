#!/bin/sh

DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID="./SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID" ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" is missing or is not executable.">&2;
	exit 3;
fi

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

DEPENDENCY_SCRIPT_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS="./SCRIPT_HELPERS/convert_cidr_network_to_base_address.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS" ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS\" is missing or is not executable.">&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS="./SCRIPT_HELPERS/convert_cidr_network_to_end_address.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS" ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS\" is missing or is not executable.">&2;
	exit 3;
fi

check_success () {
	if [ "$?" -ne 0 ]; then
		echo "$0; cannot confirm is the address is within the network.">&2;
		exit 3;
	fi
}

usage () {
	echo "Usage: $0 --address <X.X.X.X> --network <X.X.X.X/X>">&2;
	exit 2;
}

if [ "$1" = "" ]; then usage; else fi

while true; do
	case "$1" in
		--address )
			ADDRESS="$2";
			#if not enough arguments
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--network )
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

if [ -z "$ADDRESS" ]; then
	echo "$0; you must provide an ipv4 address (0.0.0.0)">&2;
	exit 2;
fi

IS_IPV4_ADDRESS_VALID=$($DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$ADDRESS");
check_success;

ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$ADDRESS" \
--output-bit-order "little-endian");
check_success;

IS_IPV4_NETWORK_VALID=$($DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID --network "$NETWORK");
check_success;

CIDR_NETWORK_BASE_ADDRESS=$($DEPENDENCY_SCRIPT_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS --network "$NETWORK");
check_failure;

CIDR_NETWORK_BASE_ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$CIDR_NETWORK_BASE_ADDRESS" \
--output-bit-order "little-endian");
check_success;

CIDR_NETWORK_END_ADDRESS=$($DEPENDENCY_SCRIPT_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS --network "$NETWORK");
check_success;

CIDR_NETWORK_END_ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$CIDR_NETWORK_END_ADDRESS" \
--output-bit-order "little-endian");
check_success;

#
# Using lexicographical comparison helps to avoid converting the addresses to decimal.
# Less than base address or greater than end address
#
if \
[ "$ADDRESS_BINARY" \< "$CIDR_NETWORK_BASE_ADDRESS_BINARY" ] || \
[ "$ADDRESS_BINARY" \> "$CIDR_NETWORK_END_ADDRESS_BINARY" ]; then
	echo "$0; the address is not contained within the network.">&2;
	exit 2;
else
	exit 0;
fi
