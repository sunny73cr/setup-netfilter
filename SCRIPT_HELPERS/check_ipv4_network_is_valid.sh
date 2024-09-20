#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: Set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.">&2; exit 4; fi

print_usage_then_exit () {
	echo "Usage: $0 --network <X.X.X.X/X>">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

ADDRESS="";

while true; do
	case "$1" in
		--network)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -E '^-')" != "" ]; then
				print_usage_then_exit;
			else
				ADDRESS=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "Unrecognised argument - ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z "$ADDRESS" ]; then
	echo "$0; you must provide an IPV4 network in CIDR form (X.X.X.X/Y, where X is 0-255, and Y is 1-32).">&2;
	exit 1;
fi

NETWORK_ADDRESS=$(echo "$ADDRESS" | cut -d '/' -f 1);

if [ "$NETWORK_ADDRESS" = "$ADDRESS" ]; then
	#does not contain /
	echo "$0; the network does not match the IPV4 CIDR notation (X.X.X.X/X)">&2;
	exit 1;
fi

$DEP_SCRIPT_PATH_VLAIDATE_IPV4_ADDRESS --address "$NETWORK_ADDRESS"
case $? in
	0) ;;
	1) printf "$0: you have provided an invalid ip address. It must be in the form X.X.X.X, where X is 0-255">&2 exit 1; ;;
	*) printf "$0: dependency script path failure: \"\" produced a failure exit code.">&2 exit 3; ;;
esac

CIDR_MASK=$(echo "$ADDRESS" | cut -d '/' -f 2);

if [ -z "$(echo "$CIDR_MASK" | grep -P '[0-9]+')" ]; then
	echo "$0; the CIDR/Network mask is not a number.">&2;
	exit 1;
fi

if [ "$CIDR_MASK" -lt 1 ]; then
	echo "$0; the CIDR/Network mask cannot be less than 1.">&2;
	exit 1;
fi

if [ "$CIDR_MASK" -gt 32 ]; then
	echo "$0; the CIDR/Network mask cannot be greater than 32.">&2;
	exit 1;
fi

exit 0;
