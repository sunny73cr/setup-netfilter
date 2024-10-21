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
	printf " Optional: --response-code x (where x is an option listed below)\n">&2;
	printf "  1. noerror - no error\n">&2;
	printf "  2. formerr - format error\n">&2;
	printf "  3. servfail - server failure\n">&2;
	printf "  4. nxdomain - non-existent domain\n">&2;
	printf "  5. notimpl - not implemented\n">&2;
	printf "  6. refused - query refused\n">&2;
	printf "  7. yxdomain - name exists when it should not\n">&2;
	printf "  8. yxrrset - rrset exists when it should not\n">&2;
	printf "  9. nxrrset - rrset does not exist when it should\n">&2;
	printf "  10. notauth - server not authoritative / not authorized\n">&2;
	printf "  11. notzone - name not contained in zone\n">&2;
	printf "  12. dsotypeni - DSO-Type not implemented\n">&2;
	printf "  13. unassigned-12-15 - the unassigned response codes 12 to 15\n">&2;
	printf "  14. badvers|badsig - Bad OPT Version or TSIG Signature Failure\n">&2;
	printf "  15. badkey - Key not recognised\n">&2;
	printf "  16. badtime - Signature out of time window\n">&2;
	printf "  17. badmode -  Bad TKEY Mode\n">&2;
	printf "  18. badname -  Duplicate Key name\n">&2;
	printf "  19. badalg -  Algorithm not supported\n">&2;
	printf "  20. badtrunc - Bad Truncation\n">&2;
	printf "  21. badcookie - Bad/Missing server cookie\n">&2;
	printf "  22. unassigned-24-3840 - The unassigned response codes 24 to 3840\n">&2;
	printf "  23. reserved-3841-4095 - The reserved response codes 3841 to 4095 (private use)\n">&2;
	printf "  24. unassigned-4096-65534 - The unassigned response codes 4096 to 54434\n">&2;
	printf "  25. reserved-65535 - The reserved esponse code 65535 (Can be allocated by standards action)\n">&2;
	printf "\n">&2;
	printf " Optional: --is-authoritative-answer yes|no\n">&2;
	printf "  Is the answer authoritative for the zone / was the response sent by an Authoritative Server.\n">&2;
	printf "\n">&2;
	printf " Optional: --is-response-truncated yes|no\n">&2;
	printf "  Is the response too large to fit in a single UDP packet?\n">&2;
	printf "\n">&2;
	printf " Optional: --is-recursion-desired yes|no\n">&2;
	printf "  Is a recursive query desired? (If not found, ask the next server in the chain)\n">&2;
	printf "\n">&2;
	printf " Optional: --is-recursion-available yes|no\n">&2;
	printf "  Is a recursive query available (Can ask the next server in the chain)\n">&2;
	printf "\n">&2;
	printf " Optional: --is-dnssec-enabled yes|no\n">&2;
	printf "  Has the admin of this machine enabled DNSSEC?\n">&2;
	printf "\n">&2;
	printf " Optional: --is-authentic-data\n">&2;
	printf "  Is the response data authentic? (DNSSEC validated)\n">&2;
	printf "\n">&2;
	printf " Optional: --is-checking-disabled\n">&2;
	printf "  Is checking of the response data disabled?\n">&2;
	printf "\n">&2;
	printf " For --is-authoritative-answer, --is-recursion-desired, --is-recursion-available, --is-authentic-data, --is-checking-disabled:\n">&2;
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
	printf " Optional: --total-answers X (where x is 0-65535)\n">&2;
	printf "  Limit the total RRs returned to an exact count\n">&2;
	printf "\n">&2;
	printf " Optional: --total-answers-min X (where x is 0-65535)\n">&2;
	printf "  Limit the total RRs returned to a minimum\n">&2;
	printf "\n">&2;
	printf " Optional: --total-answers-max X (where x is 0-65535)\n">&2;
	printf "  Limit the total RRs returned to a maximum\n">&2;
	printf "\n">&2;
	printf " You cannot combine --total-answers with either --total-answers-min or --total-answers-max\n">&2;
	printf " You are not required to supply both --total-answers-min or --total-answers-max\n">&2;
	printf "\n">&2;
	printf " Optional: --total-authority-records X (where x is 0-65535)\n">&2;
	printf "  Limit the number of Authority RRs to an exact count\n">&2;
	printf "\n">&2;
	printf " Optional: --total-authority-records-min X (where x is 0-65535)\n">&2;
	printf "  Limit the number of Authority RRs to a minimum\n">&2;
	printf "\n">&2;
	printf " Optional: --total-authority-records-max X (where x is 0-65535)\n">&2;
	printf "  Limit the number of Authority RRs to a maximum\n">&2;
	printf "\n">&2;
	printf " You cannot combine --total-authority-records with either --total-authority-records-min or --total-authority-records-max\n">&2;
	printf " You are not required to supply both --total-authority-records-min or --total-authority-records-max\n">&2;
	printf "\n">&2;
	printf " Optional: --total-additional-records X (where x is 0-65535)\n">&2;
	printf "  Limit the number of Additional RRs to an exact count\n">&2;
	printf "\n">&2;
	printf " Optional: --total-additional-records-min X (where x is 0-65535)\n">&2;
	printf "  Limit the number of Additional RRs to a minimum\n">&2;
	printf "\n">&2;
	printf " Optional: --total-additional-records-max X (where x is 0-65535)\n">&2;
	printf "  Limit the number of Additional RRs to a maximum\n">&2;
	printf "\n">&2;
	printf " You cannot combine --total-additional-records with either --total-additional-records-min or --total-additional-records-max\n">&2;
	printf " You are not required to supply both --total-additional-records-min or --total-additional-records-max\n">&2;
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
RESPONSE_CODE="";
IS_AUTHORITATIVE_ANSWER="";
IS_RESPONSE_TRUNCATED="";
IS_RECURSION_DESIRED="";
IS_RECURSION_AVAILABLE="";
IS_DNSSEC_ENABLED="";
IS_AUTHENTIC_DATA="";
IS_CHECKING_DISABLED="";
TOTAL_QUESTIONS="";
TOTAL_QUESTIONS_MIN="";
TOTAL_QUESTIONS_MAX="";
TOTAL_ANSWERS="";
TOTAL_ANSWERS_MIN="";
TOTAL_ANSWERS_MAX="";
TOTAL_AUTHORITY_RECORDS="";
TOTAL_AUTHORITY_RECORDS_MIN="";
TOTAL_AUTHORITY_RECORDS_MAX="";
TOTAL_ADDITIONAL_RECORDS="";
TOTAL_ADDITIONAL_RECORDS_MIN="";
TOTAL_ADDITIONAL_RECORDS_MAX="";

