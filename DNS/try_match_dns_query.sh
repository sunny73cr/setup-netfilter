#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_VALIDATE_SERVICE_ID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_service_user_id_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_SERVICE_ID ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_SERVICE_ID\" is missing or is not executable.\n">&2;
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
	printf "Dependencies: \n">&2;
	printf "printf\n">&2;
	printf "$DEPENDENCY_PATH_VALIDATE_SERVICE_ID\n">&2;
	printf "\n">&2;
}

print_dependencies_then_exit() {
	print_dependencies;
	exit 2;
}

if [ "$1" = "-d" ]; then print_dependencies_then_exit; fi

print_usage() {
	printf "Usage: $0 <parameters>\n">&2;
	printf "Flags used by themselves: \n">&2;
	printf " -e (prints an explanation of the functions' purpose) (exit code 2)\n">&2;
	printf " -h (prints an explanation of the functions' available parameters, and their effect) (exit code 2)\n">&2;
	printf " -d (prints the functions' dependencies: newline delimited list) (exit code 2)\n">&2
	printf " -ehd (prints the above three) (exit code 2)\n">&2;
	printf "\n">&2;
	printf "Parameters:\n">&2;
	printf "\n">&2;
	printf " Optional: --dns-service-uid x (The number ranges from 1-65535)">&2;
	printf "  it is stronly recommended to supply the user ID. It is the ID assigned to the DNS server 'service' listed in the /etc/passwd file.">&2;
	printf "\n">&2;
	printf " Optional: --transaction-id X (where x is 0-65535)\n">&2;
	printf "\n">&2;
	printf " Optional: --transaction-id-min X (where x is 0-65535)\n">&2;
	printf "\n">&2;
	printf " Optional: --transaction-id-max X (where x is 0-65535)\n">&2;
	printf "\n">&2;
	printf " You cannot combine --transaction-id with either --transaction-id-min or --transaction-id-max\n">&2;
	printf " You are not required to supply both --transaction-id-min or --transaction-id-max\n">&2;
	printf "\n">&2;
	printf " Optional: --op-code x (where x is an option listed below)\n">&2;
	printf "  1. standard-query - a standard A/AAAA/CNAME/PTR/NS/MX/etc query\n">&2;
	printf "  2. inverse-query - an IQuery/Inverse QUery (OBSOLETE!)\n">&2;
	printf "  3. status - a 'status' request (behaviour undefined)\n">&2;
	printf "  4. unassigned-3 - the unassigned op code '3'\n">&2;
	printf "  5. notify - a 'notify' message indicates an update to a resource record that the slave should apply to its database.\n">&2;
	printf "  6. update - an 'update' message indicates an uodate to a resource record\n">&2;
	printf "  7. dso - a 'DNS Stateful Operation'\n">&2;
	printf "  8. unassigned-7-15\n">&2;
	printf "\n">&2;
	printf " since --op-code 5 (notify) is used within a master/slave topology in an authoritative server environment; it must be combined with --is-authoritative-master (request) or --is-authoritative-slave (response)\n">&2;
	printf "\n">&2;
	printf " Optional: --is-recursion-desired yes|no\n">&2;
	printf "  Is a recursive query desired? (If not found, ask the next server in the chain)\n">&2;
	printf "\n">&2;
	printf " Optional: --is-dnssec-enabled yes|no\n">&2;
	printf "  Has the admin of this machine enabled DNSSEC?\n">&2;
	printf "\n">&2;
	printf " Optional: --is-checking-disabled\n">&2;
	printf "  Is checking of the response data disabled?\n">&2;
	printf "\n">&2;
	printf " For --is-recursion-desired, --is-checking-disabled:\n">&2;
	printf " A specified preference will only match what was provided.\n">&2;
	printf " Absence of this argument indicates that there is no preference, and the value is not matched.\n">&2;
	printf "\n">&2;
	printf " Optional: --total-questions X (where x is 0-65535)\n">&2;
	printf "  Limit the total RRs queried to an exact count\n">&2;
	printf "\n">&2;
	printf " Optional: --total-questions-min X (where x is 0-65535)\n">&2;
	printf "  Limit the total RRs queried to a minimum\n">&2;
	printf "\n">&2;
	printf " Optional: --total-questions-max X (where x is 0-65535)\n">&2;
	printf "  Limit the total RRs queried to a maximum\n">&2;
	printf "\n">&2;
	printf " You cannot combine --total-questions with either --total-questions-min or --total-questions-max\n">&2;
	printf " You are not required to supply both --total-questions-min or --total-questions-max\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf "  enabling this flag causes the program to skip validating inputs (if you already know they are valid.)\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validate\n">&2;
	printf "  enabling this flag causes the program to exit after validating inputs.\n">&2;
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
TRANSACTION_ID="";
TRANSACTION_ID_MIN="";
TRANSACTION_ID_MAX="";
OP_CODE="";
IS_RECURSION_DESIRED="";
IS_DNSSEC_ENABLED="";
IS_CHECKING_DISABLED="";
TOTAL_QUESTIONS="";
TOTAL_QUESTIONS_MIN="";
TOTAL_QUESTIONS_MAX="";

#FLAGS:
IS_AUTHORITATIVE_MASTER=0;
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

		--transaction-id)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				TRANSACTION_ID=$2;
				shift 2;
			fi
		;;

		--transaction-id-min)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				TRANSACTION_ID_MIN=$2;
				shift 2;
			fi
		;;

		--transaction-id-max)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				TRANSACTION_ID_MAX=$2;
				shift 2;
			fi
		;;

		--op-code)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				OP_CODE=$2;
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

		--is-dnssec-enabled)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				IS_DNSSEC_ENABLED=$2;
				shift 2;
			fi
		;;

		--is-checking-disabled)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				IS_CHECKING_DISABLED=$2;
				shift 2;
			fi
		;;

		--total-questions)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				TOTAL_QUESTIONS=$2;
				shift 2;
			fi
		;;

		--total-questions-min)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				TOTAL_QUESTIONS_MIN=$2;
				shift 2;
			fi
		;;

		--total-questions-max)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				TOTAL_QUESTIONS_MAX=$2;
				shift 2;
			fi
		;;

		#Approach to parsing flags:
		#If the flag was provided, toggle on its value; then move next
		#Or shift 1 / remove the flag from the list

		--is-authoritative-master)
			IS_AUTHORITATIVE_MASTER=1;
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

