#!/bin/sh

print_usage_then_exit () {
	printf "Usage: $0 <arguments>\n">&2;
	printf " --number <number>\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validate\n">&2;
	printf " Note: causes the program to exit after performing validation\n">&2;
	printf "\n">&2;
	printf " Optional: --newline-suffix-output\n">&2;
	printf " Note: this appends a newline to the output.\n">&2;
	printf "\n">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

NUMBER="";
ONLY_VALIDATE=0;
NEWLINE_SUFFIX_OUTPUT=0;

while true; do
	case "$1" in
		--number)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#value is empty
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				NUMBER=$2;
				shift 2;
			fi
		;;
		--only-validate)
			ONLY_VALIDATE=1;
			shift 1;
		;;
		--newline-suffix-output)
			NEWLINE_SUFFIX_OUTPUT=1;
			shift 1;
		;;
		"") break; ;;
		*) printf "Unrecognised argument - ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z "$NUMBER" ]; then
	printf "$0; you must provide a number.\n">&2;
	exit 2;
fi

if [ "$(echo "$NUMBER" | grep -E '[-]{0,1}[0-9]{1,64}')" = "" ]; then
	printf "$0: you must provide a positive or negative number up to 64 digits in length (including 0).\n">&2;
	exit 2;
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi;

STRING_LENGTH=${#NUMBER};

#if the number is negative
if [ "$(echo "$NUMBER" | cut -c 1)" = "-" ]; then
	#return a substring and truncate the sign
	RESULT=$(echo "$NUMBER" | cut -c "2-$STRING_LENGTH");
else
	#the number is positive, return it.
	RESULT=$NUMBER;
fi

printf "$RESULT";

if [ $NEWLINE_SUFFIX_OUTPUT -eq 1 ]; then
	printf "\n";
fi

exit 0;
