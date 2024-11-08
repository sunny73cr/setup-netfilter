#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

print_description() {
	printf "A program that converts a hexadecimal string to binary.\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "printf\n">&2;
	printf "echo\n">&2;
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
	printf " Required: --hex X (where x is a 1-65536 character hexadecimal string)\n">&2;
	printf "  The hexadecimal string to convert.\n">&2;
	printf "  Please note that the limit is arbitrary; you may increase the limit if you desire.\n">&2;
	printf "\n">&2;
	printf " Optional: --output-bit-length X (where X is 1-262144).\n">&2;
	printf "  The bit-length of the binary string output.\n">&2;
	printf "  If the bit-length is greater than the output string, zero padding is added.\n">&2;
	printf "  If the bit-length is not provided, no zero padding occurs.\n">&2;
	printf "\n">&2;
	printf " Optional: --output-bit-order big-endian|little-endian\n">&2;
	printf "  Alters the direction in which the bits are ordered.\n">&2;
	printf "  The default is little-endian.\n">&2;
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
HEX="";
OUTPUT_BIT_LENGTH=4;
OUTPUT_BIT_ORDER="little-endian";

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

		--hex)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				HEX=$2;
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
	if [ -z "$HEX" ]; then
		printf "\nMissing --hex. ">&2;
		print_usage_then_exit;
	fi

	#Due to the large potential length of HEX; to speed up the program when converting a long string,
	#use an imperative approach compared to a delcarative approach with REGEX.
	i=1;
	while true; do
		CHAR=$(echo $HEX | cut -c $i);
		if [ -z "$CHAR" ]; then break; fi

		case $CHAR in
			0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|A|B|C|D|E|F) ;;
			*) printf "\nInvalid --hex (must be a hexadecimal string) ">&2; print_usage_then_exit; ;;
		esac

		i=$(($i+1));
	done;

	HEX_STR_LEN=${#HEX};

	if [ $HEX_STR_LEN -lt 1 ]; then
		printf "\nInvalid --hex (must be a 1-65536 character hexadecimal string). ">&2;
		print_usage_then_exit;
	fi

	if [ $HEX_STR_LEN -gt 65536 ]; then
		printf "\nInvalid --hex (must be a 1-65536 character hexadecimal string). ">&2;
		print_usage_then_exit;
	fi

	case $OUTPUT_BIT_ORDER in
		little-endian|big-endian) ;;
		*) printf "\nInvalid --output-bit-order. ">&2; print_usage_then_exit; ;;
	esac

	if [ -n $OUTPUT_BIT_LENGTH ]; then
		if [ -z "$(echo $OUTPUT_BIT_LENGTH | grep '[0-9]\{1,6\}')" ]; then
			printf "\nInvalid --output-bit-length (Must be a 1-2 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $OUTPUT_BIT_LENGTH -lt 1 ]; then
			printf "\nInvalid --output-bit-length (must be 1 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $OUTPUT_BIT_LENGTH -gt 262144 ]; then
			printf "\nInvalid --output-bit-length (must be 262144 or less). ">&2;
			print_usage_then_exit;
		fi
	fi
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

lookup_hex_little_endian() {
	case $1 in
		0) printf "0000"; ;;
		1) printf "0001"; ;;
		2) printf "0010"; ;;
		3) printf "0011"; ;;
		4) printf "0100"; ;;
		5) printf "0101"; ;;
		6) printf "0110"; ;;
		7) printf "0111"; ;;
		8) printf "1000"; ;;
		9) printf "1001"; ;;
		a|A) printf "1010"; ;;
		b|B) printf "1011"; ;;
		c|C) printf "1100"; ;;
		d|D) printf "1101"; ;;
		e|E) printf "1110"; ;;
		f|F) printf "1111"; ;;
		*) printf "\n$0: Invalid character when converting hex to binary. cannot continue. ">&2; exit 4; ;;
	esac
}

lookup_hex_big_endian() {
	case $1 in
		0) printf "0000"; ;;
		1) printf "1000"; ;;
		2) printf "0100"; ;;
		3) printf "1100"; ;;
		4) printf "0010"; ;;
		5) printf "1010"; ;;
		6) printf "0110"; ;;
		7) printf "1110"; ;;
		8) printf "0001"; ;;
		9) printf "1001"; ;;
		a|A) printf "0101"; ;;
		b|B) printf "1101"; ;;
		c|C) printf "0011"; ;;
		d|D) printf "1011"; ;;
		e|E) printf "0111"; ;;
		f|F) printf "1111"; ;;
		*) printf "\n$0: Invalid character when converting hex to binary. cannot continue. ">&2; exit 4; ;;
	esac
}

case $OUTPUT_BIT_ORDER in
	little-endian) OUTPUT_BIT_ORDER=0; ;;
	big-endian) OUTPUT_BIT_ORDER=1; ;;
	*) printf "\nInvalid --output-bit-order. ">&2; print_usage_then_exit; ;;
esac

BINARY_STRING="";

i=1;
while true; do
	CHAR=$(echo $HEX | cut -c $i);
	if [ -z "$CHAR" ]; then break; fi

	if [ $OUTPUT_BIT_ORDER -eq 0 ]; then
		BINARY=$(lookup_hex_little_endian $CHAR);
	else
		BINARY=$(lookup_hex_big_endian $CHAR);
	fi

	BINARY_STRING="$BINARY_STRING$BINARY";

	i=$(($i+1));
done;

BINARY_STR_LEN=${#BINARY_STRING};

if [ $OUTPUT_BIT_LENGTH -lt $BINARY_STR_LEN ]; then
	OUTPUT_BIT_LENGTH=$BINARY_STR_LEN;
fi

if [ $BINARY_STR_LEN -lt $OUTPUT_BIT_LENGTH ]; then
	ZERO_PAD_COUNT=$(($OUTPUT_BIT_LENGTH-$BINARY_STR_LEN));

	while true; do
		if [ $ZERO_PAD_COUNT -eq 0 ]; then break; fi

		ZERO_PAD="${ZERO_PAD}0";

		ZERO_PAD_COUNT=$(($ZERO_PAD_COUNT-1));
	done;

	if [ $OUTPUT_BIT_ORDER -eq 0 ]; then
		BINARY_STRING="$ZERO_PAD$BINARY_STRING";
	else
		BINARY_STRING="$BINARY_STRING$ZERO_PAD";
	fi

fi

printf "$BINARY_STRING";

exit 0;
