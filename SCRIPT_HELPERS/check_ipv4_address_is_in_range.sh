#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID ]; then
	printf "$0; dependency \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_ipv4_address_to_binary.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY ]; then
	printf "$0; dependency \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_description() {
	printf "A program that confirms if the provided ipv4 address is contained in the provided range.\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "printf\n">&2;
	printf "echo\n">&2;
	printf "$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\n">&2;
	printf "$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\n">&2;
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
	printf " Required: --address X.X.X.X (where x is 0-255)\n">&2;
	printf "  The ipv4 address that is or isnt within (inclusive) the --range.\n">&2;
	printf "\n">&2;
	printf " Required: --range X.X.X.X-X.X.X.X (where x is 0-255)\n">&2;
	printf "  The ipv4 address range that does or does not contain the --address.\n">&2;
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
RANGE="";

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

		--range)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				RANGE=$2;
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

	if [ -z "$RANGE" ]; then
		printf "\nMissing --range. ">&2;
		print_usage_then_exit;
	fi

	$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$ADDRESS"
	case $? in
		0) ;;
		1) printf "\nInvalid --address. ">&2; print_usage_then_exit; ;;
		*) printf "$0: dependency \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced a failure exit code ($?).\n">&2 exit 3; ;;
	esac

	if [ -z "$(echo $RANGE | grep '^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}-[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$')" ]; then
		printf "\nInvalid --range. ">&2;
		print_usage_then_exit;
	fi

	RANGE_START_ADDRESS=$(echo $RANGE | cut -d '-' -f 1);

	$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$RANGE_START_ADDRESS"
	case $? in
		0) ;;
		1) printf "\nInvalid --range. ">&2; print_usage_then_exit; ;;
		*) printf "$0: dependency \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced a failure exit code ($?).\n">&2 exit 3; ;;
	esac

	RANGE_END_ADDRESS=$(echo $RANGE | cut -d '-' -f 2);

	$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$RANGE_END_ADDRESS"
	case $? in
		0) ;;
		1) printf "\nInvalid --range. ">&2; print_usage_then_exit; ;;
		*) printf "$0: dependency \"$DEPENDENCY_SCRIPT_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced a failure exit code ($?).\n">&2 exit 3; ;;
	esac
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$ADDRESS" \
--output-bit-order "little-endian");
case $? in
	0) ;;
	*) printf "$0: dependency \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" produced a failure exit code ($?).\n">&2 exit 3; ;;
esac

RANGE_START_ADDRESS=$(echo $RANGE | cut -d '-' -f 1);

RANGE_START_ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$RANGE_START_ADDRESS" \
--output-bit-order "little-endian");
case $? in
	0) ;;
	*) printf "$0: dependency \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" produced a failure exit code ($?).\n">&2 exit 3; ;;
esac

RANGE_END_ADDRESS=$(echo $RANGE | cut -d '-' -f 2);

RANGE_END_ADDRESS_BINARY=$($DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$RANGE_END_ADDRESS" \
--output-bit-order "little-endian");
case $? in
	0) ;;
	*) printf "$0: dependency \"$DEPENDENCY_SCRIPT_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" produced a failure exit code ($?).\n">&2 exit 3; ;;
esac

#If addresses are out of order, re-order them
if [ "$RANGE_START_ADDRESS_BINARY" \> "$RANGE_END_ADDRESS_BINARY" ]; then
	TEMP="$RANGE_START_ADDRESS_BINARY";
	RANGE_START_ADDRESS_BINARY=$RANGE_END_ADDRESS_BINARY;
	RANGE_END_ADDRESS_BINARY=$TEMP;
fi

#
# Using lexicographical comparison to avoid converting the addresses to decimal for integral comparison.
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