#Why, user?
if [ $SKIP_VALIDATION -eq 1 ] && [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

if [ $SKIP_VALIDATION -eq 0 ]; then
	if [ -n "$DNS_SERVICE_ID" ]; then
		$DEPENDENCY_PATH_VALIDATE_SERVICE_ID --service-user-id $DNS_SERVICE_ID;
		case $? in
			0) ;;
			1) printf "\nInvalid --dns-service-uid. "; print_usage_then_exit; ;;
			*) printf "$0: dependency \"$DEPENDENCY_PATH_VALIDATE_SERVICE_ID\" produced a failure exit code ($?)."; exit 4; ;;
		esac
	fi

	if [ -n "$TRANSACTION_ID" ] && [ -n "$TRANSACTION_ID_MIN" ]; then
		printf "\nInvalid combination of --transaction-id and --transaction-id-min. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$TRANSACTION_ID" ] && [ -n "$TRANSACTION_ID_MAX" ]; then
		printf "\nInvalid combination of --transaction-id and --transaction-id-max. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$TRANSACTION_ID" ]; then
		if [ -z "$(echo $TRANSACTION_ID | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --transaction-id (must be a 1-5 digit number) ">&2;
			print_usage_then_exit;
		fi

		if [ $TRANSACTION_ID -lt 0 ]; then
			printf "\nInvalid --transaction-id (must be 0 or greater) ">&2;
			print_usage_then_exit;
		fi

		if [ $TRANSACTION_ID -gt 65535 ]; then
			printf "\nInvalid --transaction-id (must be less than 65536) ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$TRANSACTION_ID_MIN" ]; then
		if [ -z "$(echo $TRANSACTION_ID_MIN | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --transaction-id-min (must be a 1-5 digit number) ">&2;
			print_usage_then_exit;
		fi

		if [ $TRANSACTION_ID_MIN -lt 0 ]; then
			printf "\nInvalid --transaction-id-min (must be 0 or greater) ">&2;
			print_usage_then_exit;
		fi

		if [ $TRANSACTION_ID_MIN -gt 65535 ]; then
			printf "\nInvalid --transaction-id-min (must be less than 65536) ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$TRANSACTION_ID_MAX" ]; then
		if [ -z "$(echo $TRANSACTION_ID_MAX | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --transaction-id-max (must be a 1-5 digit number) ">&2;
			print_usage_then_exit;
		fi

		if [ $TRANSACTION_ID_MAX -lt 0 ]; then
			printf "\nInvalid --transaction-id-max (must be 0 or greater) ">&2;
			print_usage_then_exit;
		fi

		if [ $TRANSACTION_ID_MAX -gt 65535 ]; then
			printf "\nInvalid --transaction-id-max (must be less than 65536) ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$OP_CODE" ]; then
		case $OP_CODE in
			standard-query) ;;
			inverse-query) ;;
			status) ;;
			unassigned-3) ;;
			notify) ;;
			update) ;;
			dso) ;;
			unassigned-7-15) ;;
			*) printf "\nInvalid --op-code. ">&2; print_usage_then_exit; ;;
		esac
	fi

	if [ -n "$IS_RECURSION_DESIRED" ]; then
		case $IS_RECURSION_DESIRED in
			yes) ;;
			no) ;;
			*) printf "\nInvalid --is-recursion-desired. ">&2; print_usage_then_exit; ;;
		esac
	fi

	if [ "$IS_CHECKING_DISABLED" = "yes" ] && [ "$IS_DNSSEC_ENABLED" != "yes" ]; then
		printf "\nIf --is-checking-disabled is yes, then --is-dnssec-enabled must also be yes. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$IS_DNSSEC_ENABLED" ]; then
		case $IS_DNSSEC_ENABLED in
			yes) ;;
			no) ;;
			*) printf "\nInvalid --is-dnssec-enabled. ">&2; print_usage_then_exit; ;;
		esac
	fi

	if [ -n "$IS_CHECKING_DISABLED" ]; then
		case $IS_CHECKING_DISABLED in
			yes) ;;
			no) ;;
			*) printf "\nInvalid --is-checking-disabled. ">&2; print_usage_then_exit; ;;
		esac
	fi

	if [ -n "$TOTAL_QUESTIONS" ] && [ -n "$TOTAL_QUESTIONS_MIN" ]; then
		printf "\nInvalid combination of --total-questions and --total-questions-min. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$TOTAL_QUESTIONS" ] && [ -n "$TOTAL_QUESTIONS_MAX" ]; then
		printf "\nInvalid combination of --total-questions and --total-questions-max. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$TOTAL_QUESTIONS" ]; then
		if [ -z "$(echo $TOTAL_QUESTIONS | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --total-questions (must be a 1-5 digit number) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_QUESTIONS -lt 0 ]; then
			printf "\nInvalid --total-questions (must be 0 or greater) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_QUESTIONS -gt 65535 ]; then
			printf "\nInvalid --total-questions (must be less than 65536) ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$TOTAL_QUESTIONS_MIN" ]; then
		if [ -z "$(echo $TOTAL_QUESTIONS_MIN | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --total-questions-min (must be a 1-5 digit number) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_QUESTIONS_MIN -lt 0 ]; then
			printf "\nInvalid --total-questions-min (must be 0 or greater) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_QUESTIONS_MIN -gt 65535 ]; then
			printf "\nInvalid --total-questions-min (must be less than 65536) ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$TOTAL_QUESTIONS_MAX" ]; then
		if [ -z "$(echo $TOTAL_QUESTIONS_MAX | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --total-questions-max (must be a 1-5 digit number) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_QUESTIONS_MAX -lt 0 ]; then
			printf "\nInvalid --total-questions-max (must be 0 or greater) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_QUESTIONS_MAX -gt 65535 ]; then
			printf "\nInvalid --total-questions-max (must be less than 65536) ">&2;
			print_usage_then_exit;
		fi
	fi
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

OFFSET_MARKER="ih";
BIT_OFFSET_PACKET_BEGIN=0;
BIT_OFFSET_TRANSACTION_ID=$BIT_OFFSET_PACKET_BEGIN;
BIT_OFFSET_TYPE=$(($BIT_OFFSET_TRANSACTION_ID+16));
BIT_OFFSET_OP=$(($BIT_OFFSET_TYPE+1));
BIT_OFFSET_IS_AUTHORITATIVE_ANSWER=$(($BIT_OFFSET_OP+4));
BIT_OFFSET_IS_RESPONSE_TRUNCATED=$(($BIT_OFFSET_IS_AUTHORITATIVE_ANSWER+1));
BIT_OFFSET_IS_RECURSION_DESIRED=$(($BIT_OFFSET_IS_RESPONSE_TRUNCATED+1));
BIT_OFFSET_IS_RECURSION_AVAILABLE=$(($BIT_OFFSET_IS_RECURSION_DESIRED+1));
BIT_OFFSET_ZERO=$(($BIT_OFFSET_IS_RECURSION_AVAILABLE+1));
BIT_OFFSET_IS_AUTHENTIC_DATA=$(($BIT_OFFSET_ZERO+1));
BIT_OFFSET_IS_CHECKING_DISABLED=$(($BIT_OFFSET_IS_AUTHENTIC_DATA+1));
BIT_OFFSET_RESPONSE_CODE=$(($BIT_OFFSET_IS_CHECKING_DISABLED+1));
BIT_OFFSET_TOTAL_QUESTIONS=$(($BIT_OFFSET_RESPONSE_CODE+4));
BIT_OFFSET_TOTAL_ANSWERS=$(($BIT_OFFSET_TOTAL_QUESTIONS+16));
BIT_OFFSET_TOTAL_AUTHORITY_RECORDS=$(($BIT_OFFSET_TOTAL_ANSWERS+16));
BIT_OFFSET_TOTAL_ADDITIONAL_RECORDS=$(($BIT_OFFSET_TOTAL_AUTHORITY_RECORDS+16));
BIT_OFFSET_QUESTIONS=$(($BIT_OFFSET_TOTAL_ADDITIONAL_RECORDS+16));

if [ -n $DNS_SERVICE_UID ]; then
	printf "\\t\\tmeta skuid $DNS_SERVICE_UID \\\\\n";
fi

printf "\\t\\t#Match Transaction ID ";
if [ -n "$TRANSACTION_ID" ]; then
	printf "(exactly $TRANSACTION_ID)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TRANSACTION_ID,16 $TRANSACTION_ID \\\\\n";

elif [ -n "$TRANSACTION_ID_MIN" ] && [ -z "$TRANSACTION_ID_MAX" ]; then
	printf "(minimum $TRANSACTION_ID_MIN)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TRANSACTION_ID,16 >= $TRANSACTION_ID_MIN \\\\\n";

elif [ -z "$TRANSACTION_ID_MIN" ] && [ -n "$TRANSACTION_ID_MAX" ]; then
	printf "(maximum $TRANSACTION_ID_MAX)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TRANSACTION_ID,16 <= $TRANSACTION_ID_MAX \\\\\n";

elif [ -z "$TRANSACTION_ID_MIN" ] && [ -n "$TRANSACTION_ID_MAX" ]
	printf "($TRANSACTION_ID_MIN-$TRANSACTION_ID_MAX)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TRANSACTION_ID,16 >= $TRANSACTION_ID_MIN \\\\\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TRANSACTION_ID,16 <= $TRANSACTION_ID_MAX \\\\\n";
fi

printf "\\t\\t#Match OP Query (0)\n";
printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TYPE,1 0 \\\\\n";

printf "\\t#Match Operation Code ";
if [ -n "$OP_CODE" ]; then
	case $OP_CODE in
		standard-query)
			printf "(standard-query)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_OP_CODE,4 0 \\\\\n";
		;;
		inverse-query)
			printf "(inverse-query)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_OP_CODE,4 1 \\\\\n";
		;;
		status)
			printf "(status)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_OP_CODE,4 2 \\\\\n";
		;;
		unassigned-3)
			printf "(Unassigned 3)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_OP_CODE,4 3 \\\\\n";
		;;
		notify)
			printf "(notify)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_OP_CODE,4 4 \\\\\n";
		;;
		update)
			printf "(update zone)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_OP_CODE,4 5 \\\\\n";
		;;
		dso)
			printf "(DNS Stateful Operations)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_OP_CODE,4 6 \\\\\n";
		;;
		unassigned-7-15)
			printf "(Unassigned 7-15)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_OP_CODE,4 >= 7 \\\\\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_OP_CODE,4 <= 15 \\\\\n";
		;;
	esac
