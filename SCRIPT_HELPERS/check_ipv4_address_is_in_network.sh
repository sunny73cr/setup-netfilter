#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.\n">&2; exit 4; fi

DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";
DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_network_is_valid.sh";
DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_ipv4_address_to_binary.sh";
DEPENDENCY_SCRIPT_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_cidr_network_to_base_address.sh";
DEPENDENCY_SCRIPT_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_cidr_network_to_end_address.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID ]; then
	printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" is missing or is not executable.\n">&2;
	exit 3;
fi

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID ]; then
	printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID\" is missing or is not executable.\n">&2;
	exit 3;
fi

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY ]; then
	printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" is missing or is not executable.\n">&2;
	exit 3;
fi

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS ]; then
	printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS\" is missing or is not executable.\n">&2;
	exit 3;
fi

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS ]; then
	printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_usage_then_exit () {
	printf "Usage: $0 <arguments>\n">&2;
	printf " --address X.X.X.X (where X is 0-255)\n">&2;
	printf " --network X.X.X.X/Y (where X is 0-255, and Y is 1-32)\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validate\n">&2;
	printf " Skip output, and exit after validating parameters.\n">&2;
	printf "\n">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; else fi

ADDRESS="";
NETWORK="";
ONLY_VALIDATE=0;

while true; do
	case $1 in
		--address)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#value is empty
			if [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				ADDRESS=$2;
				shift 2;
			fi
		;;
		--network)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#value is empty
			if [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				NETWORK=$2;
				shift 2;
			fi
		;;
		--only-validate)
			ONLY_VALIDATE=1;
			shift 1;
		;;
		"") break; ;;
		*) printf "Unrecognised argument $1. ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z "$ADDRESS" ]; then
	printf "\nMissing --address. ">&2;
	print_usage_then_exit;
fi

$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$ADDRESS"
case $? in
	0)
	1) printf "\nInvalid --address. ">&2; print_usage_then_exit; ;;
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced a failure exit code.\n">&2; exit 3; ;;
esac

$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID --network "$NETWORK"
case $? in
	0)
	1) printf "\nInvalid --network. ">&2; print_usage_then_exit; ;;
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_NETWORK_IS_VALID\" produced a failure exit code.\n">&2; exit 3; ;;
esac

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$ADDRESS" \
--output-bit-order "little-endian");
case $? in
	0)
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" produced a failure exit code.\n">&2; exit 3; ;;
esac

CIDR_NETWORK_BASE_ADDRESS=$($DEPENDENCY_SCRIPT_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS --network "$NETWORK");
case $? in
	0)
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS\" produced a failure exit code.\n">&2; exit 3; ;;
esac

CIDR_NETWORK_BASE_ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$CIDR_NETWORK_BASE_ADDRESS" \
--output-bit-order "little-endian");
case $? in
	0)
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" produced a failure exit code.\n">&2; exit 3; ;;
esac

CIDR_NETWORK_END_ADDRESS=$($DEPENDENCY_SCRIPT_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS --network "$NETWORK");
case $? in
	0)
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CIDR_NETWORK_TO_END_ADDRESS\" produced a failure exit code.\n">&2; exit 3; ;;
esac

CIDR_NETWORK_END_ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$CIDR_NETWORK_END_ADDRESS" \
--output-bit-order "little-endian");
case $? in
	0)
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" produced a failure exit code.\n">&2; exit 3; ;;
esac

#
# Using lexicographical comparison helps to avoid converting the addresses to decimal.
# Less than base address or greater than end address
#
if \
[ "$ADDRESS_BINARY" \< "$CIDR_NETWORK_BASE_ADDRESS_BINARY" ] || \
[ "$ADDRESS_BINARY" \> "$CIDR_NETWORK_END_ADDRESS_BINARY" ]; then
	printf "$0: the address is not contained within the network.\n">&2;
	exit 1;
else
	exit 0;
fi
