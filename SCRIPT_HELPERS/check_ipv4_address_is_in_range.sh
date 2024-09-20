#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.\n">&2; exit 4; fi

DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";
DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_ipv4_address_to_binary.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID ]; then
	printf "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" is missing or is not executable.\n">&2;
	exit 3;
fi

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY ]; then
	printf "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_usage_then_exit () {
	printf "Usage: $0 <arguments>\n"">&2;
	printf " --address X.X.X.X (where X is 0-255)\n">&2;
	printf " --range X.X.X.X-X.X.X.X (where X is 0-255)\n">&2;
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
		--range)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
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
	1) printf "$0: you have proivided an invalid ip address, format is X.X.X.X (where X is 0-255)\n">&2; exit 2;
	*) printf "$0: script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced a failure exit code\n">&2 exit 3; ;;
esac

ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$ADDRESS" \
--output-bit-order "little-endian");
case $? in
	0) ;;
	*) printf "$0: script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" produced a failure exit code\n">&2 exit 3; ;;
esac

RANGE_START_ADDRESS=$(echo $RANGE | cut -d '-' -f 1);

$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$RANGE_START_ADDRESS"
case $? in
	0) ;;
	1) printf "$0: you have proivided an invalid range start ip address, format is X.X.X.X (where X is 0-255)\n">&2; exit 2;
	*) printf "$0: script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced a failure exit code\n">&2 exit 3; ;;
esac

RANGE_START_ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$RANGE_START_ADDRESS" \
--output-bit-order "little-endian");
case $? in
	0) ;;
	*) printf "$0: script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" produced a failure exit code\n">&2 exit 3; ;;
esac

RANGE_END_ADDRESS=$(echo $RANGE | cut -d '-' -f 2);

$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$RANGE_END_ADDRESS"
case $? in
	0) ;;
	1) printf "$0: you have proivided an invalid range end ip address, format is X.X.X.X (where X is 0-255)\n">&2; exit 2;
	*) printf "$0: script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced a failure exit code\n">&2 exit 3; ;;
esac

RANGE_END_ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$RANGE_END_ADDRESS" \
--output-bit-order "little-endian");
case $? in
	0) ;;
	*) printf "$0: script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" produced a failure exit code\n">&2 exit 3; ;;
esac

#If addresses are out of order, re-order them
if [ "$RANGE_START_ADDRESS_BINARY" > "$RANGE_END_ADDRESS_BINARY" ]; then
	TEMP="$RANGE_START_ADDRESS_BINARY";
	RANGE_START_ADDRESS_BINARY=$RANGE_END_ADDRESS_BINARY;
	RANGE_END_ADDRESS_BINARY=$TEMP;
fi

#
# Using lexicographical comparison helps to avoid converting the addresses to decimal.
#

# Less than base address or greater than end address
if \
[ "$ADDRESS_BINARY" \< "$RANGE_START_ADDRESS_BINARY" ] || \
[ "$ADDRESS_BINARY" \> "$RANGE_END_ADDRESS_BINARY" ]; then
	printf "$0; the address is not contained within the range.\n">&2;
	exit 1;
else
	exit 0;
fi