#FLAGS:
IS_AUTHORITATIVE_SLAVE=0;
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

		--is-authoritative-answer)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				IS_AUTHORITATIVE_ANSWER=$2;
				shift 2;
			fi
		;;

		--is-response-truncated)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				IS_RESPONSE_TRUNCATED=$2;
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
				IS_RECURSION_AVAILABLE=$2;
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

		--is-authentic-data)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				IS_AUTHENTIC_DATA=$2;
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

		--total-answers)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				TOTAL_ANSWERS=$2;
				shift 2;
			fi
		;;

		--total-answers-min)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				TOTAL_ANSWERS_MIN=$2;
				shift 2;
			fi
		;;

		--total-answers-max)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				TOTAL_ANSWERS_MAX=$2;
				shift 2;
			fi
		;;

		--total-authority-records)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				TOTAL_AUTHORITY_RECORDS=$2;
				shift 2;
			fi
		;;

		--total-authority-records-min)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				TOTAL_AUTHORITY_RECORDS_MIN=$2;
				shift 2;
			fi
		;;

		--total-authority-records-max)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				TOTAL_AUTHORITY_RECORDS_MAX=$2;
				shift 2;
			fi
		;;

		--total-additonal-records)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				TOTAL_ADDITIONAL_RECORDS=$2;
				shift 2;
			fi
		;;

		--total-additonal-records-min)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				TOTAL_ADDITIONAL_RECORDS_MIN=$2;
				shift 2;
			fi
		;;

		--total-additonal-records-max)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				TOTAL_ADDITIONAL_RECORDS_MAX=$2;
				shift 2;
			fi
		;;

		#Approach to parsing flags:
		#If the flag was provided, toggle on its value; then move next
		#Or shift 1 / remove the flag from the list

		--is-authoritative-slave)
			IS_AUTHORITATIVE_SLAVE=1;
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

	if [ -n "$RESPONSE_CODE" ]; then
		case $RESPONSE_CODE in
			noerror) ;;
			formerr) ;;
			servfail) ;;
			nxdomain) ;;
			notimpl) ;;
			refused) ;;
			yxdomain) ;;
			yxrrset) ;;
			nxrrset) ;;
			notauth) ;;
			notzone) ;;
			dsotypeni) ;;
			unassigned-12-15) ;;
			badvers|badsig) ;;
			badkey) ;;
			badtime) ;;
			badmode) ;;
			badname) ;;
			badalg) ;;
			badtrunc) ;;
			badcookie) ;;
			unassigned-24-3840) ;;
			reserved-3841-4095) ;;
			unassigned-4096-65534) ;;
			reserved-65535) ;;
			*) printf "\nInvalid --response-code. ">&2; print_usage_then_exit; ;;
		esac
	fi

	if [ -n "$IS_AUTHORITATIVE_ANSWER" ]; then
		case $IS_AUTHORITATIVE_ANSWER in
			yes) ;;
			no) ;;
			*) printf "\nInvalid --is-authoritative-answer. ">&2; print_usage_then_exit; ;;
		esac
	fi

	if [ -n "$IS_RESPONSE_TRUNCATED" ]; then
		case $IS_RESPONSE_TRUNCATED in
			yes) ;;
			no) ;;
			*) printf "\nInvalid --is-response-truncated. ">&2; print_usage_then_exit; ;;
		esac
	fi

	if [ -n "$IS_RECURSION_DESIRED" ]; then
		case $IS_RECURSION_DESIRED in
			yes) ;;
			no) ;;
			*) printf "\nInvalid --is-recursion-desired. ">&2; print_usage_then_exit; ;;
		esac
	fi

	if [ -n "$IS_RECURSION_AVAILABLE" ]; then
		case $IS_RECURSION_AVAILABLE in
			yes) ;;
			no) ;;
			*) printf "\nInvalid --is-recursion-available. ">&2; print_usage_then_exit; ;;
		esac
	fi

	if [ "$IS_AUTHENTIC_DATA" = "yes" ] && [ "$IS_DNSSEC_ENABLED" != "yes" ]; then
		printf "\nIf --is-authentic-data is yes, then --is-dnssec-enabled must also be yes. ">&2;
		print_usage_then_exit;
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

	if [ -n "$IS_AUTHENTIC_DATA" ]; then
		case $IS_AUTHENTIC_DATA in
			yes) ;;
			no) ;;
			*) printf "\nInvalid --is-authentic-data. ">&2; print_usage_then_exit; ;;
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

	if [ -n "$TOTAL_ANSWERS" ] && [ -n "$TOTAL_ANSWERS_MIN" ]; then
		printf "\nInvalid combination of --total-answers and --total-answers-min. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$TOTAL_ANSWERS" ] && [ -n "$TOTAL_ANSWERS_MAX" ]; then
		printf "\nInvalid combination of --total-answers and --total-answers-max. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$TOTAL_ANSWERS" ]; then
		if [ -z "$(echo $TOTAL_ANSWERS | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --total-answers (must be a 1-5 digit number) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_ANSWERS -lt 0 ]; then
			printf "\nInvalid --total-answers (must be 0 or greater) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_ANSWERS -gt 65535 ]; then
			printf "\nInvalid --total-answers (must be less than 65536) ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$TOTAL_ANSWERS_MIN" ]; then
		if [ -z "$(echo $TOTAL_ANSWERS_MIN | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --total-answers-min (must be a 1-5 digit number) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_ANSWERS_MIN -lt 0 ]; then
			printf "\nInvalid --total-answers-min (must be 0 or greater) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_ANSWERS_MIN -gt 65535 ]; then
			printf "\nInvalid --total-answers-min (must be less than 65536) ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$TOTAL_ANSWERS_MAX" ]; then
		if [ -z "$(echo $TOTAL_ANSWERS_MAX | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --total-answers-max (must be a 1-5 digit number) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_ANSWERS_MAX -lt 0 ]; then
			printf "\nInvalid --total-answers-max (must be 0 or greater) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_ANSWERS_MAX -gt 65535 ]; then
			printf "\nInvalid --total-answers-max (must be less than 65536) ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$TOTAL_AUTHORITY_RECORDS" ] && [ -n "$TOTAL_AUTHORITY_RECORDS_MIN" ]; then
		printf "\nInvalid combination of --total-authority-records and --total-authority-records-min. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$TOTAL_AUTHORITY_RECORDS" ] && [ -n "$TOTAL_AUTHORITY_RECORDS_MAX" ]; then
		printf "\nInvalid combination of --total-authority-records and --total-authority-records-max. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$TOTAL_AUTHORITY_RECORDS" ]; then
		if [ -z "$(echo $TOTAL_AUTHORITY_RECORDS | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --total-authority-records (must be a 1-5 digit number) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_AUTHORITY_RECORDS -lt 0 ]; then
			printf "\nInvalid --total-authority-records (must be 0 or greater) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_AUTHORITY_RECORDS -gt 65535 ]; then
			printf "\nInvalid --total-authority-records (must be less than 65536) ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$TOTAL_AUTHORITY_RECORDS_MIN" ]; then
		if [ -z "$(echo $TOTAL_AUTHORITY_RECORDS_MIN | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --total-authority-records-min (must be a 1-5 digit number) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_AUTHORITY_RECORDS_MIN -lt 0 ]; then
			printf "\nInvalid --total-authority-records-min (must be 0 or greater) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_AUTHORITY_RECORDS_MIN -gt 65535 ]; then
			printf "\nInvalid --total-authority-records-min (must be less than 65536) ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$TOTAL_AUTHORITY_RECORDS_MAX" ]; then
		if [ -z "$(echo $TOTAL_AUTHORITY_RECORDS_MAX | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --total-authority-records-max (must be a 1-5 digit number) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_AUTHORITY_RECORDS_MAX -lt 0 ]; then
			printf "\nInvalid --total-authority-records-max (must be 0 or greater) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_AUTHORITY_RECORDS_MAX -gt 65535 ]; then
			printf "\nInvalid --total-authority-records-max (must be less than 65536) ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$TOTAL_ADDITIONAL_RECORDS" ] && [ -n "$TOTAL_ADDITIONAL_RECORDS_MIN" ]; then
		printf "\nInvalid combination of --total-additional-records and --total-additional-records-min. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$TOTAL_ADDITIONAL_RECORDS" ] && [ -n "$TOTAL_ADDITIONAL_RECORDS_MAX" ]; then
		printf "\nInvalid combination of --total-additional-records and --total-additional-records-max. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$TOTAL_ADDITIONAL_RECORDS" ]; then
		if [ -z "$(echo $TOTAL_ADDITIONAL_RECORDS | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --total-additional-records (must be a 1-5 digit number) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_ADDITIONAL_RECORDS -lt 0 ]; then
			printf "\nInvalid --total-additional-records (must be 0 or greater) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_ADDITIONAL_RECORDS -gt 65535 ]; then
			printf "\nInvalid --total-additional-records (must be less than 65536) ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$TOTAL_ADDITIONAL_RECORDS_MIN" ]; then
		if [ -z "$(echo $TOTAL_ADDITIONAL_RECORDS_MIN | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --total-additional-records-min (must be a 1-5 digit number) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_ADDITIONAL_RECORDS_MIN -lt 0 ]; then
			printf "\nInvalid --total-additional-records-min (must be 0 or greater) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_ADDITIONAL_RECORDS_MIN -gt 65535 ]; then
			printf "\nInvalid --total-additional-records-min (must be less than 65536) ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$TOTAL_ADDITIONAL_RECORDS_MAX" ]; then
		if [ -z "$(echo $TOTAL_ADDITIONAL_RECORDS_MAX | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --total-additional-records-max (must be a 1-5 digit number) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_ADDITIONAL_RECORDS_MAX -lt 0 ]; then
			printf "\nInvalid --total-additional-records-max (must be 0 or greater) ">&2;
			print_usage_then_exit;
		fi

		if [ $TOTAL_ADDITIONAL_RECORDS_MAX -gt 65535 ]; then
			printf "\nInvalid --total-additional-records-max (must be less than 65536) ">&2;
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

printf "\\t\\t#Match OP Response (1)\n";
printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TYPE,1 1 \\\\\n";

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
if [ -n "$IS_AUTHORITATIVE_ANSWER" ]; then
	case $IS_AUTHORITATIVE_ANSWER in
		yes)
			printf "(yes)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_IS_AUTHORITATIVE_ANSWER,1 1 \\\\\n";
		;;
		no)
			printf "(no)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_IS_AUTHORITATIVE_ANSWER,1 0 \\\\\n";
		;;
	esac
