#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.\n">&2; exit 4; fi

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

print_usage_then_exit () {
	printf "Usage: $0 <arguments>\n">&2;
	printf " --number (0 - 4,294,967,296; without delimiters)\n">&2;
	printf "\n">&2;
	printf " Optional: --output-bit-order ('big-endian' or 'little-endian') (no hyphens)\n">&2;
	printf " Note: if omitted, output-bit-order defaults to 'little endian'\n">&2;
	printf "\n">&2;
	printf " Optional: --output-bit-length (1 to 32)\n">&2;
	printf " Note: if omitted, output-bit-length defaults to the smallest length required.\n">&2;
	printf " Note: if the output-bit-length is greater than neccessary, the binary string is padded with zeroes.\n">&2;
	printf "\n">&2;
	printf " Optional: --newline-suffix-output\n">&2;
	printf " Note: if enabled, append a newline character to the end of the output.\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validate\n">&2;
	printf " Note: this causes the program to exit after performing validation.\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validate\n">&2;
	printf " Note: this causes the program to skip validation (if you know the inputs are correct.)\n">&2;
	printf "\n">&2;
	exit 2;
}

NUMBER="";
BIT_ORDER="";
BIT_LENGTH="";

ONLY_VALIDATE=0;
SKIP_VALIDATE=0;
NEWLINE_SUFFIX_OUTPUT=0;

while true; do
	case "$1" in
		--number)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				NUMBER=$2;
				shift 2;
			fi
		;;
		--output-bit-order)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				BIT_ORDER=$2;
				shift 2;
			fi
		;;
		--output-bit-length)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				BIT_LENGTH=$2;
				shift 2;
			fi
		;;
		--newline-suffix-output)
			NEWLINE_SUFFIX_OUTPUT=1;
			shift 1;
		;;
		--only-validate)
			ONLY_VALIDATE=1;
			shift 1;
		;;
		--skip-validate)
			SKIP_VALIDATE=1;
			shift 1;
		;;
		"") break; ;;
		*) printf "Unrecognised argument .">&2; print_usage_then_exit; ;;
	esac
done

if [ $ONLY_VALIDATE -eq 1 ] && [ $SKIP_VALIDATE -eq 1 ]; then
	#why?
	exit 0;
fi

if [ -z "$NUMBER" ]; then
	NUMBER=$(dd if=/dev/stdin of=/dev/stdout bs=1 count=10 status=none);

	if [ -z "$NUMBER" ]; then print_usage_then_exit; fi
fi

if [ $SKIP_VALIDATE -eq 0 ]; then
	if [ -z "$NUMBER" ]; then
		printf "\nMissing --number. ">&2;
		print_usage_then_exit;
	fi

	if [ "$(printf $NUMBER | grep -E '^[0-9]{1,10}$')" = "" ]; then
		printf "\nInvalid --number. ">&2;
		print_usage_then_exit;
	fi

	if [ $NUMBER -gt 4294967296 ]; then
		printf "\nInvalid --number. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$BIT_LENGTH" ]; then
		if [ "$(echo $BIT_LENGTH | grep -E '^[1-9][0-9]{0,1}$')" = "" ]; then
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
			*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_EXPONENT\" produced a failure exit code.\n">&2; exit 3; ;;
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

	#BIT_LENGTH_MINUS_ONE=$(($BIT_LENGTH-1));

	ZERO_PAD_COUNT=$(( $BIT_LENGTH - ${#RESULT} ));

	ZERO_PAD="";

	ZERO="0";

	while true; do
		if [ $ZERO_PAD_COUNT -eq 0 ]; then break; fi

		ZERO_PAD="$ZERO_PAD$ZERO";

		ZERO_PAD_COUNT=$(( $ZERO_PAD_COUNT - 1 ));
	done;

	#Output in desired bit order.

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

if [ $NEWLINE_SUFFIX_OUTPUT -eq 1 ]; then
	printf "\n";
fi

exit 0;
