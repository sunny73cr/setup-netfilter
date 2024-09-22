#!/bin/sh

print_usage_then_exit () {
	printf "Usage: $0 <arguments>\n">&2;
	printf " --input string (cannot be empty, indirect upper bound of (2^32)-1, or max of unsigned int32.)\n">&2;
	printf " --start-idx number (cannot be negative, limit of (2^32)-1, or max of unsigned int32.)\n">&2;
	printf " --length number (cannot be below 1, limit of (2^32)-1, or max of unsigned int32.)\n">&2;
	printf "\n">&2;
	printf "Optional: --newline-suffix-output\n">&2;
	printf " Note: this causes the program to output a newline after the result.\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validate\n">&2;
	printf " Note: the program skips validating the arguments (if you know they are valid.)\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validate\n">&2;
	printf " Note: the program exits after validating the arguments.\n">&2;
	printf "\n">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

INPUT="";
START_IDX="";
LENGTH="";
NEWLINE_SUFFIX_OUTUPUT=0;
ONLY_VALIDATE=0;
SKIP_VALIDATE=0;

while true; do
	case "$1" in
		--input)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				INPUT=$2;
				shift 2;
			fi
		;;
		--start-idx)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				START_IDX=$2;
				shift 2;
			fi
		;;
		--length)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				LENGTH=$2;
				shift 2;
			fi
		;;
		--newline-suffix-output)
			NEWLINE_SUFFIX_OUTPUT=1;
			shift 1;
		;;
		--skip-validate)
			SKIP_VALIDATE=1;
			shift 1;
		;;
		--only-validate)
			ONLY_VALIDATE=1;
			shift 1;
		;;
		"") break; ;;
		*) printf "\nUnrecognised argument - ">&2; print_usage_then_exit; ;;
	esac
done

#Why, user?
if [ $SKIP_VALIDATE -eq 1 ] && [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

if [ $SKIP_VALIDATE -eq 0 ]; then
	if [ "$(echo $START_IDX | grep -E '0|[1-9]{1,10}[0-9]{0,10}')" = "" ]; then
		printf "\nInvalid --start-idx. ">&2;
		print_usage_then_exit;
	fi

	if [ $START_IDX -gt 4294967295 ]; then
		printf "\nInvalid --start-idx. ">&2;
		print_usage_then_exit;
	fi

	INPUT_LENGTH=${#INPUT};

	if [ $START_IDX -lt 0 ] || [ $START_IDX -gt $(($INPUT_LENGTH-1)) ]; then
		echo "\nInvalid --start-idx. ">&2;
		print_usage_then_exit;
	fi

	if [ "$(echo $LENGTH | grep -P '[1-9]{1,10}[0-9]{0,10}')" = "" ]; then
		echo "\nInvalid --length. ">&2;
		print_usage_then_exit;
	fi

	if [ $START_IDX -gt 4294967295 ]; then
		printf "\nInvalid --start-idx. ">&2;
		print_usage_then_exit;
	fi

	START_IDX_PLUS_ONE=$(($START_IDX+1));

	SUBSTRING_LENGTH=$(($START_IDX_PLUS_ONE+$LENGTH));

	if [ $SUBSTRING_LENGTH -gt $INPUT_LENGTH ]; then
		printf "\nsubstring is too long. ">&2;
		exit 2;
	fi
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

SUBSTRING=$(echo $INPUT | awk \
-v start_idx=$START_IDX_PLUS_ONE \
-v len=$LENGTH \
-- '{ string=substr($0, start_idx, len); print string; }' \
);
printf "$SUBSTRING";

if [ $NEWLINE_SUFFIX_OUTPUT -eq 1 ]; then
	printf "\n";
fi

exit 0;
