#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" is missing or is not executable.">&2;
	exit 3;
fi

DEPENDENCY_PATH_CONVERT_DECIMAL_TO_BINARY="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_base10_to_binary.sh";

if [ ! -x $DEPENDENCY_PATH_CONVERT_DECIMAL_TO_BINARY ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_PATH_CONVERT_DECIMAL_TO_BINARY\" is missing or is not executable">&2;
	exit 3;
fi

print_description() {
	printf "A program that converts an IPV4 address into a binary string.\n">&2;
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
	printf "$DEPENDENCY_PATH_CONVERT_DECIMAL_TO_BINARY\n">&2;
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
	printf " -h (prints an explanation of the functions' available parameters, and their effect) (exit code ($?) 2)\n">&2;
	printf " -d (prints the functions' dependencies: newline delimited list) (exit code ($?) 2)\n">&2;
	printf " -ehd (prints the above three) (exit code ($?) 2)\n">&2;
	printf "\n">&2;
	printf "Parameters:\n">&2;
	printf "\n">&2;
	printf " Required: --address X.X.X.X (Where X is 0-255)\n">&2;
	printf "  The IPV4 address to convert.\n">&2;
	printf "\n">&2;
	printf " Optional: --output-bit-order little-endian|big-endian\n">&2;
	printf "  The 'endianness' of the output binary. Controls the position of the 'least significant bit' for each octet.\n">&2;
	printf "  The default is little-endian.\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-valdiation\n">&2;
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
OUTPUT_BIT_ORDER="";

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

		--output-bit-order)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				OUTPUT_BIT_ORDER=$2;
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
		printf "\nMissing --address. ">&2
	fi

	$DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID --address "$ADDRESS"
	case $? in
		0) ;;
		1) printf "\nInvalid --address. ">&2; print_usage_then_exit; ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_CHECK_IPV4_ADDRESS_IS_VALID\" produced a failure exit code ($?).\n">&2; exit 3; ;;
	esac

	if [ -z "$OUTPUT_BIT_ORDER" ]; then
		echo "\nMissing --output-bit-order. ">&2;
		print_usage_then_exit;
	fi

	case "$OUTPUT_BIT_ORDER" in
		big-endian ) ;;
		little-endian ) ;;
		*) printf "\nInvalid --output-bit-order. ">&2; print_usage_then_exit; ;;
	esac
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

OCTET1_BINARY=$($DEPENDENCY_PATH_CONVERT_DECIMAL_TO_BINARY \
--number "$(echo $ADDRESS | cut -d '.' -f 1)" \
--output-bit-order $OUTPUT_BIT_ORDER \
--output-bit-length "8");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_PATH_CONVERT_DECIMAL_TO_BINARY\" produced a failure exit code ($?).">&2; exit 3; ;;
esac

OCTET2_BINARY=$($DEPENDENCY_PATH_CONVERT_DECIMAL_TO_BINARY \
--number "$(echo $ADDRESS | cut -d '.' -f 2)" \
--output-bit-order $OUTPUT_BIT_ORDER \
--output-bit-length "8");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_PATH_CONVERT_DECIMAL_TO_BINARY\" produced a failure exit code ($?).">&2; exit 3; ;;
esac

OCTET3_BINARY=$($DEPENDENCY_PATH_CONVERT_DECIMAL_TO_BINARY \
--number "$(echo $ADDRESS | cut -d '.' -f 3)" \
--output-bit-order $OUTPUT_BIT_ORDER \
--output-bit-length "8");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_PATH_CONVERT_DECIMAL_TO_BINARY\" produced a failure exit code ($?).">&2; exit 3; ;;
esac

OCTET4_BINARY=$($DEPENDENCY_PATH_CONVERT_DECIMAL_TO_BINARY \
--number "$(echo $ADDRESS | cut -d '.' -f 4)" \
--output-bit-order $OUTPUT_BIT_ORDER \
--output-bit-length "8");
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_PATH_CONVERT_DECIMAL_TO_BINARY\" produced a failure exit code ($?).">&2; exit 3; ;;
esac

if [ "$BIT_ORDER" = "big-endian" ]; then
	printf "$OCTET4_BINARY$OCTET3_BINARY$OCTET2_BINARY$OCTET1_BINARY";
else
	printf "$OCTET1_BINARY$OCTET2_BINARY$OCTET3_BINARY$OCTET4_BINARY";
fi

exit 0;