else
	printf "\\t\\t#Preference for Authoritative Answer is unrestricted - consider the implications\n";
fi

printf "\\t#Match Response Truncated ";
if [ -n "$IS_RESPONSE_TRUNCATED" ]; then
	case $IS_RESPONSE_TRUNCATED in
		yes)
			printf "(yes)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_IS_RESPONSE_TRUNCATED,1 1 \\\\\n";
		;;
		no)
			printf "(no)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_IS_RESPONSE_TRUNCATED,1 0 \\\\\n";
		;;
	esac
else
	printf "\\t\\t#Preference for Response Truncation is unrestricted - consider the implications\n";
fi

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
if [ -n "$IS_RECURSION_AVAILABLE" ]; then
	case $IS_RECURSION_AVAILABLE in
		yes)
			printf "(yes)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_IS_RECURSION_AVAILABLE,1 1 \\\\\n";
		;;
		no)
			printf "(no)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_IS_RECURSION_AVAILABLE,1 0 \\\\\n";
		;;
	esac
else
	printf "\\t\\t#Preference for Recursion Available is unrestricted - consider the implications\n";
fi

printf "\\t#Match Reserved bit (always 0)\n";
printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_ZERO,1 0 \\\\\n";

if [ -n "$IS_AUTHENTIC_DATA" ]; then
	printf "\\t#Match Authentic Data ";
	case $IS_AUTHENTIC_DATA in
		yes)
			printf "(yes)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_IS_AUTHENTIC_DATA,1 1 \\\\\n";
		;;
		no)
			printf "(no)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_IS_AUTHENTIC_DATA,1 0 \\\\\n";
		;;
	esac
