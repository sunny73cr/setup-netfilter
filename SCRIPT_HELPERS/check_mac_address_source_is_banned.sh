#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID ]; then
	printf "$0: dependency \"$DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_BROADCAST="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_broadcast.sh";

if [ ! -x $DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_BROADCAST ]; then
	printf "$0: dependency \"$DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_BROADCAST\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_MULTICAST="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_multicast.sh";

if [ ! -x $DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_MULTICAST ]; then
	printf "$0: dependency \"$DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_MULTICAST\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_description() {
	printf "A program that confirms or denies if a MAC address is banned as a source.\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "printf\n">&2;
	printf "echo\n">&2;
	printf "$DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID\n">&2;
	printf "$DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_BROADCAST\n">&2;
	printf "$DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_MULTICAST\n">&2;
	printf "\n">&2;
}

print_dependencies_then_exit() {
	print_dependencies;
	exit 2;
}

if [ "$1" = "-d" ]; then print_dependencies_then_exit; fi

print_usage() {
	printf "Flags used by themselves: \n">&2;
	printf " -e (prints an explanation of the functions' purpose) (exit code 2)\n">&2
	printf " -h (prints an explanation of the functions' available parameters, and their effect) (exit code 2)\n">&2;
	printf " -d (prints the functions' dependencies: newline delimited list) (exit code 2)\n">&2;
	printf " -ehd (prints the above three) (exit code 2)\n">&2;
	printf "\n">&2;
	printf "Parameters:\n">&2;
	printf "\n">&2;
	printf " Required: --address XX:XX:XX:XX:XX:XX (where X is 0-9, a-f, A-F; hexadecimal)\n">&2;
	printf "  The MAC address to check.\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf "  Presence of this flag causes the program to skip validating inputs (if you know they are valid).\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validate\n">&2;
	printf "  Presence of this flag causes the program to exit after validating inputs.\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
ADDRESS="";

#FLAGS:
SKIP_VALIDATION=0;
ONLY_VALIDATE=0;

while true; do
	case $1 in
		#Approach to parsing arguments:
		#If the length of 'all arguments' is less than 2 (shift reduces this number),
		#since this is an argument parameter and requires a value; the program cannot continue.
		#Else, if the argument was provided, and its 'value' is empty; the program cannot continue.
		#Else, assign the argument, and shift 2 (both the argument indicator and its value / move next)

		--address)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				ADDRESS=$2;
				shift 2;
			fi
		;;

		#Approach to parsing flags:
		#If the flag was provided, toggle on its value; then move next
		#Or shift 1 / remove the flag from the list

		--skip-validation)
			SKIP_VALIDATION=1;
			shift 1;
		;;

		--only-validate)
			ONLY_VALIDATE=1;
			shift 1;
		;;

		#Handle the case of 'end' of arg parsing; where all flags are shifted from the list,
		#or the program was called without any parameters. exit the arg parsing loop.
		"") break; ;;

		#Handle the case where an argument or flag was called that the program does not recognise.
		#This should prefix the 'usage' text with the reason the program failed.
		#The 'Standard Error' file descriptor is used to separate failure output or log messages from actual program output.
		*) printf "\nUnrecognised argument $1. ">&2; print_usage_then_exit; ;;

	esac
done;

if [ $SKIP_VALIDATION -eq 0 ]; then
	if [ -z "$ADDRESS" ]; then
		printf "\nMissing --address. ">&2;
		print_usage_then_exit;
	fi

	$DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID --address $ADDRESS;
	case $? in
		0) ;;
		1) printf "\nInvalid --address. ">&2; print_usage_then_exit; ;;
		*) printf "$0: dependency \"DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_VALID\" produced a failure exit code ($?).\n">&2; exit 3; ;;
	esac
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

$DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_BROADCAST --address $ADDRESS;
case $? in
	1) ;;
	0) printf "\nMAC Address is banned as a source. ">&2; exit 0; ;;
	*) printf "$0: dependency \"DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_BROADCAST\" produced a failure exit code ($?).\n">&2; exit 3; ;;
esac

$DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_MULTICAST --address $ADDRESS;
case $? in
	1) ;;
	0) printf "\nMAC Address is banned as a source. ">&2; exit 0; ;;
	*) printf "$0: dependency \"DEPENDENCY_PATH_CHECK_MAC_ADDRESS_IS_MULTICAST\" produced a failure exit code ($?).\n">&2; exit 3; ;;
esac

#not banned
exit 1;
