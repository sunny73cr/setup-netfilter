#!/bin/sh

DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS="./SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS" ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS\" is missing or is not executable.">&2;
	exit 3;
fi

check_success () {
	if [ "$?" -ne 0 ]; then
		echo "$0; cannot convert the IPV4 address to segments.">&2;
		exit 3;
	fi
}

usage () {
	echo "Usage: $0 --address <string>">&2;
	exit 2;
}

ADDRESS="";

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--address )
			ADDRESS="$2";
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

if [ -z "$ADDRESS" ]; then
	echo "$0; you must provide an IPV4 address (--address <string>).">&2;
	exit 2;
fi

IS_IPV4_ADDRESS_VALID=$("$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS" --address "$ADDRESS");
check_success

IPV4_ADDRESS_SEGMENT_1=$(echo "$ADDRESS" | cut -d '.' -f 1);
IPV4_ADDRESS_SEGMENT_2=$(echo "$ADDRESS" | cut -d '.' -f 2);
IPV4_ADDRESS_SEGMENT_3=$(echo "$ADDRESS" | cut -d '.' -f 3);
IPV4_ADDRESS_SEGMENT_4=$(echo "$ADDRESS" | cut -d '.' -f 4);

echo $IPV4_ADDRESS_SEGMENT_1;
echo $IPV4_ADDRESS_SEGMENT_2;
echo $IPV4_ADDRESS_SEGMENT_3;
echo $IPV4_ADDRESS_SEGMENT_4;
exit 0;
