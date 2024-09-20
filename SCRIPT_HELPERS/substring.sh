#!/bin/sh

print_usage_then_exit () {
	echo "Usage: $0 --input <string> --start-idx <number> --length <number>">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

INPUT="";
START_IDX="";
LENGTH="";

while true; do
	case "$1" in
		--input)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -E '^-')" != "" ]; then
				print_usage_then_exit;
			else
				INPUT=$2;
				shift 2;
			fi
		;;
		--start-idx)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -E '^-')" != "" ]; then
				print_usage_then_exit;
			else
				START_IDX=$2;
				shift 2;
			fi
		;;
		--length)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -E '^-')" != "" ]; then
				print_usage_then_exit;
			else
				LENGTH=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "Unrecognised argument - ">&2; print_usage_then_exit; ;;
	esac
done

if [ "$(echo $START_IDX | grep -E '[-]{0,1}0|[1-9]{1,10}[0-9]{0,10}')" = "" ]; then
	echo "$0; the start index must be a number.">&2;
	exit 2;
fi

INPUT_LENGTH=${#INPUT};

if [ $START_IDX -lt 0 ] || [ $START_IDX -gt $(($INPUT_LENGTH-1)) ]; then
	echo "$0; start index out of bounds.">&2;
	exit 2;
fi

if [ "$(echo $LENGTH | grep -P '[-]{0,1}0|[1-9]{1,10}[0-9]{0,10}')" = "" ]; then
	echo "$0; the length must be a number.">&2;
	exit 2;
fi

START_IDX_PLUS_ONE=$(($START_IDX+1));

SUBSTRING_LENGTH=$(($START_IDX_PLUS_ONE+$LENGTH));

if [ $SUBSTRING_LENGTH -gt $INPUT_LENGTH ]; then
	echo "$0; the substring is too long.">&2;
	exit 2;
fi

SUBSTRING=$(echo $INPUT | awk \
-v start_idx=$START_IDX_PLUS_ONE \
-v len=$LENGTH \
-- '{ string=substr($0, start_idx, len); print string; }' \
);

echo "$SUBSTRING";

exit 0;
