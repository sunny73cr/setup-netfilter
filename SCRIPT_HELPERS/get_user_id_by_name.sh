#!/bin/sh

usage () {
	echo "Usage: $0 --name <string>">&2;
	exit 2;
}

NAME="";

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--name )
			NAME="$2";
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

if [ -z $NAME ]; then
	echo "$0; you must provide a user name (--name <string>)">&2;
	exit 2;
fi

USER_ID="$(sudo cat /etc/passwd | grep -P "^$NAME:" | cut -d ":" -f 3)";

echo $USER_ID;

exit 0;
