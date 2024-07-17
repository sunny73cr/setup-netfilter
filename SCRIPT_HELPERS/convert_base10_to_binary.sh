#!/bin/sh

DEPENDENCY_SCRIPT_PATH_EXPONENT="./SCRIPT_HELPERS/exponent.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_EXPONENT" ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_EXPONENT\" is missing or is not executable.">&2;
	exit 2;
fi

check_success () {
	if [ "$?" -ne 0 ]; then
		echo "$0; cannot convert base10 to binary">&2;
		exit 3;
	fi
}

usage () {
	echo "Usage: $0 --number <number> --output-bit-order <big-endian|little-endian> --output-bit-length <1-32>">&2;
	exit 2;
}

NUMBER="";
BIT_ORDER="";
BIT_LENGTH="";

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--number)
			NUMBER="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		
		--output-bit-order)
			BIT_ORDER="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		
		--output-bit-length)
			BIT_LENGTH="$2";
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

if [ -z "$NUMBER" ]; then
	echo "$0; you must provide a number">&2;
	exit 2;
fi

if [ -z "$BIT_ORDER" ]; then
	echo "$0; you must provide a bit order.">&2;
	exit 2;
fi

case "$BIT_ORDER" in
	"big-endian") BIT_ORDER="BIG-ENDIAN"; ;;
	"little-endian") BIT_ORDER="LITTLE-ENDIAN"; ;;
	*)
		echo "$0; unrecognised bit order (try '--output-bit-order big-endian' or '--output-bit-order little-endian' without quotes.)">&2;
		exit 2;
	;;
esac

if [ -z "$BIT_LENGTH" ]; then
	echo "$0; you must provide an output bit length (try '--output-bit-length 32' without quotes.)">&2;
	exit 2;
fi

if [ "$BIT_LENGTH" -eq 0 ]; then
	echo "$0; bit length should not be zero.">&2;
	exit 2;
fi

if [ "$BIT_LENGTH" -gt 32 ]; then
	echo "$0; bit length cannot be greater than 32.">&2;
	exit 2;
fi

MAX_FOR_BIT_LENGTH=$($DEPENDENCY_SCRIPT_PATH_EXPONENT --base "2" --exponent $BIT_LENGTH);
check_success

MAX_FOR_BIT_LENGTH_MINUS_ONE=$((MAX_FOR_BIT_LENGTH-1));

if [ "$NUMBER" -gt "$MAX_FOR_BIT_LENGTH_MINUS_ONE" ]; then
	echo "The number exceeds the maximum value ($BIT_LENGTH bits = 0 to $MAX_FOR_BIT_LENGTH_MINUS_ONE)">&2;
	exit 2;
fi

# RapidTables.come convert decimal to binary calculator:
# https://www.rapidtables.com/convert/number/decimal-to-binary.html
# 
# 1. Input divide 2 == the quotient
# 2. Remainder of quotient modulus 2 == the binary digit
# 3. Repeat until the quotient is equal to 0.

RESULT="";

QUOTIENT="$NUMBER";

while true; do
	if [ $QUOTIENT -eq 0 ]; then
		break;
	fi

	RESULT=$RESULT$(($QUOTIENT%2));
	
	QUOTIENT=$(($QUOTIENT/2));
done;

#Zero pad binary output to 8 bits.

BIT_LENGTH_MINUS_ONE=$(($BIT_LENGTH-1));

ZERO_PAD_COUNT=$(( $BIT_LENGTH_MINUS_ONE - ${#RESULT} ));

ZERO="0";

while [ $ZERO_PAD_COUNT -ge 0 ]; do
	ZERO_PAD=$ZERO_PAD$ZERO;
	
	ZERO_PAD_COUNT=$(( ZERO_PAD_COUNT - 1 ));
done;

#Output in desired byte order.

if [ "$BIT_ORDER" = "BIG-ENDIAN" ]; then
	echo -n $RESULT;
	echo -n $ZERO_PAD;
	echo "";
else
	echo -n $ZERO_PAD;
	
	#iterate the binary string in reverse
	#1-based index for awk compatibility
	i=${#RESULT};
	while [ $i -ge 1 ]; do
		BIT=$(echo $RESULT | awk -v var=$i '{ string=substr($0, var, 1); print string; }' );
		
		echo -n $BIT;
		
		i=$(($i-1));
	done;
	
	echo "";
fi