else
	printf "\\t\\t#Preference for Operation Code is unrestricted - consider the implications\n";
fi

printf "\\t#Match Authoritative Answer ";
printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_IS_AUTHORITATIVE_ANSWER,1 0 \\\\\n";

printf "\\t#Match Response Truncated ";
printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_IS_RESPONSE_TRUNCATED,1 1 \\\\\n";

printf "\\t#Match Recursion Desired ";
if [ -n "$IS_RECURSION_DESIRED" ]; then
	case $IS_RECURSION_DESIRED in
		yes)
			printf "(yes)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_IS_RECURSION_DESIRED,1 1 \\\\\n";
		;;
		no)
			printf "(no)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_IS_RECURSION_DESIRED,1 0 \\\\\n";
		;;
	esac
else
	printf "\\t\\t#Preference for Recursion Desired is unrestricted - consider the implications\n";
fi

printf "\\t#Match Recursion Available ";
printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_IS_RECURSION_AVAILABLE,1 0 \\\\\n";

printf "\\t#Match Reserved bit (always 0)\n";
printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_ZERO,1 0 \\\\\n";

printf "\\t#Match Authentic Data ";
printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_IS_AUTHENTIC_DATA,1 0 \\\\\n";

if [ -n "$IS_CHECKING_DISABLED" ]; then
	printf "\\t#Match Checking Disabled ";
	case $IS_CHECKING_DISABLED in
		yes)
			printf "(yes)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_IS_CHECKING_DISABLED,1 1 \\\\\n";
		;;
		no)
			printf "(no)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_IS_CHECKING_DISABLED,1 0 \\\\\n";
		;;
	esac
