#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_SUBSTRING="$ENV_SETUP_NFT/SCRIPT_HELPERS/substring.sh";

if [ ! -x $DEPENDENCY_PATH_SUBSTRING ]; then
	printf "$0: dependency \"$DEPENDENCY_PATH_SUBSTRING\" is missing or is not executable.">&2;
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
	printf "  The value cannot be longer than 8 characters, due to limitations in Dash's integral types. (64-bit maximum)\n">&2;
	printf "  You must provide only printable characters.\n">&2;
	printf "\n">&2;
	printf " Optional: --bit-length\n">&2;
	printf "  If --bit-length is longer than the length of --ascii * 8, then zero padding is added.\n">&2;
	printf "  If --bit-length is shorter than the length of --ascii * 8, then an error is returned.\n">&2;
	printf "  If --bit-length is not provided, no zero padding occurs.\n">&2;
	printf "\n">&2;
	printf " Optional: --output-bit-order little-endian|big-endian\n">&2;
	printf "  Alter the order in which the converted bits are output.\n">&2;
	printf "  The default is little-endian.\n">&2;
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

		--output-bit-order)
			if [ $# -lt 2 ]; then
				printf "Not enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "Not enough arguments (value for $1 is empty.) ">&2;
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

		if [ $BIT_LENGTH -gt 64 ]; then
			printf "\nInvalid --bit-length (must be less than or equal to 64.) ">&2;
			print_usage_then_exit;
		fi
	fi

	case $OUTPUT_BIT_ORDER in
		little-endian|big-endian) ;;
		*) printf "\nInvalid --output-bit-order. ">&2; print_usage_then_exit; ;;
	esac
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

lookup_character_little_endian() {
	case $CHAR in
		' ') printf "00100000"; ;;
		'!') printf "00100001"; ;;
		'"') printf "00100010"; ;;
		'#') printf "00100011"; ;;
		'$') printf "00100100"; ;;
		'%') printf "00100101"; ;;
		'&') printf "00100110"; ;;
		"'") printf "00100111"; ;;
		'\(') printf "00101000"; ;;
		'\)') printf "00101001"; ;;
		'*') printf "00101010"; ;;
		'+') printf "00101011"; ;;
		',') printf "00101100"; ;;
		'-') printf "00101101"; ;;
		'.') printf "00101110"; ;;
		'/') printf "00101111"; ;;
		'0') printf "00110000"; ;;
		'1') printf "00110001"; ;;
		'2') printf "00110010"; ;;
		'3') printf "00110011"; ;;
		'4') printf "00110100"; ;;
		'5') printf "00110101"; ;;
		'6') printf "00110110"; ;;
		'7') printf "00110111"; ;;
		'8') printf "00111000"; ;;
		'9') printf "00111001"; ;;
		':') printf "00111010"; ;;
		'\;') printf "00111011"; ;;
		'\<') printf "00111100"; ;;
		'\=') printf "00111101"; ;;
		'\>') printf "00111110"; ;;
		'?') printf "00111111"; ;;
		'@') printf "01000000"; ;;
		'A') printf "01000001"; ;;
		'B') printf "01000010"; ;;
		'C') printf "01000011"; ;;
		'D') printf "01000100"; ;;
		'E') printf "01000101"; ;;
		'F') printf "01000110"; ;;
		'G') printf "01000111"; ;;
		'H') printf "01001000"; ;;
		'I') printf "01001001"; ;;
		'J') printf "01001010"; ;;
		'K') printf "01001011"; ;;
		'L') printf "01001100"; ;;
		'M') printf "01001101"; ;;
		'N') printf "01001110"; ;;
		'O') printf "01001111"; ;;
		'P') printf "01010000"; ;;
		'Q') printf "01010001"; ;;
		'R') printf "01010010"; ;;
		'S') printf "01010011"; ;;
		'T') printf "01010100"; ;;
		'U') printf "01010101"; ;;
		'V') printf "01010110"; ;;
		'W') printf "01010111"; ;;
		'X') printf "01011000"; ;;
		'Y') printf "01011001"; ;;
		'Z') printf "01011010"; ;;
		'[') printf "01011011"; ;;
		'\\') printf "01011100"; ;;
		']') printf "01011101"; ;;
		'^') printf "01011110"; ;;
		'_') printf "01011111"; ;;
		'\`') printf "01100000"; ;;
		'a') printf "01100001"; ;;
		'b') printf "01100010"; ;;
		'c') printf "01100011"; ;;
		'd') printf "01100100"; ;;
		'e') printf "01100101"; ;;
		'f') printf "01100110"; ;;
		'g') printf "01100111"; ;;
		'h') printf "01101000"; ;;
		'i') printf "01101001"; ;;
		'j') printf "01101010"; ;;
		'k') printf "01101011"; ;;
		'l') printf "01101100"; ;;
		'm') printf "01101101"; ;;
		'n') printf "01101110"; ;;
		'o') printf "01101111"; ;;
		'p') printf "01110000"; ;;
		'q') printf "01110001"; ;;
		'r') printf "01110010"; ;;
		's') printf "01110011"; ;;
		't') printf "01110100"; ;;
		'u') printf "01110101"; ;;
		'v') printf "01110110"; ;;
		'w') printf "01110111"; ;;
		'x') printf "01111000"; ;;
		'y') printf "01111001"; ;;
		'z') printf "01111010"; ;;
		'{') printf "01111011"; ;;
		'|') printf "01111100"; ;;
		'}') printf "01111101"; ;;
		'~') printf "01111110"; ;;
		*) printf ""; ;;
	esac
}

