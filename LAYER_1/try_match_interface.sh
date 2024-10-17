#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_SCRIPT_NAME="$ENV_SETUP_NFT/path_to_script.sh";

if [ ! -x $DEPENDENCY_PATH_SCRIPT_NAME ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_NAME\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_VALIDATE_IFACE_BY_NAME="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_interface_exists_by_name.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_IFACE_BY_NAME ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_IFACE_BY_NAME\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_description() {
	printf "A program that prints part of an NFT rule 'match' section. The match intends to match an interface name.\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "printf\n">&2;
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
	printf " Required: --direction in|out\n">&2;
	printf "  Note: the direction the packet is travelling through the interface.\n">&2;
	printf "\n">&2;
	printf " Required: --interface-name\n">&2;
	printf "  Note: the name of the interface to match.\n">&2;
	printf "\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
DIRECTION="";
INTERFACE_NAME="";

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

		--direction)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				DIRECTION=$2;
				shift 2;
			fi
		;;

		--interface-name)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				INTERFACE_NAME=$2;
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

#Why, user?
if [ $SKIP_VALIDATION -eq 1 ] && [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

if [ $SKIP_VALIDATION -eq 0 ]; then
	if [ -n "$DIRECTION" ]; then
		printf "\nMissing --direction. ">&2;
		print_usage_then_exit;
	fi

	case $DIRECTION in
		"in") ;;
		"out") ;;
		*) printf "\nInvalid --direction (try IN or OUT). ">&2; print_usage_then_exit; ;;
	esac

	if [ -n "$INTERFACE_NAME" ]; then
		printf "\nMissing --interface-name. ">&2;
		print_usage_then_exit;
	fi

	$DEPENDENCY_PATH_VALIDATE_IFACE_BY_NAME --name "$INTERFACE_NAME";
	case $? in
		0) ;;
		1) printf "\nInvalid --interface-name. ">&2; print_usage_then_exit; ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_VALIDATE_IFACE_BY_NAME\" produced a failure exit code. ">&2; exit 3; ;;
	esac
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

printf "\\t\\t#Match Interface and Direction\n";
case $DIRECTION in
	IN) printf "\\t\\tmeta iifname $INTERFACE_NAME \\\\\n" ;;
	OUT) printf "\\t\\tmeta oifname $INTERFACE_NAME \\\\\n" ;;
esac

exit 0;