else
	if [ $IS_DNSSEC_ENABLED -eq 1 ]; then
		printf "\\t\\t#Preference for Authentic Data is unrestricted - consider the implications\n";
	else
		printf "\\t#DNSSEC is Disabled / The Authentic Data bit was originally reserved and should be 0\n";
		printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_IS_AUTHENTIC_DATA,1 0 \\\\\n";
	fi
fi

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
if [ -n "$RESPONSE_CODE" ]; then
	case $RESPONSE_CODE in
		noerror)
			printf "(no error)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 0 \\\\\n";
		;;
		formerr)
			printf "(format error)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 1 \\\\\n";
		;;
		servfail)
			printf "(server failure)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 2 \\\\\n";
		;;
		nxdomain)
			printf "(non-existent domain)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 3 \\\\\n";
		;;
		notimpl)
			printf "(not implemented)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 4 \\\\\n";
		;;
		refused)
			printf "(query refused)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 5 \\\\\n";
		;;
		yxdomain)
			printf "(name exists, when it should not)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 6 \\\\\n";
		;;
		yxrrset)
			printf "(rrset exists, when it should not)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 7 \\\\\n";
		;;
		nxrrset)
			printf "(rrset does not exist, when it should)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 8 \\\\\n";
		;;
		notauth)
			printf "(not authorized / server is not authoritative for the zone)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 9 \\\\\n";
		;;
		notzone)
			printf "(name not contained in zone)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 10 \\\\\n";
		;;
		dsotypeni)
			printf "(DSO_TYPE not implemented)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 11 \\\\\n";
		;;
		unassigned-12-15)
			printf "(unassigned RCODE 12-15)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 >= 12 \\\\\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 <= 15 \\\\\n";
		;;
		badvers|badsig)
			printf "(Bad OPT Version / TSIG Signature Failure)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 16 \\\\\n";
		;;
		badkey)
			printf "(Key not recognised)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 17 \\\\\n";
		;;
		badtime)
			printf "(Signature out of time window)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 18 \\\\\n";
		;;
		badmode)
			printf "(Bad TKEY Mode)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 19 \\\\\n";
		;;
		badname)
			printf "(Duplicate key name)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 20 \\\\\n";
		;;
		badalg)
			printf "(Algorithm not supported)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 21 \\\\\n";
		;;
		badtrunc)
			printf "(Bad Truncation)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 22 \\\\\n";
		;;
		badcookie)
			printf "(Bad/missing server cookie)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 23 \\\\\n";
		;;
		unassigned-24-3840)
			printf "(Unassigned RCODE 24-3840)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 >= 24 \\\\\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 <= 3840 \\\\\n";
		;;
		reserved-3841-4095)
			printf "(Reserved 3841-4095)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 >= 3841 \\\\\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 <= 4095 \\\\\n";
		;;
		unassigned-4096-65534)
			printf "(Unassigned 4096-65534)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 >= 4096 \\\\\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 <= 65534 \\\\\n";
		;;
		reserved-65535)
			printf "(Reserved, can be used ny Standards Allocation)\n";
			printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_RESPONSE_CODE,4 65535 \\\\\n";
		;;
	esac
