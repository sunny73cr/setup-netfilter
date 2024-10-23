#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

print_description() {
	printf "A program that converts a signed number into an unsigned number (2's complement, negative into positive).\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "Dependencies:\n">&2;
	printf "printf\n">&2;
	printf "echo\n">&2;
	printf "cut\n">&2;
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
	printf " Required: --number x (where x is -2,417,483,648 to 4,294,967,295)\n">&2;
	printf "  Positive numbers are of little value here, but they are supported.\n">&2;
	printf "  The minimum value is (-)2^31, and the maximum is 2^32.\n">&2;
	printf "\n">&2;
	printf " Optional: --suffix-output-with-newline\n">&2;
	printf "  Attach a newline character to the end of the output.\n">&2;
	printf "  Useful when output is directed to the console.\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf "  Presence of this flag causes the program to skip validating inputs (if you know they are valid.)\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validate\n">&2;
	printf "  Presence of this flag causes the program to exit after validation.\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
NUMBER="";

#FLAGS:
SKIP_VALIDATION=0;
ONLY_VALIDATE=0;
SUFFIX_OUTPUT_WITH_NEWLINE=0;

while true; do
	case $1 in
		#Approach to parsing arguments:
		#If the length of 'all arguments' is less than 2 (shift reduces this number),
		#since this is an argument parameter and requires a value; the program cannot continue.
		#Else, if the argument was provided, and its 'value' is empty; the program cannot continue.
		#Else, assign the argument, and shift 2 (both the argument indicator and its value / move next)

		--number)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				NUMBER=$2;
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

		--suffix-output-with-newline)
			SUFFIX_OUTPUT_WITH_NEWLINE=1;
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
	if [ -z "$NUMBER" ]; then
		printf "\nInvalid --number. ">&2;
		print_usage_then_exit;
	fi

	if [ -z "$(echo $NUMBER | grep '[-]\{0,1\}[1-9][0-9]\{0,31\}')" ]; then
		printf "\nInvalid --number (Must be betwen -2,417,483,648 to 4,294,967,295). ">&2;
		print_usage_then_exit;
	fi

	if [ $NUMBER -lt -2417483648 ]; then
		printf "\nInvalid --number (must be greater than or equal to -2,417,483,648). ">&2;
		print_usage_then_exit;
	fi

	if [ $NUMBER -gt 4294967295 ]; then
		printf "\nInvalid --number (must be less than or equal to 4,294,967,295). ">&2;
		print_usage_then_exit;
	fi
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi;

STRING_LENGTH=${#NUMBER};

#if the number is negative
if [ "$(echo $NUMBER | cut -c 1)" = "-" ]; then
	#return a substring and truncate the sign
	RESULT=$(echo "$NUMBER" | cut -c "2-$STRING_LENGTH");
else
	#the number is positive, return it.
	RESULT=$NUMBER;
fi

printf "$RESULT";

if [ $SUFFIX_OUTPUT_WITH_NEWLINE -eq 1 ]; then
	printf "\n";
fi

exit 0;
