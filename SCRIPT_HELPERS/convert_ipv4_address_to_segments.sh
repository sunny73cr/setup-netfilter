#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS\" is missing or is not executable.">&2;
	exit 3;
fi

print_description() {
	printf "A program that splits an IPV4 Address into its' segments.\n">&2;
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
	printf " Required: --address X.X.X.X (where X is 0-255)\n">&2;
	printf "  The IPV4 Address to split.\n">&2;
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
		echo "\nMissing --address. ">&2;
		print_usage_then_exit;
	fi

	$DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS" --address "$ADDRESS"
	case $? in
		0) ;;
		1) printf "\nInvalid --address. ">&2; print_usage_then_exit; ;;
		*) printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS\" produced a failure exit code.">&2; exit 3; ;;
	esac
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

IPV4_ADDRESS_SEGMENT_1=$(echo "$ADDRESS" | cut -d '.' -f 1);
IPV4_ADDRESS_SEGMENT_2=$(echo "$ADDRESS" | cut -d '.' -f 2);
IPV4_ADDRESS_SEGMENT_3=$(echo "$ADDRESS" | cut -d '.' -f 3);
IPV4_ADDRESS_SEGMENT_4=$(echo "$ADDRESS" | cut -d '.' -f 4);

printf "$IPV4_ADDRESS_SEGMENT_1\n";
printf "$IPV4_ADDRESS_SEGMENT_2\n";
printf "$IPV4_ADDRESS_SEGMENT_3\n";
printf "$IPV4_ADDRESS_SEGMENT_4\n";

exit 0;
