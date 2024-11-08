#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the absolute path of the setup-netfilter directory first.\n">&2; exit 4; fi

DEPENDENCY_SCRIPT_PATH_ABSOLUTE="$ENV_SETUP_NFT/SCRIPT_HELPERS/absolute.sh";

if [ ! -x $DEPENDENCY_SCRIPT_PATH_ABSOLUTE ]; then
	echo "$0; dependency: \"$DEPENDENCY_SCRIPT_PATH_ABSOLUTE\" is missing or is not executable.">&2; exit 3;
fi

print_usage_then_exit () {
	printf "Usage: $0 <arguments>\n">&2;
	printf " --base number (decimal/floating-point numbers supported)\n">&2;
	printf " --exponent number (decimal/floating-point numbers supported)\n">&2;
	printf "\n">&2;
	printf " Optional: --find-root \n">&2;
	printf " Note: this flag causes the program to find the 'exponen-th root' of the base.\n">&2;
	printf " Eg. square root = exponent 2, or cube root = exponent 3.\n">&2;
	printf " The program supports calculating any 'root', or any 'exponent'; though you should be aware:\n">&2;
	printf " It is likely that awk/gawk/mawk uses a floating point math library; and precision is not guaranteed.\n">&2;
	printf " Please be aware that your shell likely only supports 32 bit numbers; and warning you the user\n">&2;
	printf " of an overflow or underflow is not worth computing. Accuracy is therefore not guaranteed.\n">&2;
	printf "\n">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

BASE="";
EXPONENT="";
FIND_ROOT=0;
NEWLINE_SUFFIX_OUTPUT=0;

while true; do
	case $1 in
		--base)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				BASE=$2;
				shift 2;
			fi
		;;
		--exponent)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				EXPONENT=$2;
				shift 2;
			fi
		;;
		--find-root)
			FIND_ROOT=1;
			shift 1;
		;;
		--newline-suffix-output)
			NEWLINE_SUFFIX_OUTPUT=1;
			shift 1;
		;;
		"") break; ;;
		*) printf "\nUnrecognised argument $1. ">&2; print_usage_then_exit; ;;
	esac
done



#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_SCRIPT_NAME="$ENV_SETUP_NFT/path_to_script.sh";

if [ ! -x $DEPENDENCY_PATH_SCRIPT_NAME ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_NAME\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_description() {
	printf "A program that performs a function.\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "printf\n">&2;
	printf "echo\n">&2;
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
	printf " Required: --base X (where X is)\n">&2;
	printf "  The 'base' number to raise to an exponent or to find the root of.\n">&2;
	printf "\n">&2;
	printf " Required: --exponent X (where X is)\n">&2;
	printf " The 'exponent' number to raise the base to, or root the base to.\n">&2;
	printf "\n">&2;
	printf " Optional: --find-root\n">&2;
	printf "  The presence of this flag causes the function to find the root of the base.\n">&2;
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
BASE="";
EXPONENT="";

#FLAGS:
FIND_ROOT=0;
SKIP_VALIDATION=0;
ONLY_VALIDATE=0;

while true; do
	case $1 in
		#Approach to parsing arguments:
		#If the length of 'all arguments' is less than 2 (shift reduces this number),
		#since this is an argument parameter and requires a value; the program cannot continue.
		#Else, if the argument was provided, and its 'value' is empty; the program cannot continue.
		#Else, assign the argument, and shift 2 (both the argument indicator and its value / move next)

		--base)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				BASE=$2;
				shift 2;
			fi
		;;

		--exponent)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				EXPONENT=$2;
				shift 2;
			fi
		;;

		#Approach to parsing flags:
		#If the flag was provided, toggle on its value; then move next
		#Or shift 1 / remove the flag from the list

		--find-root)
			FIND_ROOT=1;
			shift 1;
		;;

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
	if [ -z "$BASE" ]; then
		printf "\nMissing --base. ">&2;
		print_usage_then_exit;
	fi

	if [ "$(echo $BASE | grep '[-]\{0,1\}[0-9]\{1,10\}')" = "" ]; then
		printf "\nInvalid --base. ">&2;
		print_usage_then_exit;
	fi

	if [ -z "$EXPONENT" ]; then
		printf "\nMissing --exponent. ">&2;
		print_usage_then_exit;
	fi

	if [ "$(echo $EXPONENT | grep '[-]\{0,1\}[0-9]\{1,10\}')" = "" ]; then
		printf "\nInvalid --exponent. ">&2;
		print_usage_then_exit;
	fi

	if [ $FIND_ROOT -eq 1 ] && [ -z "$(echo $BASE | grep '-')" ]; then
		printf "\nInvalid combination of --find-root and a negative --base: the result is an irrational number. ">&2;
		print_usage_then_exit;
	fi
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

#If exponent is zero, the result is always 1.
#If exponent is one, the result is always the base.
#If the user wishes to find the 'nth root', inverse the exponent and exponentiate
#Else, exponentiate.

#Note: depends on awk/mawk/gawk for floating-point number support, and additionally for its' math library.

if [ $EXPONENT -eq 0 ]; then
	printf "1";

elif [ $EXPONENT -eq 1 ]; then
	printf "$BASE";

elif [ $FIND_ROOT -eq 1 ]; then
	EXPONENT_ABSOLUTE=$($DEPENDENCY_SCRIPT_PATH_ABSOLUTE --number "$EXPONENT");
	case $? in
		0) ;;
		*) printf "$0: dependency: \"$DEPENDENCY_SCRIPT_PATH_ABSOLUTE\" produced a failure exit code."; exit 3; ;;
	esac

	EXPONENT_INVERSE=$(awk -v exponent=$EXPONENT_ABSOLUTE -- 'BEGIN{ print 1 / exponent }');

	ROOT=$(awk -v base=$BASE -v exponent=$EXPONENT_INVERSE -- 'BEGIN{ print base ^ exponent }');

	printf "$ROOT";

else
	EXPONENTIATED=$(awk -v base=$BASE -v exponent=$EXPONENT -- 'BEGIN{print base ^ exponent}');

	printf "$EXPONENTIATED";

fi

if [ $NEWLINE_SUFFIX_OUTPUT -eq 1 ]; then
	printf '\n';
fi

exit 0;
