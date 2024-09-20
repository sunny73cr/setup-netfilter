#!/bin/sh

print_usage_then_exit () {
	printf "Usage: $0 <arguments>\n";
	printf " --binary <string> (0's and 1's).\n";
	printf "\n">&2;
	printf " Optional: --input-bit-order (big-endian or little-endian).\n">&2;
	printf " Note: if input-bit-order is omitted, the default is little-endian.\n">&2;
	printf "\n">&2;
	printf " Optional: --output-signed-numbers\n">&2;
	printf " Note: if the output-signed-numbers flag is present, numbers with the highest bit set are output as negative numbers.\n">&2;
	printf " WARNING: this is very likely not what you want, unless the binary is already a length matching a data type, with zero padding if neccessary.\n">&2;
	printf "\n">&2;
	printf " Optional: --newline-suffix-output\n">&2;
	printf " Note: this causes the program to append a newline to the output.\n">&2;
	printf "\n">&2;
	exit 2;
}

BINARY="";
BIT_ORDER="";
OUTPUT_SIGNED_NUMBERS=0;
SKIP_VALIDATE=0;
NEWLINE_SUFFIX_OUTPUT=0;
while true; do
	case $1 in
		--binary)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				BINARY=$2;
				shift 2;
			fi
		;;
		--input-bit-order)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				BIT_ORDER=$2;
				shift 2;
			fi
		;;
		--output-signed-numbers)
			OUTPUT_SIGNED_NUMBERS=1;
			shift 1;
		;;
		--skip-validate)
			SKIP_VALIDATE=1;
			shift 1;
		;;
		--newline-suffix-output)
			NEWLINE_SUFFIX_OUTPUT=1;
			shift 1;
		;;
		"") break; ;;
		*) printf "Unrecognised argument $1. ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z "$BINARY" ]; then
	BINARY=$(dd if=/dev/stdin of=/dev/stdout bs=1 count=32 status=none);

	if [ -z "BINARY" ]; then print_usage_then_exit; fi
fi

if [ $SKIP_VALIDATE -eq 0 ]; then

	if [ "$(echo "$BINARY" | grep -E '^[0|1]{1,32}$')" = "" ]; then
		printf "\nInvalid --binary. ">&2;
		print_usage_then_exit;
	fi

	if [ "$(echo "$BINARY" | grep -E '^[0]{1,32}$')" != "" ]; then
		printf "0";
		if [ $NEWLINE_SUFFIX_OUTPUT -eq 1 ]; then
			printf "\n";
		fi
		exit 0;
	fi
fi

BIT_LENGTH="${#BINARY}";

case "$BIT_ORDER" in
	big-endian)
		OFFSET=1;
		BIT_ORDER=0;
	;;
	""|little-endian)
		OFFSET=$BIT_LENGTH;
		BIT_ORDER=1;
	;;
	*)
		printf "\nInvalid --bit-order. ">&2;
		print_usage_then_exit;
	;;
esac

# RapidTables.come conver binary to decimal calculator:
# https://www.rapidtables.com/convert/number/binary-to-decimal.html
#
# For a binary number with n digits:
# D(n-1) 	= 	d3 d2 d1 d0
# 0110 		=	0  1  1  0
# The decimal number is equal to the sum of binary digits multiplied by their power of 2
# Decimal	=	d0*(2^0) + d1*(2^1) + d2*(2^2) + d3*(d^3)
# Binary	=	0*1	 + 1*2	    + 1*4      + 0*8
#

#if signing output numbers, output a - if the number is negative
if [ $OUTPUT_SIGNED_NUMBERS -eq 1 ]; then
	if [ $BIT_ORDER -eq 1 ]; then
		OFFSET=$(($OFFSET+1));
		if [ "$(echo $BINARY | cut -c 1)" = "1" ]; then
			#negative little endian number
			echo -n '-';
		fi
	else
		OFFSET=$(($OFFSET-1));
		if [ "$(echo $BINARY | cut -c $BIT_LENGTH)" = "1" ]; then
			#negative big endian number
			echo -n '-';
		fi
	fi
fi

CHAR_IDX=1;

TOTAL=0;

BIT="";

while true; do
	BIT=$(echo $BINARY | cut -c "$CHAR_IDX");

	if [ $BIT -eq 1 ]; then
		case $OFFSET in
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

	if [ $CHAR_IDX -eq $BIT_LENGTH ]; then
		break;
	fi

	CHAR_IDX=$(($CHAR_IDX+1));

	if [ $BIT_ORDER -eq 0 ]; then
		OFFSET=$((OFFSET+1));
	else
		OFFSET=$((OFFSET-1));
	fi
done;

printf $TOTAL;

if [ $NEWLINE_SUFFIX_OUTPUT -eq 1 ]; then
	printf "\n";
fi

exit 0;
