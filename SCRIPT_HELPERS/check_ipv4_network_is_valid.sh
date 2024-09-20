#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.\n">&2; exit 4; fi

DEP_SCRIPT_PATH_VLAIDATE_IPV4_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";

if [ ! -x $DEP_SCRIPT_PATH_VLAIDATE_IPV4_ADDRESS ]; then
	echo "$0: dependency \"$DEP_SCRIPT_PATH_VLAIDATE_IPV4_ADDRESS\" is missing or is not executable.\n">&2
	exit 3;
fi

print_usage_then_exit () {
	printf "Usage: $0 <arguments>\n">&2;
	printf " --network X.X.X.X/Y (where X is 0-255, and Y is 1-32)\n">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

ADDRESS="";

while true; do
	case $1 in
		--network)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				ADDRESS=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "Unrecognised argument $1. ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z "$ADDRESS" ]; then
	printf "\nMissing --address. ">&2;
	print_usage_then_exit;
fi

NETWORK_ADDRESS=$(echo "$ADDRESS" | cut -d '/' -f 1);

if [ "$NETWORK_ADDRESS" = "$ADDRESS" ]; then
	#does not contain /
	printf "$0; the network does not match the IPV4 CIDR notation (X.X.X.X/Y where X is 0-255, and Y is 1-32) \n">&2;
	exit 1;
fi

$DEP_SCRIPT_PATH_VLAIDATE_IPV4_ADDRESS --address "$NETWORK_ADDRESS"
case $? in
	0) ;;
	1) printf "$0: you have provided an invalid ip address. It must be in the form X.X.X.X, where X is 0-255\n">&2 exit 1; ;;
	*) printf "$0: dependency: \"$DEP_SCRIPT_PATH_VLAIDATE_IPV4_ADDRESS\" produced a failure exit code.\n">&2 exit 3; ;;
esac

CIDR_MASK=$(echo "$ADDRESS" | cut -d '/' -f 2);

if [ -z "$(echo "$CIDR_MASK" | grep -P '[0-9]+')" ]; then
	printf "$0; the CIDR/Network mask is not a number.\n">&2;
	exit 1;
fi

if [ "$CIDR_MASK" -lt 1 ]; then
	printf "$0; the CIDR/Network mask cannot be less than 1.\n">&2;
	exit 1;
fi

if [ "$CIDR_MASK" -gt 32 ]; then
	printf "$0; the CIDR/Network mask cannot be greater than 32.\n">&2;
	exit 1;
fi

exit 0;
