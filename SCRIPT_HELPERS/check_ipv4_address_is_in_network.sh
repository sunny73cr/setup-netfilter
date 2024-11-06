#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID ]; then
	printf "$0: dependency \"$DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_network_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID ]; then
	printf "$0: dependency \"$DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_ipv4_address_to_binary.sh";

if [ ! -x $DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY ]; then
	printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_cidr_network_to_base_address.sh";

if [ ! -x $DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS ]; then
	printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_cidr_network_to_end_address.sh";

if [ ! -x $DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS ]; then
	printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS\" is missing or is not executable.\n">&2;
	exit 3;
fi


print_description() {
	printf "A program that confirms if the provided address is part of the provided network in cidr form.\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "printf\n">&2;
	printf "echo\n">&2;
	printf "$DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID\n">&2;
	printf "$DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID\n">&2;
	printf "$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\n">&2;
	printf "$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS\n">&2;
	printf "$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS\n">&2;
	printf "\n">&2;
}

print_dependencies_then_exit() {
	print_dependencies;
	exit 2;
}

if [ "$1" = "-d" ]; then print_dependencies_then_exit; fi

print_usage() {
	printf "Flags used by themselves: \n">&2;
	printf " -e (prints an explanation of the functions' purpose) (exit code 2)\n">&2
	printf " -h (prints an explanation of the functions' available parameters, and their effect) (exit code 2)\n">&2;
	printf " -d (prints the functions' dependencies: newline delimited list) (exit code 2)\n">&2;
	printf " -ehd (prints the above three) (exit code 2)\n">&2;
	printf "\n">&2;
	printf "Parameters:\n">&2;
	printf "\n">&2;
	printf " Required: --address X.X.X.X (where X is 0-255)\n">&2;
	printf "  The address that is or isnt within the --network\n">&2;
	printf "\n">&2;
	printf " Required: --network X.X.X.X/Y (where X is 0-255, and Y is 1-32)\n">&2;
	printf "  The network that does or does not contain the --address.\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf "  Presence of this flag causes the program to skip validating inputs (if you know they are valid).\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validate\n">&2;
	printf "  Presence of this flag causes the program to exit after validating inputs.\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
ADDRESS="";
NETWORK="";

#FLAGS:
SKIP_VALIDATION=0;
ONLY_VALIDATE=0;

while true; do
	case $1 in
		#Approach to parsing arguments:
		#If the length of 'all arguments' is less than 2 (shift reduces this number),
		#since this is an argument parameter and requires a value; the program cannot continue.
		#Else, if the argument was provided, and its 'value' is empty; the program cannot continue.
		#Else, assign the argument, and shift 2 (both the argument indicator and its value / move next)

		--address)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				ADDRESS=$2;
				shift 2;
			fi
		;;

		--network)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				NETWORK=$2;
				shift 2;
			fi
		;;

		#Approach to parsing flags:
		#If the flag was provided, toggle on its value; then move next
		#Or shift 1 / remove the flag from the list

		--skip-validation)
			SKIP_VALIDATION=1;
			shift 1;
		;;

		--only-validate)
			ONLY_VALIDATE=1;
			shift 1;
		;;

		#Handle the case of 'end' of arg parsing; where all flags are shifted from the list,
		#or the program was called without any parameters. exit the arg parsing loop.
		"") break; ;;

		#Handle the case where an argument or flag was called that the program does not recognise.
		#This should prefix the 'usage' text with the reason the program failed.
		#The 'Standard Error' file descriptor is used to separate failure output or log messages from actual program output.
		*) printf "\nUnrecognised argument $1. ">&2; print_usage_then_exit; ;;

	esac
done;

if [ $SKIP_VALIDATION -eq 0 ]; then
	if [ -z "$ADDRESS" ]; then
		printf "\nMissing --address. ">&2;
		print_usage_then_exit;
	fi

	$DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$ADDRESS"
	case $? in
		0)
		1) printf "\nInvalid --address. ">&2; print_usage_then_exit; ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced a failure exit code ($?).\n">&2; exit 3; ;;
	esac

	$DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID --network "$NETWORK"
	case $? in
		0)
		1) printf "\nInvalid --network. ">&2; print_usage_then_exit; ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID\" produced a failure exit code ($?).\n">&2; exit 3; ;;
	esac
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

ADDRESS_BINARY=$($DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$ADDRESS" \
--output-bit-order "little-endian");
case $? in
	0)
	*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" produced a failure exit code ($?).\n">&2; exit 3; ;;
esac

CIDR_NETWORK_BASE_ADDRESS=$($DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS --network "$NETWORK");
case $? in
	0)
	*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS\" produced a failure exit code ($?).\n">&2; exit 3; ;;
esac

CIDR_NETWORK_BASE_ADDRESS_BINARY=$($DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$CIDR_NETWORK_BASE_ADDRESS" \
--output-bit-order "little-endian");
case $? in
	0)
	*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" produced a failure exit code ($?).\n">&2; exit 3; ;;
esac

CIDR_NETWORK_END_ADDRESS=$($DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS --network "$NETWORK");
case $? in
	0)
	*) printf "$0: dependency \"$DEPENDENCY_PATH_CIDR_NETWORK_TO_END_ADDRESS\" produced a failure exit code ($?).\n">&2; exit 3; ;;
esac

CIDR_NETWORK_END_ADDRESS_BINARY=$($DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$CIDR_NETWORK_END_ADDRESS" \
--output-bit-order "little-endian");
case $? in
	0)
	*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" produced a failure exit code ($?).\n">&2; exit 3; ;;
esac

#
# Using lexicographical comparison to avoid converting the addresses to decimal for integral comparison.
# Less than base address or greater than end address is a failure.
#
if \
[ "$ADDRESS_BINARY" \< "$CIDR_NETWORK_BASE_ADDRESS_BINARY" ] || \
[ "$ADDRESS_BINARY" \> "$CIDR_NETWORK_END_ADDRESS_BINARY" ]; then
	printf "$0: the address is not contained within the network.\n">&2;
	exit 1;
else
	exit 0;
fi