else
	printf "\\t\\t#Preference for Response Code is unrestricted - consider the implications\n";
fi

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

printf "\\t\\t#Match Total Answers ";
if [ -n "$TOTAL_ANSWERS" ]; then
	printf "(exactly $TOTAL_ANSWERS)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_ANSWERS,16 $TOTAL_ANSWERS \\\\\n";

elif [ -n "$TOTAL_ANSWERS_MIN" ] && [ -z "$TOTAL_ANSWERS_MAX" ]; then
	printf "(minimum $TOTAL_ANSWERS_MIN)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_ANSWERS,16 >= $TOTAL_ANSWERS_MIN \\\\\n";

elif [ -z "$TOTAL_ANSWERS_MIN" ] && [ -n "$TOTAL_ANSWERS_MAX" ]; then
	printf "(maximum $TOTAL_ANSWERS_MAX)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_ANSWERS,16 <= $TOTAL_ANSWERS_MAX \\\\\n";

elif [ -z "$TOTAL_ANSWERS_MIN" ] && [ -n "$TOTAL_ANSWERS_MAX" ]
	printf "($TOTAL_ANSWERS_MIN-$TOTAL_ANSWERS_MAX)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_ANSWERS,16 >= $TOTAL_ANSWERS_MIN \\\\\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_ANSWERS,16 <= $TOTAL_ANSWERS_MAX \\\\\n";

