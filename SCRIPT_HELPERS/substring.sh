#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

print_description() {
	printf "A program that extracts a subset of characters from the input string.\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "printf\n">&2;
	printf "echo\n">&2;
	printf "grep\n">&2;
	printf "awk\n">&2;
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
	printf " Required: --input x (cannot be empty, indirect upper bound of (2^32)-1, or max of unsigned int32.)\n">&2;
	printf "  The input string to take a subset of characters from.\n">&2;
	printf "\n">&2;
	printf " Required: --start-idx x (cannot be negative, limit of (2^32)-1, or max of unsigned int32.)\n">&2;
	printf "  The index to begin cutting a substring out of --input\n">&2;
	printf "\n">&2;
	printf " Required: --length x (cannot be below 1, limit of (2^32)-1, or max of unsigned int32.)\n">&2;
	printf "  The length of the substring within --input\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf "  Presence of this flag causes the program to skip validating inputs (if you know they are valid.)\n">&2;
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
INPUT="";
START_IDX="";
LENGTH="";

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

		--input)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				INPUT=$2;
				shift 2;
			fi
		;;

		--start-idx)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				START_IDX=$2;
				shift 2;
			fi
		;;

		--length)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				LENGTH=$2;
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
	if [ "$(echo $START_IDX | grep '0\|[1-9]\{1,10\}[0-9]\{0,9\}')" = "" ]; then
		printf "\nInvalid --start-idx (must be a 1-10 digit number). ">&2;
		print_usage_then_exit;
	fi

	if [ $START_IDX -lt 0 ]; then
		printf "\nInvalid --start-idx (cannot be less than 0). ">&2;
		print_usage_then_exit;
	fi

	if [ $START_IDX -gt 4294967295 ]; then
		printf "\nInvalid --start-idx (cannot be greater than 4,294,967,295). ">&2;
		print_usage_then_exit;
	fi

	if [ "$(echo $LENGTH | grep '[1-9]\{1,10\}[0-9]\{0,9\}')" = "" ]; then
		echo "\nInvalid --length (must be a 1-10 digit number). ">&2;
		print_usage_then_exit;
	fi

	if [ $LENGTH -lt 1 ]; then
		printf "\nInvalid --length (cannot be less than 1). ">&2;
		print_usage_then_exit;
	fi

	if [ $LENGTH -gt 4294967295 ]; then
		printf "\nInvalid --length (cannot be greater than 4,294,967,295). ">&2;
		print_usage_then_exit;
	fi

	INPUT_LENGTH=${#INPUT};

	if [ $START_IDX -lt 0 ]; then
		printf "\nInvalid --start-idx (beyond lowerr bound). ">&2;
		print_usage_then_exit;
	fi

	if [ $START_IDX -gt $(($INPUT_LENGTH-1)) ]; then
		printf "\nInvalid --start-idx (beyond upper bound). ">&2;
		print_usage_then_exit;
	fi

	if [ $(($START_IDX+$LENGTH)) -gt $INPUT_LENGTH ]; then
		printf "\nSubstring is too long. ">&2;
		print_usage_then_exit;
	fi
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

SUBSTRING=$(echo $INPUT | awk -v start_idx=$(($START_IDX+1)) -v len=$LENGTH -- '{ string=substr($0, start_idx, len); print string; }');

printf "$SUBSTRING";

if [ $NEWLINE_SUFFIX_OUTPUT -eq 1 ]; then
	printf "\n";
fi

exit 0;
