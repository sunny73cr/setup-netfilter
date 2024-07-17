#!/bin/sh

DEPENDENCY_SCRIPT_PATH_ABSOLUTE="./SCRIPT_HELPERS/absolute.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_ABSOLUTE" ]; then
	echo "$0; dependency script failure: \"$DEPENDENCY_SCRIPT_PATH_ABSOLUTE\" is missing or is not executable.">&2;
	exit 3;
fi

check_success () {
	if [ $? -ne 0 ]; then
		echo "$0; cannot exponentiate the number.">&2;
		exit 3;
	fi
}

usage () {
	echo "Usage: $0 --base <number> --exponent <number>">&2;
	exit 2;
}

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--base)
			BASE="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--exponent)
			EXPONENT="$2";
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

if [ -z "$BASE" ]; then
	echo "$0; you must provide a base to raise exponentially.">&2;
	exit 2;
fi

NUMBER_REGEX="[-]{0,1}[0-9]+";

if [ "$(echo "$BASE" | grep -P $NUMBER_REGEX)" = "" ]; then
	echo "$0; the base must be a number.">&2;
	exit 2;
fi

if [ "$(echo "$EXPONENT" | grep -P $NUMBER_REGEX)" = "" ]; then
	echo "$0; the exponent must be a number">&2;
	exit 2;
fi

SHOULD_RETURN_INVERSE="false";

if [ "$EXPONENT" -lt 0 ]; then
	SHOULD_RETURN_INVERSE="true";

	EXPONENT_ABSOLUTE=$($DEPENDENCY_SCRIPT_PATH_ABSOLUTE --number "$EXPONENT");

	check_success

	EXPONENT=$EXPONENT_ABSOLUTE;
fi

if [ "$EXPONENT" -eq 0 ]; then
	echo 1;
	exit 0;
fi

TOTAL=1;
ITER=1;
while true; do
	TOTAL=$(($TOTAL*$BASE));

	ITER=$(($ITER+1));

	if [ $ITER -gt $EXPONENT ]; then
		break;
	fi
done

if [ "$SHOULD_RETURN_INVERSE" = "true" ]; then
	INVERSE_EXPONENTATION=$(awk -v total=$TOTAL 'BEGIN{print 1 / total}');
	echo $INVERSE_EXPONENTATION;
	exit 0;
else
	echo $TOTAL;
	exit 0;
fi