fi

printf "\\t\\t#Match Total Authority Records ";
if [ -n "$TOTAL_AUTHORITY_RECORDS" ]; then
	printf "(exactly $TOTAL_AUTHORITY_RECORDS)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_AUTHORITY_RECORDS,16 $TOTAL_AUTHORITY_RECORDS \\\\\n";

elif [ -n "$TOTAL_AUTHORITY_RECORDS_MIN" ] && [ -z "$TOTAL_AUTHORITY_RECORDS_MAX" ]; then
	printf "(minimum $TOTAL_AUTHORITY_RECORDS_MIN)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_AUTHORITY_RECORDS,16 >= $TOTAL_AUTHORITY_RECORDS_MIN \\\\\n";

elif [ -z "$TOTAL_AUTHORITY_RECORDS_MIN" ] && [ -n "$TOTAL_AUTHORITY_RECORDS_MAX" ]; then
	printf "(maximum $TOTAL_AUTHORITY_RECORDS_MAX)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_AUTHORITY_RECORDS,16 <= $TOTAL_AUTHORITY_RECORDS_MAX \\\\\n";

elif [ -z "$TOTAL_AUTHORITY_RECORDS_MIN" ] && [ -n "$TOTAL_AUTHORITY_RECORDS_MAX" ]
	printf "($TOTAL_AUTHORITY_RECORDS_MIN-$TOTAL_AUTHORITY_RECORDS_MAX)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_AUTHORITY_RECORDS,16 >= $TOTAL_AUTHORITY_RECORDS_MIN \\\\\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_AUTHORITY_RECORDS,16 <= $TOTAL_AUTHORITY_RECORDS_MAX \\\\\n";

