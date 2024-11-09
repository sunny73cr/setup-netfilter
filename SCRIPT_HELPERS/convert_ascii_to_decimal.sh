#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_CONVERT_ASCII_TO_BINARY="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_ascii_to_binary.sh";

if [ ! -x $DEPENDENCY_PATH_CONVERT_ASCII_TO_BINARY ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_CONVERT_ASCII_TO_BINARY\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CONVERT_BINARY_TO_DECIMAL="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_binary_to_base10.sh";

if [ ! -x $DEPENDENCY_PATH_CONVERT_BINARY_TO_DECIMAL ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_CONVERT_BINARY_TO_DECIMAL\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_description() {
	printf "A program that converts an ascii string into a decimal number.\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "printf\n">&2;
	printf "echo\n">&2;
	printf "$DEPENDENCY_PATH_CONVERT_ASCII_TO_BINARY\n">&2;
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
	printf " Required: --ascii x (where x is the string you wish to convert.)\n">&2;
	printf "  The value cannot be longer than 4 characters, due to limitations in Dash's integral types. (32-bit maximum)\n">&2;
	printf "\n">&2;
	printf " Optional: --bit-length\n">&2;
	printf "  If --bit-length is longer than the length of --ascii * 8, then zero padding is added.">&2;
	printf "  If --bit-length is shorter than the length of --ascii * 8, then an error is returned.">&2;
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
BIT_LENGTH=8;
ASCII="";

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

		--ascii)
			if [ $# -lt 2 ]; then
				printf "Not enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "Not enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				ASCII=$2;
				shift 2;
			fi
		;;

		--bit-length)
			if [ $# -lt 2 ]; then
				printf "Not enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "Not enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				BIT_LENGTH=$2;
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
	ASCII_LENGTH=0;

	if [ -z "$ASCII" ]; then
		printf "\nMissing --ascii. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$ASCII" ]; then
		ASCII_LENGTH="${#ASCII}";
	fi

	if [ -n "$BIT_LENGTH" ]; then
		if [ -z "$(echo $BIT_LENGTH | grep '[0-9]\{1,2\}')" ]; then
			printf "\nInvalid --bit-length (must be a 1-2 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $BIT_LENGTH -lt 8 ]; then
			printf "\nInvalid --bit-length (must be greater than or equal to 8.) ">&2;
			print_usage_then_exit;
		fi

		if [ $BIT_LENGTH -gt 32 ]; then
			printf "\nInvalid --bit-length (must be less than or equal to 32.) ">&2;
			print_usage_then_exit;
		fi
	fi
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

#If BIT_LENGTH wasnt provided, no padding, increase BIT_LENGTH to the length of $ASCII.
if [ $BIT_LENGTH -lt ${#ASCII} ]; then BIT_LENGTH=${#ASCII}; fi

ASCII_BINARY=$($DEPENDENCY_PATH_CONVERT_ASCII_TO_BINARY --ascii $ASCII --bit-length $BIT_LENGTH);
case $? in
	0) ;;
	*) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_ASCII_TO_BINARY\" produced a failure exit code ($?). ">&2; exit 3; ;;
esac

ASCII_DECIMAL=$($DEPENDENCY_PATH_CONVERT_BINARY_TO_DECIMAL --binary $ASCII_BINARY --input-bit-order "little-endian");
case $? in
	0) ;;
	8) printf "$0: dependency \"$DEPENDENCY_PATH_CONVERT_BINARY_TO_DECIMAL\" produced a failure exit code ($?). ">&2; exit 3; ;;
esac

printf "$ASCII_DECIMAL";

exit 0;
