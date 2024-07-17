#!/bin/sh

usage () {
	echo "Usage: $0 --network <X.X.X.X/X>">&2;
	exit 2;
}

ADDRESS="";

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--network )
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
	echo "$0; you must provide an IPV4 address (--network <X.X.X.X/X>).">&2;
	exit 2;
fi

NETWORK_ADDRESS=$(echo "$ADDRESS" | cut -d '/' -f 1);

if [ "$NETWORK_ADDRESS" = "$ADDRESS" ]; then
	#does not contain /
	echo "$0; the network does not match the IPV4 CIDR notation (X.X.X.X/X)">&2;
	exit 2;
fi

IS_ADDRESS_VALID=$($DEP_SCRIPT_PATH_VLAIDATE_IPV4_ADDRESS --address "$NETWORK_ADDRESS");
check_success;

CIDR_MASK=$(echo "$ADDRESS" | cut -d '/' -f 2);

if [ -z "$(echo "$CIDR_MASK" | grep -P '[0-9]+')" ]; then
	echo "$0; the CIDR/Network mask is not a number.">&2;
	exit 2;
fi

if [ "$CIDR_MASK" -lt 0 ]; then
	echo "$0; the CIDR/Network mask cannot be less than 0.">&2;
	exit 2;
fi

if [ "$CIDR_MASK" -gt 32 ]; then
	echo "$0; the CIDR/Network mask cannot be greater than 32.">&2;
	exit 2;
fi

exit 0;