fi

printf "\\t\\t#Match Total Additional Records ";
if [ -n "$TOTAL_ADDITIONAL_RECORDS" ]; then
	printf "(exactly $TOTAL_ADDITIONAL_RECORDS)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_ADDITIONAL_RECORDS,16 $TOTAL_ADDITIONAL_RECORDS \\\\\n";

elif [ -n "$TOTAL_ADDITIONAL_RECORDS_MIN" ] && [ -z "$TOTAL_ADDITIONAL_RECORDS_MAX" ]; then
	printf "(minimum $TOTAL_ADDITIONAL_RECORDS_MIN)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_ADDITIONAL_RECORDS,16 >= $TOTAL_ADDITIONAL_RECORDS_MIN \\\\\n";

elif [ -z "$TOTAL_ADDITIONAL_RECORDS_MIN" ] && [ -n "$TOTAL_ADDITIONAL_RECORDS_MAX" ]; then
	printf "(maximum $TOTAL_ADDITIONAL_RECORDS_MAX)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_ADDITIONAL_RECORDS,16 <= $TOTAL_ADDITIONAL_RECORDS_MAX \\\\\n";

elif [ -z "$TOTAL_ADDITIONAL_RECORDS_MIN" ] && [ -n "$TOTAL_ADDITIONAL_RECORDS_MAX" ]
	printf "($TOTAL_ADDITIONAL_RECORDS_MIN-$TOTAL_ADDITIONAL_RECORDS_MAX)\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_ADDITIONAL_RECORDS,16 >= $TOTAL_ADDITIONAL_RECORDS_MIN \\\\\n";
	printf "\\t\\t@$BIT_OFFSET,$BIT_OFFSET_TOTAL_ADDITIONAL_RECORDS,16 <= $TOTAL_ADDITIONAL_RECORDS_MAX \\\\\n";

fi

exit 0;
