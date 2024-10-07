#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_VALIDATE_SERVICE_ID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_service_user_id_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_SERVICE_ID ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_SERVICE_ID\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_description() {
	printf "A program that prints part of an NFT rule 'match' section. The match intends to identify DNS 'response' packets.\n">&2;
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
	printf " Note: If this argument is ommited, the sessions' preference for recursion is not strictly enforced.\n">&2;
	printf "\n">&2;
	printf " Optional: --is-recursion-available yes|no\n">&2;
	printf " Note: providing this argument causes the program to confirm definitely if the query does or does not desire a recursive query from the server.\n">&2;
	printf " Note: If this argument is ommited, the servers' ability to query recursively is not strictly enforced.\n">&2;
	printf "\n">&2;
	printf " Optional: --is-authoritative yes|no\n">&2;
	printf " Note: providing this argument causes the program to confirm definitely if the response is or is not from an authoritative server.\n">&2;
	printf " Note: If this argument is ommited, the responses' indication of authority is not strictly enforced.\n">&2;
	printf "\n">&2;
	printf " Optional: --is-truncated yes|no\n">&2;
	printf " Note: providing this argument causes the program to confirm definitely if the response is or is not truncated.\n">&2;
	printf " Note: If this argument is ommited, the responses' indication of truncation is not strictly enforced.\n">&2;
	printf "\n">&2;
	printf " Optional: --response-code x (where x is 0-5)\n">&2;
	printf " Note: providing this argument causes the program to restrict the response code to the provided value.\n">&2;
	printf " Note: If this argument is ommited, the response code is not strictly enforced beyond the range of legal values.\n">&2;
	printf "\n">&2;
	printf " Note: for the arguments: --is-recursion-desired, --is-recursion-available, --is-authoritative, --is-truncated.\n">&2;
	printf " Note: In a shell/nft environment this flag is limited in its usefulness, as it is difficult to parse packet content,\n">&2;
	printf " Note: and therefore is difficult to confirm if the response is truly valid.\n">&2;
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
IS_RECURSION_DESIRED=-1;
IS_RECRUSION_AVAILABLE=-1;
IS_AUTHORITATIVE=-1;
IS_TRUNCATED=-1;
RESPONSE_CODE=-1;

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

		--is-recursion-available)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				IS_RECURSION_available=$2;
				shift 2;
			fi
		;;

		--is-authoritative)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				IS_AUTHORITATIVE=$2;
				shift 2;
			fi
		;;

		--is-truncated)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				IS_TRUNCATED=$2;
				shift 2;
			fi
		;;

		--response-code)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				RESPONSE_CODE=$2;
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
	if [ -n "$DNS_SERVICE_ID" ]; then
		$DEPENDENCY_PATH_VALIDATE_SERVICE_ID --service-user-id $DNS_SERVICE_ID;
		case $? in
			0) ;;
			1) printf "\nInvalid --dns-service-id. "; print_usage_then_exit; ;;
			*) printf "$0: dependency \"$DEPENDENCY_PATH_VALIDATE_SERVICE_ID\" produced a failure exit code."; exit 4; ;;
		esac
	fi

	case $IS_RECRUSION_DESIRED in
		-1) ;;
		yes) ;;
		no) ;;
		*) printf "\nInvalid --is-recursion-desired. "; print_usage_then_exit; ;;
	esac

	case $IS_RECRUSION_AVAILABLE in
		-1) ;;
		yes) ;;
		no) ;;
		*) printf "\nInvalid --is-recursion-available. "; print_usage_then_exit; ;;
	esac

	case $IS_AUTHORITATIVE in
		-1) ;;
		yes) ;;
		no) ;;
		*) printf "\nInvalid --is-authoritative. "; print_usage_then_exit; ;;
	esac

	case $IS_TRUNCATED in
		-1) ;;
		yes) ;;
		no) ;;
		*) printf "\nInvalid --is-truncated. "; print_usage_then_exit; ;;
	esac

	case $RESPONSE_CODE in
		0|1|2|3|4|5)
		*) printf "\nInvalid or unsupported --response-code. "; print_usage_then_exit; ;;
	esac
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

