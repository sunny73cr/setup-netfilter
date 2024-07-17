#!/bin/sh

usage () {
	echo "Usage: $0 --number <number>">&2;
	exit 2;
}

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--number)
			NUMBER="$2";
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
	echo "$0; you must provide a number.">&2;
	exit 2;
fi

if [ "$(echo "$NUMBER" | grep -P '[-]{0,1}[0-9]+')" = "" ]; then
	echo "$0; the string you provided is not a number.">&2;
	exit 2;
fi

STRING_LENGTH=${#NUMBER};

if [ "$(echo $NUMBER | cut -c 1)" = "-" ]; then
	RESULT=$(echo $NUMBER | cut -c "2-$STRING_LENGTH");
else
	RESULT=$NUMBER;
fi

echo $RESULT;
exit 0;