else
	if [ $IS_DNSSEC_ENABLED -eq 1 ]; then
		printf "\\t\\t#Preference for Checking Disabled is unrestricted - consider the implications\n";
	else
		printf "\\t#DNSSEC is Disabled / The Checking Disabled bit was originally reserved and should be 0\n"
		printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_IS_CHECKING_DISABLED,1 0 \\\\\n";
	fi
fi

printf "\\t#Match Response Code ";
printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 0 \\\\\n";

printf "\\t\\t#Match Total Questions ";
if [ -n "$TOTAL_QUESTIONS" ]; then
	printf "(exactly $TOTAL_QUESTIONS)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_QUESTIONS,16 $TOTAL_QUESTIONS \\\\\n";

elif [ -n "$TOTAL_QUESTIONS_MIN" ] && [ -z "$TOTAL_QUESTIONS_MAX" ]; then
	printf "(minimum $TOTAL_QUESTIONS_MIN)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_QUESTIONS,16 >= $TOTAL_QUESTIONS_MIN \\\\\n";

elif [ -z "$TOTAL_QUESTIONS_MIN" ] && [ -n "$TOTAL_QUESTIONS_MAX" ]; then
	printf "(maximum $TOTAL_QUESTIONS_MAX)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_QUESTIONS,16 <= $TOTAL_QUESTIONS_MAX \\\\\n";

elif [ -z "$TOTAL_QUESTIONS_MIN" ] && [ -n "$TOTAL_QUESTIONS_MAX" ]
	printf "($TOTAL_QUESTIONS_MIN-$TOTAL_QUESTIONS_MAX)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_QUESTIONS,16 >= $TOTAL_QUESTIONS_MIN \\\\\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_QUESTIONS,16 <= $TOTAL_QUESTIONS_MAX \\\\\n";
fi

printf "\\t\\t#Match Total Answers (0 for query)";
printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_ANSWERS,16 0 \\\\\n";

printf "\\t\\t#Match Total Authority Records (0 for query)";
printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_AUTHORITY_RECORDS,16 0 \\\\\n";

printf "\\t\\t#Match Total Additional Records (0 for query)";
printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_ADDITIONAL_RECORDS,16 0 \\\\\n";

exit 0;
