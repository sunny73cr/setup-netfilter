#!/bin/sh

usage () {
	echo "Usage: $0 --input <string> --start-idx <number> --length <number>">&2;
	exit 2;
}

INPUT="";
START_IDX="";
LENGTH="";

while true; do
	case "$1" in
		--input)
			INPUT="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--start-idx)
			START_IDX="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--length)
			LENGTH="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		"") break; ;;
		*)
			echo "">&2;
			echo "Unrecognised option: $1 $2">&2;
			usage;
		;;
	esac
done

if [ -z "$INPUT" ]; then
	echo "$0; you must provide an input string.">&2;
	exit 2;
fi

INPUT_LENGTH="${#INPUT}";

NUMBER_REGEX='0|[1-9]*[0-9]+';

if [ -z "$START_IDX" ]; then
	echo "$0; you must provide a start idx.">&2;
	exit 2;
fi

if [ "$(echo "$START_IDX" | grep -P $NUMBER_REGEX)" = "" ]; then
	echo "$0; the start index must be a number.">&2;
	exit 2;
fi

if [ "$START_IDX" -lt 0 ] || [ "$START_IDX" -gt "$(($INPUT_LENGTH-1))" ]; then
	echo "$0; start index out of bounds.">&2;
	exit 2;
fi

if [ -z "$LENGTH" ]; then
	echo "$0; you must provide a length.">&2;
	exit 2;
fi

if [ "$(echo "$LENGTH" | grep -P $NUMBER_REGEX)" = "" ]; then
	echo "$0; the length must be a number.">&2;
	exit 2;
fi

START_IDX_PLUS_ONE=$(($START_IDX+1));

REMAINING_LENGTH=$(($INPUT_LENGTH-$START_IDX_PLUS_ONE));

if [ "$LENGTH" -gt "$REMAINING_LENGTH" ]; then
	echo "$0; the length is too long when beginning at that index.">&2;
	exit 2;
fi

SUBSTRING=$(echo "$INPUT" | awk \
-v start_idx="$START_IDX_PLUS_ONE" \
-v len="$LENGTH" \
-- '{ string=substr($0, start_idx, len); print string; }' \
);

echo "$SUBSTRING";
exit 0;
