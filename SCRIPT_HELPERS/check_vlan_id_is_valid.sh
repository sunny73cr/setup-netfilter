#!/bin/sh

usage () {
	echo "Usage: $0 --id <string>">&2;
	exit 2;
}

ID="";

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--id )
			ID="$2";
			#if not enough arguments
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		"" ) break; ;;
		*)
			echo "">&2;
			echo "Unrecognised option: $1 $2">&2;
			usage;
		;;
	esac
done

if [ -z "$ID" ]; then
	echo "$0; you must provide an id (--id <number>).">&2;
	exit 2;
fi

if [ "$ID" -lt 1 ]; then
	echo "$0; the port is too low.">&2;
	exit 2;
fi

if [ "$ID" -gt 4096 ]; then
	echo "$0; the port is too high.">&2;
	exit 2;
fi

exit 0;
