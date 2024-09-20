#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "Set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.">&2; exit 4; fi

DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";
DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_ipv4_address_to_binary.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" is missing or is not executable.">&2;
	exit 3;
fi

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" is missing or is not executable.">&2;
	exit 3;
fi

print_usage_then_exit () {
	echo "Usage: $0 --address <X.X.X.X> --range <X.X.X.X-X.X.X.X>">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

while true; do
	case $1 in
		--address)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -E '^-')" != "" ]; then
				print_usage_then_exit;
			else
				ADDRESS=$2;
				shift 2;
			fi
		;;
		--range)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -E '^-')" != "" ]; then
				print_usage_then_exit;
			else
				NETWORK=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "Unrecognised argument - ">&2; print_usage_then_exit; ;;
	esac
done

$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$ADDRESS"
case $? in
	0) ;;
	1) echo "$0: you have proivided an invalid ip address, format is X.X.X.X (where X is 0-255)">&2; exit 2;
	*) echo "$0: script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced a failure exit code">&2 exit 3; ;;
esac

ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$ADDRESS" \
--output-bit-order "little-endian");
case $? in
	0) ;;
	*) echo "$0: script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" produced a failure exit code">&2 exit 3; ;;
esac

RANGE_START_ADDRESS=$(echo $RANGE | cut -d '-' -f 1);

$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$RANGE_START_ADDRESS"
case $? in
	0) ;;
	1) echo "$0: you have proivided an invalid lower bound ip address, format is X.X.X.X (where X is 0-255)">&2; exit 2;
	*) echo "$0: script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced a failure exit code">&2 exit 3; ;;
esac

RANGE_START_ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$RANGE_START_ADDRESS" \
--output-bit-order "little-endian");
case $? in
	0) ;;
	*) echo "$0: script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" produced a failure exit code">&2 exit 3; ;;
esac

RANGE_END_ADDRESS=$(echo $RANGE | cut -d '-' -f 2);

$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$RANGE_END_ADDRESS"
case $? in
	0) ;;
	1) echo "$0: you have proivided an invalid upper bound ip address, format is X.X.X.X (where X is 0-255)">&2; exit 2;
	*) echo "$0: script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced a failure exit code">&2 exit 3; ;;
esac

RANGE_END_ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$RANGE_END_ADDRESS" \
--output-bit-order "little-endian");
case $? in
	0) ;;
	*) echo "$0: script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" produced a failure exit code">&2 exit 3; ;;
esac

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
	exit 1;
else
	exit 0;
fi
