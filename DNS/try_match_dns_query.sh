#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_SCRIPT_NAME="$ENV_SETUP_NFT/path_to_script.sh";

if [ ! -x $DEPENDENCY_PATH_SCRIPT_NAME ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_NAME\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_description() {
	printf "A program that prints part of an NFT rule 'match' section. The match intends to identify DNS 'query' packets.\n">&2;
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
	printf " Optional: --dns-service-uid x (The number ranges from 1-65535)">&2;
	printf " Note: it is stronly recommended to supply the user ID. It is the ID assigned to the DNS server 'service' listed in the /etc/passwd file.">&2;
	printf "\n">&2;
	printf " Optional: --is-recursion-desired yes|no\n">&2;
	printf " Note: providing this argument causes the program to confirm definitely if the query does or does not desire a recursive query from the server.\n">&2;
	printf " Note: In a shell/nft environment this flag is limited in its usefulness, as it is difficult to parse the queried domains,\n">&2;
	printf " Note: and therefore is difficult to confirm if the query is valid in its preference for recursion.\n">&2;
	printf " Note: If this argument is ommited, the packets' preference for recursion is not strictly enforced.\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf " Note: enabling this flag causes the program to skip validating inputs (if you already know they are valid.)\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validate\n">&2;
	printf " Note: enabling this flag causes the program to exit after validating inputs.\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
DNS_SERVICE_UID="";

#FLAGS:
SKIP_VALIDATION=0;
ONLY_VALIDATE=0;
IS_RECURSION_DESIRED=-1;

while true; do
	case $1 in
		#Approach to parsing arguments:
		#If the length of 'all arguments' is less than 2 (shift reduces this number),
		#since this is an argument parameter and requires a value; the program cannot continue.
		#Else, if the argument was provided, and its 'value' is empty; the program cannot continue.
		#Else, assign the argument, and shift 2 (both the argument indicator and its value / move next)

		--dns-service-uid)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				DNS_SERVICE_UID=$2;
				shift 2;
			fi
		;;

		--is-recursion-desired)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				IS_RECURSION_DESIRED=$2;
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
	case $IS_RECRUSION_DESIRED in
		-1) ;;
		yes) ;;
		no) ;;
		*) printf "\nInvalid --is-recursion-desired. "; print_usage_then_exit; ;;
	esac
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

if [ -n $DNS_SERVICE_UID ]; then
	printf "\\t\\tmeta skuid $DNS_SERVICE_UID \\\\\n";
fi

printf "\\t\\t#ID\n";
printf "\\t\\t@ih,0,16 != 0 \\\\\n";

printf "\\t\\t#Query (0) or Response (1)\n";
printf "\\t\\t@ih,16,1 0 \\\\\n";

printf "\\t\\t#OPCODE\n";
printf "\\t\\t@ih,17,4 > -1 \\\\\n";
printf "\\t\\t@ih,17,4 < 2 \\\\\n";

printf "\\t\\t#Authoritative Answer\n";
printf "\\t\\t@ih,21,1 0 \\\\\n";

printf "\\t\\t#Truncation\n";
printf "\\t\\t@ih,22,1 0 \\\\\n";

printf "\\t\\t#Recursion Desired\n";
case $IS_RECRUSION_DESIRED in
	-1)
		printf "\\t\\t#@ih,23,1 - not strictly enforced. It can only be 1 or 0; no further validation required. \\\\\n";
	;;
	yes)
		printf "\\t\\t@ih,23,1 1 \\\\\n";
	;;
	no)
		printf "\\t\\t@ih,23,1 0 \\\\\n";
	;;
	*) printf "\nInvalid --is-recursion-desired. "; print_usage_then_exit; ;;
esac

printf "\\t\\t#Recursion Available\n";
printf "\\t\\t#@ih,24,1 - \\\\\n";

printf "\\t\\t#Reserved bits (0's)\n";
printf "\\t\\t@ih,25,3 0 \\\\\n";

printf "\\t\\t#Response Code\n";
printf "\\t\\t@ih,28,4 0 \\\\\n";

printf "\\t\\t#Queried Domain Count\n";
printf "\\t\\t@ih,32,16 > 0 \\\\\n";

printf "\\t\\t#Answer Count\n";
printf "\\t\\t@ih,48,16 0 \\\\\n";

printf "\\t\\t#Name Server Count\n";
printf "\\t\\t@ih,64,16 0 \\\\\n";

printf "\\t\\t#Additional Record Count\n";
printf "\\t\\t@ih,80,16 0 \\\\\n";

exit 0;
