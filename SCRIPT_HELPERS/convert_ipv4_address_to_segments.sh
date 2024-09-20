#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.\n">&2; exit 4; fi

DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS\" is missing or is not executable.">&2;
	exit 3;
fi

print_usage_then_exit () {
	echo "Usage: $0 --address <string>">&2;
	exit 2;
}

ADDRESS="";

if [ "$1" = "" ]; then print_usage_then_exit; fi

while true; do
	case "$1" in
		--address )
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
	echo "\nMissing --address. ">&2;
	exit 2;
fi

$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS" --address "$ADDRESS"
case $? in
	0) ;;
	1) printf "\nInvalid --address. "; print_usage_then_exit; ;;
	*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_VALIDATE_IPV4_ADDRESS\" produced a failure exit code.">&2
esac

IPV4_ADDRESS_SEGMENT_1=$(echo "$ADDRESS" | cut -d '.' -f 1);
IPV4_ADDRESS_SEGMENT_2=$(echo "$ADDRESS" | cut -d '.' -f 2);
IPV4_ADDRESS_SEGMENT_3=$(echo "$ADDRESS" | cut -d '.' -f 3);
IPV4_ADDRESS_SEGMENT_4=$(echo "$ADDRESS" | cut -d '.' -f 4);

printf "$IPV4_ADDRESS_SEGMENT_1\n";
printf "$IPV4_ADDRESS_SEGMENT_2\n";
printf "$IPV4_ADDRESS_SEGMENT_3\n";
printf "$IPV4_ADDRESS_SEGMENT_4\n";

exit 0;

