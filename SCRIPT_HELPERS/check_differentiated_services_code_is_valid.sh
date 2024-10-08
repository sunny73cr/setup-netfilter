#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

#DEPENDENCY_PATH_SCRIPT_NAME="$ENV_SETUP_NFT/path_to_script.sh";

#if [ ! -x $DEPENDENCY_PATH_SCRIPT_NAME ]; then
#	printf "$0: dependency: \"$DEPENDENCY_PATH_NAME\" is missing or is not executable.\n">&2;
#	exit 3;
#fi

print_description() {
	printf "A program that confirms or denies if the provided DSCP value is valid.\n">&2;
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
	printf "\n">&2;
}

print_dependencies_then_exit() {
	print_dependencies;
	exit 2;
}

if [ "$1" = "-d" ]; then print_dependencies_then_exit; fi

print_usage() {
	printf "Usage: $0 <parameters>\n">&2;
	printf " -e\n">&2;
	printf " calling the program with the '-e' flag prints an explanation of the scripts' function or purpose.\n">&2;
	printf " The program then exits with a code of 2 (user input error).\n">&2;
	printf "\n">&2;
	printf " -h\n">&2;
	printf " calling the program with the '-h' flag prints an explanation of the scripts' parameters and their effect.\n">&2;
	printf " The program then exits with a code of 2 (user input error).\n">&2;
	printf "\n">&2;
	printf " -d\n">&2;
	printf " callling the program with the '-d' flags prints a (new-line separated, and terminated) list of the programs' dependencies (what it needs to run).\n">&2;
	printf " The program then exits with a code of 2 (user input error).\n">&2;
	printf "\n">&2;
	printf " -ehd\n">&2;
	printf " calling the program with the '-ehd' flag (or, ehd-ucate me) prints the description, the dependencies list, and the usage text.\n">&2;
	printf " The program then exits with a code of 2 (user input error).\n">&2;
	printf "\n">&2;
	printf " Note that calling all scripts in a project with the flag '-ehd', then concatenating their output using file redirection (string > file),\n">&2;
	printf " Is a nice and easy way to maintain documentation for your project.\n">&2;
	printf "\n">&2;
	printf "Parameters:\n">&2;
	printf "\n">&2;
	printf " Required: --code\n">&2;
	printf "  Note: this is a decimal code relating to an assigned \"DSCP Code\" as defined by IANA.\n">&2;
	printf "  Note: refer to: https://iana.org/assignments/dscp-registry/dscp-registry.xhtml\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
CODE="";

#FLAGS:

while true; do
	case $1 in
		#Approach to parsing arguments:
		#If the length of 'all arguments' is less than 2 (shift reduces this number),
		#since this is an argument parameter and requires a value; the program cannot continue.
		#Else, if the argument was provided, and its 'value' is empty; the program cannot continue.
		#Else, assign the argument, and shift 2 (both the argument indicator and its value / move next)

		--code)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				CODE=$2;
				shift 2;
			fi
		;;

		#Approach to parsing flags:
		#If the flag was provided, toggle on its value; then move next
		#Or shift 1 / remove the flag from the list

		#

		#Handle the case of 'end' of arg parsing; where all flags are shifted from the list,
		#or the program was called without any parameters. exit the arg parsing loop.
		"") break; ;;

		#Handle the case where an argument or flag was called that the program does not recognise.
		#This should prefix the 'usage' text with the reason the program failed.
		#The 'Standard Error' file descriptor is used to separate failure output or log messages from actual program output.
		*) printf "\nUnrecognised argument $1. ">&2; print_usage_then_exit; ;;

	esac
done;

if [ -z "$CODE" ]; then
	printf "\nMissing --code. ">&2;
	print_usage_then_exit;
fi

if [ -z "$(echo $CODE | grep '[0-9]\{1,2\}')" ]; then
	printf "\nInvalid --code. Must be a decimal number. ">&2;
	print_usage_then_exit;
fi

case $CODE in
	0) exit 0; ;; #CS0
	8) exit 0; ;; #CS1
	16) exit 0; ;; #CS2
	24) exit 0; ;; #CS3
	32) exit 0; ;; #CS4
	40) exit 0; ;; #CS5
	48) exit 0; ;; #CS6
	56) exit 0; ;; #CS7
	10) exit 0; ;; #AF11
	12) exit 0; ;; #AF12
	14) exit 0; ;; #AF13
	18) exit 0; ;; #AF21
	20) exit 0; ;; #AF22
	22) exit 0; ;; #AF23
	26) exit 0; ;; #AF31
	28) exit 0; ;; #AF32
	30) exit 0; ;; #AF33
	34) exit 0; ;; #AF41
	36) exit 0; ;; #AF42
	38) exit 0; ;; #AF43
	46) exit 0; ;; #EF
	44) exit 0; ;; #VOICE-ADMIT
	*) exit 1; ;;
esac

exit 0;