lookup_character_big_endian() {
	case $CHAR in
		' ') printf "00000100"; ;;
		'!') printf "10000100"; ;;
		'"') printf "01000100"; ;;
		'#') printf "11000100"; ;;
		'$') printf "00100100"; ;;
		'%') printf "10100100"; ;;
		'&') printf "01100100"; ;;
		"'") printf "11100100"; ;;
		'\(') printf "00010100"; ;;
		'\)') printf "10010100"; ;;
		'*') printf "01010100"; ;;
		'+') printf "11010100"; ;;
		',') printf "00110100"; ;;
		'-') printf "10110100"; ;;
		'.') printf "01110100"; ;;
		'/') printf "11110100"; ;;
		'0') printf "00001100"; ;;
		'1') printf "10001100"; ;;
		'2') printf "01001100"; ;;
		'3') printf "11001100"; ;;
		'4') printf "00101100"; ;;
		'5') printf "10101100"; ;;
		'6') printf "01101100"; ;;
		'7') printf "11101100"; ;;
		'8') printf "00011100"; ;;
		'9') printf "10011100"; ;;
		':') printf "01011100"; ;;
		'\;') printf "11011100"; ;;
		'\<') printf "00111100"; ;;
		'\=') printf "10111100"; ;;
		'\>') printf "01111100"; ;;
		'?') printf "11111100"; ;;
		'@') printf "00000010"; ;;
		'A') printf "10000010"; ;;
		'B') printf "01000010"; ;;
		'C') printf "11000010"; ;;
		'D') printf "00100010"; ;;
		'E') printf "10100010"; ;;
		'F') printf "01100010"; ;;
		'G') printf "11100010"; ;;
		'H') printf "00010010"; ;;
		'I') printf "10010010"; ;;
		'J') printf "01010010"; ;;
		'K') printf "11010010"; ;;
		'L') printf "00110010"; ;;
		'M') printf "10110010"; ;;
		'N') printf "01110010"; ;;
		'O') printf "11110010"; ;;
		'P') printf "00001010"; ;;
		'Q') printf "10001010"; ;;
		'R') printf "01001010"; ;;
		'S') printf "11001010"; ;;
		'T') printf "00101010"; ;;
		'U') printf "10101010"; ;;
		'V') printf "01101010"; ;;
		'W') printf "11101010"; ;;
		'X') printf "00011010"; ;;
		'Y') printf "10011010"; ;;
		'Z') printf "01011010"; ;;
		'[') printf "11011010"; ;;
		'\\') printf "00111010"; ;;
		']') printf "10111010"; ;;
		'^') printf "01111010"; ;;
		'_') printf "11111010"; ;;
		'\`') printf "00000110"; ;;
		'a') printf "10000110"; ;;
		'b') printf "01000110"; ;;
		'c') printf "11000110"; ;;
		'd') printf "00100110"; ;;
		'e') printf "10100110"; ;;
		'f') printf "01100110"; ;;
		'g') printf "11100110"; ;;
		'h') printf "00010110"; ;;
		'i') printf "10010110"; ;;
		'j') printf "01010110"; ;;
		'k') printf "11010110"; ;;
		'l') printf "00110110"; ;;
		'm') printf "10110110"; ;;
		'n') printf "01110110"; ;;
		'o') printf "11110110"; ;;
		'p') printf "00001110"; ;;
		'q') printf "10001110"; ;;
		'r') printf "01001110"; ;;
		's') printf "11001110"; ;;
		't') printf "00101110"; ;;
		'u') printf "10101110"; ;;
		'v') printf "01101110"; ;;
		'w') printf "11101110"; ;;
		'x') printf "00011110"; ;;
		'y') printf "10011110"; ;;
		'z') printf "01011110"; ;;
		'{') printf "11011110"; ;;
		'|') printf "00111110"; ;;
		'}') printf "10111110"; ;;
		'~') printf "01111110"; ;;
		*) printf ""; ;;
	esac
}

case $OUTPUT_BIT_ORDER in
	little-endian) OUTPUT_BIT_ORDER=0; ;;
	big-endian) OUTPUT_BIT_ORDER=1; ;;
	*) printf "\nInvalid --output-bit-order. ">&2; print_usage_then_exit; ;;
esac

BINARY_STRING="";

STRING_LENGTH=${#ASCII};
i=0;
while true; do
	CHAR=$($DEPENDENCY_PATH_SUBSTRING --input $ASCII --start-idx $i --length 1);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_SUBSTRING\" produced a failure exit code ($?).\n">&2; exit 3; ;;
	esac

	if [ $OUTPUT_BIT_ORDER -eq 0 ]; then
		CHAR_BINARY=$(lookup_character_little_endian $CHAR);
	else
		CHAR_BINARY=$(lookup_character_big_endian $CHAR);
	fi

	if [ -z "$CHAR_BINARY" ]; then
		printf "\nInvalid --ascii (not a printable ascii character). ">&2;
		print_usage_then_exit;
	fi

	BINARY_STRING="$BINARY_STRING$CHAR_BINARY";

	i=$(($i+1));
	if [ $i -eq $STRING_LENGTH ]; then break; fi
done

BINARY_STRING_LENGTH=${#BINARY_STRING};

if [ -n "$BIT_LENGTH" ] && [ -n "$(echo $BIT_LENGTH | grep '[0-9]\{1,2\}')" ] && [ $BINARY_STRING_LENGTH -lt $BIT_LENGTH ]; then
	ZERO_COUNT=$(($BIT_LENGTH-$BINARY_STRING_LENGTH));
	i=0;
	while true; do
		BINARY_STRING="${BINARY_STRING}0";

		i=$(($i+1));
		if [ $i -eq $ZERO_COUNT ]; then break; fi
	done;
fi

printf "$BINARY_STRING";

exit 0;