if [ -n $DNS_SERVICE_UID ]; then
	printf "\\t\\tmeta skuid $DNS_SERVICE_UID \\\\\n";
fi

printf "\\t\\t#ID\n";
printf "\\t\\t@ih,0,16 != 0 \\\\\n";

printf "\\t\\t#Query (0) or Response (1)\n";
printf "\\t\\t@ih,16,1 1 \\\\\n";

printf "\\t\\t#OPCODE\n";
printf "\\t\\t@ih,17,4 > -1 \\\\\n";
printf "\\t\\t@ih,17,4 < 2 \\\\\n";

printf "\\t\\t#Authoritative Answer\n";
case $IS_AUTHORITATIVE in
	-1)
		printf "\\t\\t#@ih,21,1 - not strictly enforced. It can only be 1 or 0; no further validation required. \\\\\n";
	;;
	yes)
		printf "\\t\\t@ih,21,1 1 \\\\\n";
	;;
	no)
		printf "\\t\\t@ih,21,1 0 \\\\\n";
	;;
	*) printf "\nInvalid --is-authoritative. "; print_usage_then_exit; ;;
esac

printf "\\t\\t#Truncation\n";
case $IS_TRUNCATED in
	-1)
		printf "\\t\\t#@ih,22,1 - not strictly enforced. It can only be 1 or 0; no further validation required. \\\\\n";
	;;
	yes)
		printf "\\t\\t@ih,22,1 1 \\\\\n";
	;;
	no)
		printf "\\t\\t@ih,22,1 0 \\\\\n";
	;;
	*) printf "\nInvalid --is-truncated. "; print_usage_then_exit; ;;
esac

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
case $IS_RECRUSION_AVAILABLE in
	-1)
		printf "\\t\\t#@ih,24,1 - not strictly enforced. It can only be 1 or 0; no further validation required. \\\\\n";
	;;
	yes)
		printf "\\t\\t@ih,24,1 1 \\\\\n";
	;;
	no)
		printf "\\t\\t@ih,24,1 0 \\\\\n";
	;;
	*) printf "\nInvalid --is-recursion-available. "; print_usage_then_exit; ;;
esac

printf "\\t\\t#Reserved bits (0's)\n";
printf "\\t\\t@ih,25,3 0 \\\\\n";

printf "\\t\\t#Response Code (between 0 and 5 inclusive)\n";
case $RESPONSE_CODE in
	-1)
		#Any valid value.
		printf "\\t\\t#@ih,28,4 > -1 \\\\\n";
		printf "\\t\\t#@ih,28,4 < 6 \\\\\n";
	;;
	0) printf "\\t\\t@ih,28,4 0 \\\\\n"; ;;
	1) printf "\\t\\t@ih,28,4 1 \\\\\n"; ;;
	2) printf "\\t\\t@ih,28,4 2 \\\\\n"; ;;
	3) printf "\\t\\t@ih,28,4 3 \\\\\n"; ;;
	4) printf "\\t\\t@ih,28,4 4 \\\\\n"; ;;
	5) printf "\\t\\t@ih,28,4 5 \\\\\n"; ;;
	*) printf "\nInvalid or unsupported --response-code."; print_usage_then_exit; ;;
esac

printf "\\t\\t#Queried Domain Count\n";
printf "\\t\\t@ih,32,16 > 0 \\\\\n";

printf "\\t\\t#Answer Count\n";
printf "\\t\\t#@ih,48,16 - not strictly enforced, the user cannot possibly know / it is not worth confirming. \\\\\n";

printf "\\t\\t#Name Server Count\n";
printf "\\t\\t#@ih,64,16 - not strictly enforced, the user cannot possibly know \\\\\n";

printf "\\t\\t#Additional Record Count\n";
printf "\\t\\t#@ih,80,16 - not strictly enforced, the user cannot possibly know \\\\\n";

exit 0;
