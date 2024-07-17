#!/bin/sh

usage () {
	echo "Usage: $0 --name <string>" 1>&2;
	exit 2;
}

NAME="";

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--name )
			NAME="$2";
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

if [ -z "$NAME" ]; then
	echo "$0; you must provide a name (--name <string>).">&2;
	exit 2;
fi

ALL_INTERFACE_DESCRIPTIONS_BRIEF=$(ip -br link show);

INTERFACE_DESCRIPTIONS_FILTERED_BY_NAME=$(echo "$ALL_INTERFACE_DESCRIPTIONS_BRIEF" | grep $NAME);

if [ -n "$INTERFACE_DESCRIPTIONS_FILTERED_BY_NAME" ]; then
	exit 0;
else
	echo "$0; that interface does not exist.">&2;
	exit 2;
fi
