#!/bin/sh

usage () {
	echo "Usage: $0 --binary <string> --input-bit-order <big-endian|little-endian>">&2;
	exit 2;
}

BINARY="";
BIT_ORDER="";

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--binary)
			BINARY="$2";
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		
		--input-bit-order)
			BIT_ORDER="$2";
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

if [ -z "$BINARY" ]; then
	echo "$0; you must provide a binary string">&2;
	exit 2;
fi

BINARY_REGEX='[0|1]{1,32}';

if [ "$(echo "$BINARY" | grep -P $BINARY_REGEX)" = "" ]; then
	echo "$0; you must provide a binary string (1-32 characters of 1's or 0's)">&2;
	exit 2;
fi

if [ "$BINARY" = "00000000" ]; then
	echo "0";
	exit 0;
fi

if [ -z "$BIT_ORDER" ]; then
	echo "$0; you must provide an input bit-order. (try '--input-bit-order big-endian' or '--input-bit-order little-endian' without quotes.)">&2;
	exit 2;
fi

case "$BIT_ORDER" in
	big-endian) ;;
	little-endian) ;;
	*)
		echo "$0; unrecognised bit-order. (try '--input-bit-order big-endian' or '--input-bit-order little-endian' without quotes.)">&2;
		exit 2;
	;;
esac

# RapidTables.come conver binary to decimal calculator:
# https://www.rapidtables.com/convert/number/binary-to-decimal.html
#
# For a binary number with n digits:
# D(n-1) 	= 	d3 d2 d1 d0
# 0110 		=	0  1  1  0
# The decimal number is equal to the sum of binary digits times their power of 2
# Decimal	=	d0*(2^0) + d1*(2^1) + d2*(2^2) + d3*(d^3)
# Binary	=	0*1	 + 1*2	    + 1*4      + 0*8
#
# If the supplied number is 'big-endian', then the 
#
#

BIT_LENGTH="${#BINARY}";

if [ "$BIT_LENGTH" -gt 32 ]; then
	echo "$0; the maximum length is 32-bits.">&2;
	exit 2;
fi

CHAR_IDX=1;

case "$BIT_ORDER" in
	big-endian) OFFSET=1; ;;
	little-endian) OFFSET=$BIT_LENGTH; ;;
esac

TOTAL=0;

while true; do	
	BIT=$(echo $BINARY | cut -c "$CHAR_IDX");
	
	if [ "$BIT" -eq 1 ]; then
		case "$OFFSET" in
			1) TOTAL=$((TOTAL+1)); ;;
			2) TOTAL=$((TOTAL+2)); ;;
			3) TOTAL=$((TOTAL+4)); ;;
			4) TOTAL=$((TOTAL+8)); ;;
			5) TOTAL=$((TOTAL+16)); ;;
			6) TOTAL=$((TOTAL+32)); ;;
			7) TOTAL=$((TOTAL+64)); ;;
			8) TOTAL=$((TOTAL+128)); ;;
			9) TOTAL=$((TOTAL+256)); ;;
			10) TOTAL=$((TOTAL+512)); ;;
			11) TOTAL=$((TOTAL+1024)); ;;
			12) TOTAL=$((TOTAL+2048)); ;;
			13) TOTAL=$((TOTAL+4096)); ;;
			14) TOTAL=$((TOTAL+8192)); ;;
			15) TOTAL=$((TOTAL+16384)); ;;
			16) TOTAL=$((TOTAL+32768)); ;;
			17) TOTAL=$((TOTAL+65536)); ;;
			18) TOTAL=$((TOTAL+131072)); ;;
			19) TOTAL=$((TOTAL+262144)); ;;
			20) TOTAL=$((TOTAL+524288)); ;;
			21) TOTAL=$((TOTAL+1048576)); ;;
			22) TOTAL=$((TOTAL+2097152)); ;;
			23) TOTAL=$((TOTAL+4194304)); ;;
			24) TOTAL=$((TOTAL+8388608)); ;;
			25) TOTAL=$((TOTAL+16777216)); ;;
			26) TOTAL=$((TOTAL+33554432)); ;;
			27) TOTAL=$((TOTAL+67108864)); ;;
			28) TOTAL=$((TOTAL+134217728)); ;;
			29) TOTAL=$((TOTAL+268435456)); ;;
			30) TOTAL=$((TOTAL+536870912)); ;;
			31) TOTAL=$((TOTAL+1073741824)); ;;
			32) TOTAL=$((TOTAL+2147483648)); ;;
		esac
	fi
	
	if [ "$BIT_ORDER" = "big-endian" ]; then
		OFFSET=$((OFFSET+1));
	else
		OFFSET=$((OFFSET-1));
	fi
	
	CHAR_IDX=$(($CHAR_IDX+1));
	
	if [ "$CHAR_IDX" -gt "$BIT_LENGTH" ]; then
		break;
	fi
done;

echo $TOTAL;
exit 0;
