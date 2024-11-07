#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_SCRIPT_PATH_SUBSTRING="$ENV_SETUP_NFT/SCRIPT_HELPERS/substring.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_SUBSTRING ]; then
	printf "$0; dependency: \"$DEPENDENCY_SCRIPT_PATH_SUBSTRING\" is missing or is not executable.\n">&2;
	exit 2;
fi

DEPENDENCY_SCRIPT_PATH_EXPONENT="$ENV_SETUP_NFT/SCRIPT_HELPERS/exponent.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_EXPONENT ]; then
	printf "$0; dependency: \"$DEPENDENCY_SCRIPT_PATH_EXPONENT\" is missing or is not executable.\n">&2;
	exit 2;
fi

print_description() {
	printf "A program that converts base 10 (decimal) numbers into a binary string.\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "printf\n">&2;
	printf "echo\n">&2;
	printf "$DEPENDENCY_SCRIPT_PATH_SUBSTRING\n">&2;
	printf "$DEPENDENCY_SCRIPT_PATH_EXPONENT\n">&2;
	printf "grep\n">&2;
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
	printf " Required: --number (0-4,294,967,296)\n">&2;
	printf "\n">&2;
	printf " Optional: --output-bit-order ('big-endian' or 'little-endian') (no hyphens)\n">&2;
	printf "  Alter the 'endianness' of the binary result.">&2;
	printf "  if omitted, output-bit-order defaults to 'little endian'\n">&2;
	printf "\n">&2;
	printf " Optional: --output-bit-length (1 to 32)\n">&2;
	printf "  if omitted, output-bit-length defaults to the smallest length required.\n">&2;
	printf "  if the output-bit-length is greater than neccessary, the binary string is padded with zeroes.\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf "  Presence of this flag causes the program to skip validating inputs (if you know they are correct).\n">&2;
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
NUMBER="";
OUTPUT_BIT_ORDER="";
OUTPUT_BIT_LENGTH="";

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

		--number)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				NUMBER=$2;
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

		--output-bit-length)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				OUTPUT_BIT_LENGTH=$2;
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

#Read number from stdin (support piping input into the program)
if [ -z "$NUMBER" ]; then
	NUMBER=$(dd if=/dev/stdin of=/dev/stdout bs=1 count=10 status=none);

	#else, no number; it is required; print usage and exit
	if [ -z "$NUMBER" ]; then print_usage_then_exit; fi
fi

if [ $SKIP_VALIDATE -eq 0 ]; then
	if [ -z "$NUMBER" ]; then
		printf "\nMissing --number. ">&2;
		print_usage_then_exit;
	fi

	if [ "$(printf $NUMBER | grep '^[0-9]\{1,10\}$')" = "" ]; then
		printf "\nInvalid --number. ">&2;
		print_usage_then_exit;
	fi

	if [ $NUMBER -gt 4294967296 ]; then
		printf "\nInvalid --number. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$BIT_LENGTH" ]; then
		if [ "$(echo $BIT_LENGTH | grep '^[1-9][0-9]\{0,1\}$')" = "" ]; then
			printf "\nInvalid --bit-length. ">&2;
			print_usage_then_exit;
		fi

		if [ "$BIT_LENGTH" -eq 0 ]; then
			printf "\nInvalid --bit-length. ">&2;
			print_usage_then_exit;
		fi

		if [ "$BIT_LENGTH" -gt 32 ]; then
			printf "\nInvalid --bit-length. ">&2;
			print_usage_then_exit;
		fi

		BIT_LENGTH_CAPACITY=$($DEPENDENCY_SCRIPT_PATH_EXPONENT --base 2 --exponent $BIT_LENGTH);
		case $? in
			0) ;;
			*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_EXPONENT\" produced a failure exit code ($?).\n">&2; exit 3; ;;
		esac
		BIT_LENGTH_CAPACITY_MINUS_ONE=$(($BIT_LENGTH_CAPACITY - 1));

		if [ $NUMBER -gt $BIT_LENGTH_CAPACITY_MINUS_ONE ]; then
			printf "\nInvalid --bit-length. ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$BIT_ORDER" ]; then
		case "$BIT_ORDER" in
			"big-endian") ;;
			"little-endian") ;;
			*) printf "\nInvalid --bit-order. ">&2; print_usage_then_exit; ;;
		esac
	else
		BIT_ORDER=1;
	fi

fi

if [ -n "$BIT_ORDER" ]; then
	case "$BIT_ORDER" in
		"big-endian") BIT_ORDER=0; ;;
		"little-endian") BIT_ORDER=1; ;;
		*) BIT_ORDER=1; ;;
	esac
else
	BIT_ORDER=1;
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

# RapidTables.com convert decimal to binary calculator:
# https://www.rapidtables.com/convert/number/decimal-to-binary.html
#
# 1. Input divide 2 == the quotient
# 2. Remainder of quotient modulus 2 == the binary digit
# 3. Repeat until the quotient is equal to 0.

RESULT="";

QUOTIENT="$NUMBER";

while true; do
	if [ $QUOTIENT -eq 0 ]; then break; fi

	if [ $BIT_ORDER -eq 0 ]; then
		#big-endian
		RESULT=$RESULT$(($QUOTIENT % 2));
	else
		#little-endian
		RESULT=$(($QUOTIENT % 2))$RESULT;
	fi

	QUOTIENT=$(($QUOTIENT / 2));
done;

if [ -n "$BIT_LENGTH" ]; then
	#Zero pad binary output to desired bit length.

	ZERO_PAD_COUNT=$(( $BIT_LENGTH - ${#RESULT} ));

	ZERO_PAD="";

	while true; do
		if [ $ZERO_PAD_COUNT -eq 0 ]; then break; fi

		ZERO_PAD="${ZERO_PAD}0";

		ZERO_PAD_COUNT=$(( $ZERO_PAD_COUNT - 1 ));
	done;

	#Zero pad for desired bit order.

	if [ $BIT_ORDER -eq 0 ]; then
		#big endian
		printf "$RESULT$ZERO_PAD";
	else
		#little endian
		printf "$ZERO_PAD$RESULT";
	fi
else
	#no zero padding, already in desired order.
	printf "$RESULT";
fi

exit 0;
