#!/bin/sh

print_usage_then_exit () {
	echo "Usage: $0 <arguments>">&2;
	echo "--number <number>">&2;
	echo "">&2;
	echo "Developer / Special use flags:">&2;
	echo "--only-validate">&2;
	echo "Exit after performing validation">&2;
	echo "">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

NUMBER="";
ONLY_VALIDATE=0;

while true; do
	case "$1" in
		--number)
			#not enough arguments
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			#valie is empty
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -G '^-')" != "" ]; then
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
		"") break; ;;
		*) printf "Unrecognised argument - ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z "$NUMBER" ]; then
	echo "$0; you must provide a number.">&2;
	exit 2;
fi

if [ "$(echo "$NUMBER" | grep -E '[-]{0,1}[0-9]+')" = "" ]; then
	echo "$0; the string you provided is not a number.">&2;
	exit 2;
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi;

STRING_LENGTH=${#NUMBER};

#if the number is negative
if [ "$(echo $NUMBER | cut -c 1)" = "-" ]; then
	#return a substring and truncate the sign
	RESULT=$(echo $NUMBER | cut -c "2-$STRING_LENGTH");
else
	#the number is positive, return it.
	RESULT=$NUMBER;
fi

echo $RESULT;

exit 0;
