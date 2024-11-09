#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS ]; then
	echo "$0: dependency \"$DEPENCENY_PATH_VALIDATE_IPV4_ADDRESS\" is missing or is not executable.\n">&2
	exit 3;
fi

print_description() {
	printf "A program that confirms if an IPV4 network is valid or not.\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "printf\n">&2;
	printf "echo\n">&2;
	printf "$DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS\n">&2;
	printf "cut\n">&2;
	printf "grep\n">&2;
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
	printf " Required: --network X.X.X.X/Y (where X is 0-255, and Y - 1-32)\n">&2;
	printf "  The network in CIDR form to validate.\n">&2;
	printf "  If the network is not in a valid form, and exit code of 1 is returned.\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf "  Presence of the flag causes the program to skip validating inputs (if you know they are valid).\n">&2;
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
NETWORK="";

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

		--network)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				NETWORK=$2;
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
	if [ -z "$NETWORK" ]; then
		printf "\nMissing --network. ">&2;
		print_usage_then_exit;
	fi
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

NETWORK_ADDRESS=$(echo "$NETWORK" | cut -d '/' -f 1);

$DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS --address "$NETWORK_ADDRESS"
case $? in
	0) ;;
	1) printf "\nInvalid address portion of --network. ">&2 exit 1; ;;
	*) printf "\n$0: dependency \"$DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS\" produced a failure exit code ($?).">&2 exit 3; ;;
esac

CIDR_MASK=$(echo "$NETWORK" | cut -d '/' -f 2);

if [ -z "$(echo "$CIDR_MASK" | grep '[0-9]\{1,2\}')" ]; then
	printf "\n$0: the CIDR/Network mask must be a 1-2 digit number. ">&2;
	exit 1;
fi

if [ "$CIDR_MASK" -lt 1 ]; then
	printf "\n$0: the CIDR/Network mask cannot be less than 1. ">&2;
	exit 1;
fi

if [ "$CIDR_MASK" -gt 32 ]; then
	printf "\n$0: the CIDR/Network mask cannot be greater than 32. ">&2;
	exit 1;
fi

exit 0;
