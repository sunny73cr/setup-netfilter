#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_network_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID ]; then
	echo "$0; dependency: \"$DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID\" is missing or is not executable.">&2;
	exit 3;
fi

DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_ipv4_address_to_binary.sh";

if [ ! -x $DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY ]; then
	echo "$0; dependency: \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" is missing or is not executable.">&2;
	exit 3;
fi

DEPENDENCY_PATH_CONVERT_BINARY_TO_DECIMAL="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_binary_to_base10.sh";

if [ ! -x $DEPENDENCY_PATH_CONVERT_BINARY_TO_DECIMAL ]; then
	echo "$0; dependency: \"$DEPENDENCY_PATH_CONVERT_BINARY_TO_DECIMAL\" is missing or is not executable.">&2;
	exit 3;
fi

print_description() {
	printf "A program that converts am IPV4 network in CIDR form to the lowest address in its scope.\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "printf\n">&2;
	printf "echo\n">&2;
	printf "cut\n">&2;
	printf "$DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID\n">&2;
	printf "$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\n">&2;
	printf "$DEPENDENCY_PATH_CONVERT_BINARY_TO_DECIMAL\n">&2;
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
	printf " Required: --network X.X.X.X/Y (where X is 0-255, and Y is 1-32)\n">&2;
	printf "  The IPV4 network in CIDR form to convert\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf "  Presence of this flag causes the program to skip validating inputs (if you know they are valid).\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validate\n">&2;
	printf "  Presence of this flag causes the program to exit after valdiating inputs.\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
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
	if [ -z "$NETWORK" ]; then
		echo "\nMissing --network. ">&2;
		print_usage_then_exit;
	fi

	$DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID --network "$ADDRESS"
	case $? in
		0) ;;
		1) printf "\nInvalid --network. ">&2; print_usage_then_exit; ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CHECK_IPV4_NETWORK_IS_VALID\" produced a failure exit code ($?).">&2; exit 3; ;;
	esac
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

MASK=$(echo "$ADDRESS" | cut -d '/' -f 2);

if [ "$MASK" -eq 0 ]; then
	echo "\nInvalid CIDR network mask. ">&2;
	print_usage_then_exit;
fi

ADDRESS=$(echo "$ADDRESS" | cut -d '/' -f 1);

if [ "$MASK" -eq 32 ]; then
	echo "\nInvalid CIDR network mask. ">&2;
	print_usage_then_exit;
fi

##s
# Convert the address to binary.
# Zero the bits that are not masked.
# Convert the address into decimal.
#
#			                 |'Zero' these bits.
# Network Decimal: 	192.168.5.1/16   | -------------->
# Binary: 		11000000.10101000.00000101.00000001
# Mask:   		11111111.11111111.00000000.00000000
#
# Base Address Decimal: 192.168.0.0/16
# Binary:		11000000.10101000.00000000.00000000
# Mask:			11111111.11111111.00000000000000000
##

ADDRESS_BINARY=$($DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY \
--address "$ADDRESS" \
--output-bit-order "little-endian");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_BINARY\" produced a failure exit code ($?).">&2; exit 3; ;;
esac

ADDRESS_BINARY_MASKED=$(echo $ADDRESS_BINARY | cut -c "1-$MASK");

THIRTY_TWO_ZEROES="00000000000000000000000000000000";

ZERO_FILL=$(echo "$THIRTY_TWO_ZEROES" | cut -c "1-$((32-$MASK))");

ADDRESS_BASE_BINARY="$ADDRESS_BINARY_MASKED$ZERO_FILL";

ADDRESS_BASE_DECIMAL_OCTET1=$($DEPENDENCY_PATH_CONVERT_BINARY_TO_DECIMAL \
--binary "$(echo "$ADDRESS_BASE_BINARY" | cut -c '1-8')" \
--input-bit-order "little-endian");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_PATH_CONVERT_BINARY_TO_DECIMAL\" produced a failure exit code ($?).">&2; exit 3; ;;
esac

ADDRESS_BASE_DECIMAL_OCTET2=$($DEPENDENCY_PATH_CONVERT_BINARY_TO_DECIMAL \
--binary "$(echo "$ADDRESS_BASE_BINARY" | cut -c '9-16')" \
--input-bit-order "little-endian");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_PATH_CONVERT_BINARY_TO_DECIMAL\" produced a failure exit code ($?).">&2; exit 3; ;;
esac

ADDRESS_BASE_DECIMAL_OCTET3=$($DEPENDENCY_PATH_CONVERT_BINARY_TO_DECIMAL \
--binary "$(echo "$ADDRESS_BASE_BINARY" | cut -c '17-24')" \
--input-bit-order "little-endian");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_PATH_CONVERT_BINARY_TO_DECIMAL\" produced a failure exit code ($?).">&2; exit 3; ;;
esac

ADDRESS_BASE_DECIMAL_OCTET4=$($DEPENDENCY_PATH_CONVERT_BINARY_TO_DECIMAL \
--binary "$(echo "$ADDRESS_BASE_BINARY" | cut -c '25-32')" \
--input-bit-order "little-endian");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_PATH_CONVERT_BINARY_TO_DECIMAL\" produced a failure exit code ($?).">&2; exit 3; ;;
esac

printf "$ADDRESS_BASE_DECIMAL_OCTET1.$ADDRESS_BASE_DECIMAL_OCTET2.$ADDRESS_BASE_DECIMAL_OCTET3.$ADDRESS_BASE_DECIMAL_OCTET4";

exit 0;
