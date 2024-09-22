#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.\n">&2; exit 4; fi

DEPENDENCY_SCRIPT_PATH_ABSOLUTE="$ENV_SETUP_NFT/SCRIPT_HELPERS/absolute.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_ABSOLUTE ]; then
	echo "$0; dependency: \"$DEPENDENCY_SCRIPT_PATH_ABSOLUTE\" is missing or is not executable.">&2; exit 3;
fi

print_usage_then_exit () {
	printf "Usage: $0 <arguments>\n">&2;
	printf " --base number \n">&2;
	printf " --exponent number \n">&2;
	printf " Optional: --find-root \n">&2;
	printf " Note: this flag causes the program to find the 'exponen-th root' of the base.\n">&2;
	printf " Eg. square root = exponent 2, or cube root = exponent 3.\n">&2;
	printf " The program supports calculating any 'root', or any 'exponent'; though you should be aware:\n">&2;
	printf " It is likely that awk/gawk/mawk uses a floating point math library; and precision is not guaranteed.\n">&2;
	printf " Please be aware that your shell likely only supports 32 bit numbers; and warning you the user\n">&2;
	printf " of an overflow or underflow is not worth computing. Accuracy is therefore not guaranteed.\n">&2;
	printf "">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

BASE="";
EXPONENT="";
FIND_ROOT-0;
NEWLINE_SUFFIX_OUTPUT=0;

while true; do
	case $1 in
		--base)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				BASE=$2;
				shift 2;
			fi
		;;
		--exponent)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				EXPONENT=$2;
				shift 2;
			fi
		;;
		--find-root)
			FIND_ROOT=1;
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

if [ -z "$BASE" ]; then
	echo "\nMissing --base. ">&2;
	print_usage_then_exit;
fi

NUMBER_REGEX="[-]{0,1}[0-9]+";

if [ "$(echo "$BASE" | grep -P $NUMBER_REGEX)" = "" ]; then
	echo "\nInvalid --base. ">&2;
	print_usage_then_exit;
fi

if [ "$(echo "$EXPONENT" | grep -P $NUMBER_REGEX)" = "" ]; then
	echo "\nInvalid --base. ">&2;
	print_usage_then_exit;
fi

#If exponent is zero, the result is always 1.
#If exponent is one, the result is always the base.
#If the user wishes to find the 'nth root', inverse the exponent and exponentiate
#Else, exponentiate.

#Note: depends on awk/mawk/gawk for floating-point number support, and additionally for its' math library.

if [ $EXPONENT -eq 0 ]; then
	printf "1";

elif [ $EXPONENT -eq 1 ]; then
	printf "$BASE";

elif [ $FIND_ROOT -eq 1 ]; then
	EXPONENT_ABSOLUTE=$($DEPENDENCY_SCRIPT_PATH_ABSOLUTE --number "$EXPONENT");
	case $? in
		0) ;;
		*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_ABSOLUTE\" produced a failure exit code."; exit 3; ;;
	esac

	EXPONENT_INVERSE=$(awk -v exponent=$EXPONENT_ABSOLUTE 'BEGIN{ print 1 / exponent }');

	ROOT=$(awk -v base=$BASE -v exponent=$EXPONENT_INVERSE 'BEGIN{ print base ^ exponent }');

	printf "$ROOT";

else
	EXPONENTIATED=$(awk -v base=$BASE -v exponent=$EXPONENT 'BEGIN{print base ^ exponent}');

	printf "$EXPONENTIATED";

fi

if [ $NEWLINE_SUFFIX_OUTPUT -eq 1 ]; then
	printf '\n';
fi

exit 0;
