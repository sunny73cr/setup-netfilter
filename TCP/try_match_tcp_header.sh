#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_VALIDATE_PORT="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_port_or_range_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_PORT ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_PORT\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_description() {
	printf "A program that prints part of an NFT rule 'match' section. The match intends to identify TCP headers.\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "Dependencies: \n">&2;
	printf "printf\n">&2;
	printf "echo\n">&2;
	printf "grep\n">&2;
	printf "cut\n">&2;
	printf "$DEPENDENCY_PATH_VALIDATE_PORT\n">&2;
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
	printf " Optional: --offset-marker th|ih\n">&2;
	printf "  here, th means transport header (or the usual place of the UDP header).\n">&2;
	printf "  this is commonly what you are looking to match, unless the UDP header\n">&2;
	printf "  is part of the content in an encapsulating protocol (See ICMP Destination Unreachable).\n">&2;
	printf "  for these encapsulating protocols, the offset marker should be ih; with a predefined \"offset-header-begin\".\n">&2;
	printf "\n">&2;
	printf " Optional: --offset-header-begin X (where x is a number from 0-65536)\n">&2;
	printf "  this indicates to the program where the beginning of the UDP header is.\n">&2;
	printf "  this is important for wncapsulating protocols such as an ICMP Destination Unreachable packet;\n">&2;
	printf "  otherwise, the header will simply not match.\n">&2;
	printf "\n">&2;
	printf " where --offset-marker is not provided, the default is \"th\" (the standard place to match a UDP header).\n">&2;
	printf " if --offset-header-begin is not provided, it will default to 0. If --offset marker is \"ih\", it will likely fail to match.\n">&2;
	printf "\n">&2;
	printf " Optional: --source-port x|x-x (where x is 1-65535)\n">&2;
	printf "  the source port. Depending on the IPV4/6 header, this could be either the server or client port.\n">&2;
	printf "  the source port argument may be a range of ports delmited by a hyphen (eg. x-x). The ports can be in ascending or descending order.\n">&2;
	printf "\n">&2;
	printf " Optional: --destination-port x|x-x (where x is 1-65535)\n">&2;
	printf "  the destination port. Depending on the IPV4/6 header, this could be either the server or client port.\n">&2;
	printf "  the destination port argument may be a range of ports delmited by a hyphen (eg. x-x). The ports can be in ascending or descending order.\n">&2;
	printf "\n">&2;
	printf " Optional: --sequence-number x (where x is 0-4,294,967,295)\n">&2;
	printf "  Restrict the sequence number to an exact identifier.\n">&2;
	printf "  this signifies the identifier of the 'frame' or 'window' in the TCP session.\n">&2;
	printf "  it should be random, so matching this field is of limited use.\n">&2;
	printf "\n">&2;
	printf " Optional: --sequence-number-min x (where x is 0-4,294,967,295)\n">&2;
	printf "  Restrict the sequence number to a minimum.\n">&2;
	printf "\n">&2;
	printf " Optional: --sequence-number-max x (where x is 0-4,294,967,295)\n">&2;
	printf "  Restrict the sequence number to a maximum.\n">&2;
	printf "\n">&2;
	printf " You must not combine --sequence-number with --sequence-number-min or --sequence-number-max\n">&2;
	printf " You are not required to supply both --sequence-number-min and --sequence-number-max\n">&2;
	printf " When supplied together, --sequence-number-min must be less than --sequence-number-max\n">&2;
	printf "\n">&2;
	printf " Optional: --acknowledgement-number x (where x is 0-4,294,967,295)\n">&2;
	printf "  Restrict the acknowledgement number to an exact identifier.\n">&2;
	printf "  presence signifies that this packet is an acknowledgement of a previous sequence number.\n">&2;
	printf "  it is 'as' random as the sequence number, so matching this field is of limited use.\n">&2;
	printf "\n">&2;
	printf " Optional: --acknowledgement-number-min x (where x is 0-4,294,967,295)\n">&2;
	printf "  Restrict the acknowledgement number to a minimum.\n">&2;
	printf "\n">&2;
	printf " Optional: --acknowledgement-number-max x (where x is 0-4,294,967,295)\n">&2;
	printf "  Restrict the acknowledgement number to a maximum.\n">&2;
	printf "\n">&2;
	printf " You must not combine --acknowledgement-number with --acknowledgement-number-min or --acknowledgement-number-max\n">&2;
	printf " You are not required to supply both --acknowledgement-number-min and --acknowledgement-number-max\n">&2;
	printf " When supplied together, --acknowledgement-number-min must be less than --acknowledgement-number-max\n">&2;
	printf "\n">&2;
	printf " Optional: --data-offset x (where x is 5-8)\n">&2;
	printf "  this field signifies the length in (32-bit) words of the TCP header.\n">&2;
	printf "\n">&2;
	printf " Optional: --data-offset-min x (where x is 5-8)\n">&2;
	printf "  Restrict the data offset to a minimum.\n">&2;
	printf "\n">&2;
	printf " Optional: --data-offset-max x (where x is 5-8)\n">&2;
	printf "  Restrict the data offset to a maximum.\n">&2;
	printf "\n">&2;
	printf " You must not combine --data-offset with --data-offset-min or --data-offset-max\n">&2;
	printf " You are not required to supply both --data-offset-min and --data-offset-max\n">&2;
	printf " When supplied together, --data-offset-min must be less than --data-offset-max\n">&2;
	printf "\n">&2;
	printf " Optional: --flags-on [CWR|ECE|URG|ACK|PSH|RST|SYN|FIN]\n">&2;
	printf "  Provide a csv of TCP flags that are enabled for this packet.\n">&2;
	printf "\n">&2;
	printf " Optional: --flags-off [CWR|ECE|URG|ACK|PSH|RST|SYN|FIN]\n">&2;
	printf "  Provide a csv of TCP flags that are disabled for this packet.\n">&2;
	printf "\n">&2;
	printf " Absence of an 'on' or 'off' preference for a flag results in no checks on that flag.\n">&2;
	printf "\n">&2;
	printf " Optional: --window x (where x is 0-65535)\n">&2;
	printf "  The exact length or 'base' of the TCP segment. Scaling of the base is performed with the window scaling TCP option.\n">&2;
	printf "  In modern networks, Window Scaling is common, so matching an exact value is not reliable.\n">&2;
	printf "\n">&2;
	printf " Optional: --window-min x (where x is 0-65535)\n">&2;
	printf "  Restrict the window length or base to a minimum.\n">&2;
	printf "\n">&2;
	printf " Optional: --window-max x (where x is 0-65535)\n">&2;
	printf "  Restrict the window length or base to a maximum.\n">&2;
	printf "\n">&2;
	printf " You must not combine --window with --window-min or --window-max\n">&2;
	printf " You are not required to supply both --window-min and --window-max\n">&2;
	printf " When supplied together, --window-min must be less than --window-max\n">&2;
	printf "\n">&2;
	printf " Optional: --checksum x (where x is 0-65535)\n">&2;
	printf "  Restrict the checksum to a specific value.\n">&2;
	printf "  this could be beneficial if you know the checksum of a previously sent/received packet.\n">&2;
	printf "\n">&2;
	printf " Optional: --checksum-min x (where x is 0-65535)\n">&2;
	printf "  Restrict the checksum to a minimum.\n">&2;
	printf "\n">&2;
	printf " Optional: --checksum-max x (where x is 0-65535)\n">&2;
	printf "  Restrict the checksum to a maximum.\n">&2;
	printf "\n">&2;
	printf " You must not combine --checksum with --checksum-min or --checksum-max\n">&2;
	printf " You are not required to supply both --checksum-min and --checksum-max\n">&2;
	printf " When supplied together, --checksum-min must be less than --checksum-max\n">&2;
	printf "\n">&2;
	printf " Optional: --urgent-pointer x (where x is 0-65535)\n">&2;
	printf "  Restrict the urgent pointer to a specific offset.\n">&2;
	printf "  the offset from the sequence number in this segment where some 'urgent' data begins.\n">&2;
	printf "  It is only valid when the URG flag is set.\n">&2;
	printf "\n">&2;
	printf " Optional: --urgent-pointer-min x (where x is 0-65535)\n">&2;
	printf "  Restrict the urgent-pointer to a minimum.\n">&2;
	printf "\n">&2;
	printf " Optional: --urgent-pointer-max x (where x is 0-65535)\n">&2;
	printf "  Restrict the urgent-pointer to a maximum.\n">&2;
	printf "\n">&2;
	printf " You must not combine --urgent-pointer with --urgent-pointer-min or --urgent-pointer-max\n">&2;
	printf " You are not required to supply both --urgent-pointer-min and --urgent-pointer-max\n">&2;
	printf " When supplied together, --urgent-pointer-min must be less than --urgent-pointer-max\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf "  this causes the program to skip validating inputs (if you know they are valid).\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validation\n">&2;
	printf "  this causes the program to exit after validating inputs.\n">&2;
	printf "\n">&2;
	printf "EOF">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
OFFSET_MARKER="th";
OFFSET_HEADER_BEGIN=0;
SOURCE_PORT="";
SOURCE_PORT_BEGIN=0;
SOURCE_PORT_END=0;
SOURCE_PORT_IS_RANGE=0;
DESTINATION_PORT="";
DESTINATION_PORT_BEGIN=0;
DESTINATION_PORT_END=0;
DESTINATION_PORT_IS_RANGE=0;
SEQUENCE_NUMBER="";
SEQUENCE_NUMBER_MIN="";
SEQUENCE_NUMBER_MAX="";
ACKNOWLEDGEMENT_NUMBER="";
ACKNOWLEDGEMENT_NUMBER_MIN="";
ACKNOWLEDGEMENT_NUMBER_MAX="";
DATA_OFFSET="";
DATA_OFFSET_MIN="";
DATA_OFFSET_MAX="";
FLAGS_SET="";
FLAGS_SET_CWR=0;
FLAGS_SET_ECE=0;
FLAGS_SET_URG=0;
FLAGS_SET_ACK=0;
FLAGS_SET_PSH=0;
FLAGS_SET_RST=0;
FLAGS_SET_SYN=0;
FLAGS_SET_FIN=0;
FLAGS_UNSET="";
FLAGS_UNSET_CWR=0;
FLAGS_UNSET_ECE=0;
FLAGS_UNSET_URG=0;
FLAGS_UNSET_ACK=0;
FLAGS_UNSET_PSH=0;
FLAGS_UNSET_RST=0;
FLAGS_UNSET_SYN=0;
FLAGS_UNSET_FIN=0;
WINDOW="";
WINDOW_MIN="";
WINDOW_MAX="";
CHECKSUM="";
CHECKSUM_MIN="";
CHECKSUM_MAX="";
URGENT_POINTER="";
URGENT_POINTER_MIN="";
URGENT_POINTER_MAX="";

#FLAGS:
SKIP_VALIDATION=0;
ONLY_VALIDATION=0;

while true; do
	case $1 in
		#Approach to parsing arguments:
		#If the length of 'all arguments' is less than 2 (shift reduces this number),
		#since this is an argument parameter and requires a value; the program cannot continue.
		#Else, if the argument was provided, and its 'value' is empty; the program cannot continue.
		#Else, assign the argument, and shift 2 (both the argument indicator and its value / move next)

		--offset-marker)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				OFFSET_MARKER=$2;
				shift 2;
			fi
		;;

		--offset-header-begin)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				OFFSET_HEADER_BEGIN=$2;
				shift 2;
			fi
		;;

		--source-port)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				SOURCE_PORT=$2;
				shift 2;
			fi
		;;

		--destination-port)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				DESTINATION_PORT=$2;
				shift 2;
			fi
		;;

		--sequence-number)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				SEQUENCE_NUMBER=$2;
				shift 2;
			fi
		;;

		--sequence-number-min)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				SEQUENCE_NUMBER_MIN=$2;
				shift 2;
			fi
		;;

		--sequence-number-max)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				SEQUENCE_NUMBER_MAX=$2;
				shift 2;
			fi
		;;

		--acknowledgement-number)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				ACKNOWLEDGEMENT_NUMBER=$2;
				shift 2;
			fi
		;;

		--acknowledgement-number-min)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				ACKNOWLEDGEMENT_NUMBER_MIN=$2;
				shift 2;
			fi
		;;

		--acknowledgement-number-max)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				ACKNOWLEDGEMENT_NUMBER_MAX=$2;
				shift 2;
			fi
		;;

		--data-offset)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				DATA_OFFSET=$2;
				shift 2;
			fi
		;;

		--data-offset-min)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				DATA_OFFSET_MIN=$2;
				shift 2;
			fi
		;;

		--data-offset-max)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				DATA_OFFSET_MAX=$2;
				shift 2;
			fi
		;;

		--flags-on)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				FLAGS_SET=$2;
				shift 2;
			fi
		;;

		--flags-off)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				FLAGS_UNSET=$2;
				shift 2;
			fi
		;;

		--window)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				WINDOW=$2;
				shift 2;
			fi
		;;

		--window-min)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				WINDOW_MIN=$2;
				shift 2;
			fi
		;;

		--window-max)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				WINDOW_MAX=$2;
				shift 2;
			fi
		;;

		--urgent-pointer)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				URGENT_POINTER=$2;
				shift 2;
			fi
		;;

		--urgent-pointer-min)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				URGENT_POINTER_MIN=$2;
				shift 2;
			fi
		;;

		--urgent-pointer-max)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				URGENT_POINTER_MAX=$2;
				shift 2;
			fi
		;;

		--checksum)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				CHECKSUM=$2;
				shift 2;
			fi
		;;

		--checksum-min)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				CHECKSUM_MIN=$2;
				shift 2;
			fi
		;;

		--checksum-max)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				CHECKSUM_MAX=$2;
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

		--only-validation)
			ONLY_VALIDATION=1;
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
if [ $SKIP_VALIDATION -eq 1 ] && [ $ONLY_VALDIATION -eq 1 ]; then exit 0; fi

if [ $SKIP_VALIDATION -eq 0 ]; then
	if [ -n "$OFFSET_MARKER" ]; then
		case $OFFSET_MARKER in
			th) ;;
			ih) ;;
			*) printf "\nInvalid --offset-marker. ">&2; print_usage_then_exit; ;;
		esac
	fi

	if [ -n "$OFFSET_HEADER_BEGIN" ]; then
		if [ -z "$(echo $OFFSET_HEADER_BEGIN | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --offset-header-begin (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $OFFSET_HEADER_BEGIN -lt 0 ]; then
			printf "\nInvalid --offset-header-begin (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $OFFSET_HEADER_BEGIN -gt 65536 ]; then
			printf "\nInvalid --offset-header-begin (must be less than 65537). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$SOURCE_PORT" ]; then
		if [ -n "$(echo $SOURCE_PORT | grep '[0-9]\{1,5\}-[0-9]{1,5}')" ]; then
			SOURCE_PORT_IS_RANGE=1;
			SOURCE_PORT_BEGIN=$(echo $SOURCE_PORT | cut -d '-' -f 1);
			SOURCE_PORT_END=$(echo $SOURCE_PORT | cut -d '-' -f 2);

			#Check they are numbers
			if [ -z "$(echo $SOURCE_PORT_BEGIN | grep '[0-9]\{1,5\}')" ]; then
				printf "\nInvalid --source-port (range start must be a 1-5 digit number). ">&2;
				print_usage_then_exit;
			fi

			if [ -z "$(echo $SOURCE_PORT_END | grep '[0-9]\{1,5\}')" ]; then
				printf "\nInvalid --source-port (range end must be a 1-5 digit number). ">&2;
				print_usage_then_exit;
			fi

			#Swap them if not increasing order
			if [ $SOURCE_PORT_BEGIN -gt $SOURCE_PORT_END ]; then
				TEMP=$SOURCE_PORT_BEGIN;
				SOURCE_PORT_BEGIN=$SOURCE_PORT_END;
				SOURCE_PORT_END=$TEMP;
			fi

			#Check bounds
			if [ $SOURCE_PORT_BEGIN -lt 1 ]; then
				printf "\nInvalid --source-port (range start must be greater than 0). ">&2;
				print_usage_then_exit;
			fi

			if [ $SOURCE_PORT_END -gt 65535 ]; then
				printf "\nInvalid --source-port (range end must be less than 65535). ">&2;
				print_usage_then_exit;
			fi

			#If equal, compress
			if [ $SOURCE_PORT_BEGIN -eq $SOURCE_PORT_END ]; then
				SOURCE_PORT_IS_RANGE=0;
				SOURCE_PORT=$SOURCE_PORT_BEGIN;
				SOURCE_PORT_BEGIN=0;
				SOURCE_PORT_END=0;
			fi
		else
			if [ -z "$(echo $SOURCE_PORT | grep '[0-9]\{1,5\}')" ]; then
				printf "\nInvalid --source-port (must be a 1-5 digit number). ">&2;
				print_usage_then_exit;
			fi

			if [ $SOURCE_PORT -lt 1 ]; then
				printf "\nInvalid --source-port (must be greater than 0). ">&2;
				print_usage_then_exit;
			fi

			if [ $SOURCE_PORT -gt 65535 ]; then
				printf "\nInvalid --source-port (must be less than 65536). ">&2;
				print_usage_then_exit;
			fi
		fi
	fi

	if [ -n "$DESTINATION_PORT" ]; then
		if [ -n "$(echo $DESTINATION_PORT | grep '[0-9]\{1,5\}-[0-9]\{1,5\}')" ]; then
			DESTINATION_PORT_IS_RANGE=1;
			DESTINATION_PORT_BEGIN=$(echo $DESTINATION_PORT | cut -d '-' -f 1);
			DESTINATION_PORT_END=$(echo $DESTINATION_PORT | cut -d '-' -f 2);

			#Check they are numbers
			if [ -z "$(echo $DESTINATION_PORT_BEGIN | grep '[0-9]\{1,5\}')" ]; then
				printf "\nInvalid --destination-port (range start must be a 1-5 digit number). ">&2;
				print_usage_then_exit;
			fi

			if [ -z "$(echo $DESTINATION_PORT_END | grep '[0-9]\{1,5\}')" ]; then
				printf "\nInvalid --destination-port (range end must be a 1-5 digit number). ">&2;
				print_usage_then_exit;
			fi

			#Swap them if not increasing order
			if [ $DESTINATION_PORT_BEGIN -gt $DESTINATION_PORT_END ]; then
				TEMP=$DESTINATION_PORT_BEGIN;
				DESTINATION_PORT_BEGIN=$DESTINATION_PORT_END;
				DESTINATION_PORT_END=$TEMP;
			fi

			#Check bounds
			if [ $DESTINATION_PORT_BEGIN -lt 1 ]; then
				printf "\nInvalid --destination-port (range start must be greater than 0). ">&2;
				print_usage_then_exit;
			fi

			if [ $DESTINATION_PORT_END -gt 65535 ]; then
				printf "\nInvalid --destination-port (range end must be less than 65535). ">&2;
				print_usage_then_exit;
			fi

			#If equal, compress
			if [ $DESTINATION_PORT_BEGIN -eq $DESTINATION_PORT_END ]; then
				DESTINATION_PORT_IS_RANGE=0;
				DESTINATION_PORT=$DESTINATION_PORT_BEGIN;
				DESTINATION_PORT_BEGIN=0;
				DESTINATION_PORT_END=0;
			fi
		else
			if [ -z "$(echo $DESTINATION_PORT | grep '[0-9]\{1,5\}')" ]; then
				printf "\nInvalid --destination-port (must be a 1-5 digit number). ">&2;
				print_usage_then_exit;
			fi

			if [ $DESTINATION_PORT -lt 1 ]; then
				printf "\nInvalid --destination-port (must be greater than 0). ">&2;
				print_usage_then_exit;
			fi

			if [ $DESTINATION_PORT -gt 65535 ]; then
				printf "\nInvalid --destination-port (must be less than 65536). ">&2;
				print_usage_then_exit;
			fi
		fi
	fi

	if [ -n "$SEQUENCE_NUMBER" ] && [ -n "$SEQUENCE_NUMBER_MIN" ]; then
		printf "\nInvalid combination of --sequence-number and --sequence-number-min. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$SEQUENCE_NUMBER" ] && [ -n "$SEQUENCE_NUMBER_MAX" ]; then
		printf "\nInvalid combination of --sequence-number and --sequence-number-max. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$SEQUENCE_NUMBER" ]; then
		if [ -z "$(echo $SEQUENCE_NUMBER | grep '[0-9]\{1,10\}')" ]; then
			printf "\nInvalid --sequence-number (must be a 1-10 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $SEQUENCE_NUMBER -lt 0 ]; then
			printf "\nInvalid --sequence-number (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $SEQUENCE_NUMBER -gt 4294967295 ]; then
			printf "\nInvalid --sequence-number (must be less than 4,294,967,296). ">&2;
			print_usage_then_exit;
		fi
	fi

	SEQUENCE_NUMBER_MIN_IS_VALID=0;
	if [ -n "$SEQUENCE_NUMBER_MIN" ]; then
		if [ -z "$(echo $SEQUENCE_NUMBER_MIN | grep '[0-9]\{1,10\}')" ]; then
			printf "\nInvalid --sequence-number-min (must be a 1-10 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $SEQUENCE_NUMBER_MIN -lt 0 ]; then
			printf "\nInvalid --sequence-number-min (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $SEQUENCE_NUMBER_MIN -gt 4294967295 ]; then
			printf "\nInvalid --sequence-number-min (must be less than 4,294,967,296). ">&2;
			print_usage_then_exit;
		fi

		SEQUENCE_NUMBER_MIN_IS_VALID=1;
	fi

	SEQUENCE_NUMBER_MAX_IS_VALID=0;
	if [ -n "$SEQUENCE_NUMBER_MAX" ]; then
		if [ -z "$(echo $SEQUENCE_NUMBER_MAX | grep '[0-9]\{1,10\}')" ]; then
			printf "\nInvalid --sequence-number-max (must be a 1-10 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $SEQUENCE_NUMBER_MAX -lt 0 ]; then
			printf "\nInvalid --sequence-number-max (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $SEQUENCE_NUMBER_MAX -gt 4294967295 ]; then
			printf "\nInvalid --sequence-number-max (must be less than 4,294,967,296). ">&2;
			print_usage_then_exit;
		fi

		SEQUENCE_NUMBER_MAX_IS_VALID=1;
	fi

	if [ $SEQUENCE_NUMBER_MIN_IS_VALID -eq 1 ] && [ $SEQUENCE_NUMBER_MAX_IS_VALID -eq 1 ] && [ $SEQUENCE_NUMBER_MIN -ge $SEQUENCE_NUMBER_MAX ]; then
		printf "\nInvalid --sequence-number-min or --sequence-number-max (minimum must be less than maximum). ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$ACKNOWLEDGEMENT_NUMBER" ] && [ -n "$ACKNOWLEDGEMENT_NUMBER_MIN" ]; then
		printf "\nInvalid combination of --acknowledgement-number and --acknowledgement-number-min. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$ACKNOWLEDGEMENT_NUMBER" ] && [ -n "$ACKNOWLEDGEMENT_NUMBER_MAX" ]; then
		printf "\nInvalid combination of --acknowledgement-number and --acknowledgement-number-max. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$ACKNOWLEDGEMENT_NUMBER" ]; then
		if [ -z "$(echo $ACKNOWLEDGEMENT_NUMBER | grep '[0-9]\{1,10\}')" ]; then
			printf "\nInvalid --acknowledgement-number (must be a 1-10 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $ACKNOWLEDGEMENT_NUMBER -lt 0 ]; then
			printf "\nInvalid --acknowledgement-number (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $ACKNOWLEDGEMENT_NUMBER -gt 4294967295 ]; then
			printf "\nInvalid --acknowledgement-number (must be less than 4,294,967,296). ">&2;
			print_usage_then_exit;
		fi
	fi

	ACKNOWLEDGEMENT_NUMBER_MIN_IS_VALID=0;
	if [ -n "$ACKNOWLEDGEMENT_NUMBER_MIN" ]; then
		if [ -z "$(echo $ACKNOWLEDGEMENT_NUMBER_MIN | grep '[0-9]\{1,10\}')" ]; then
			printf "\nInvalid --acknowledgement-number-min (must be a 1-10 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $ACKNOWLEDGEMENT_NUMBER_MIN -lt 0 ]; then
			printf "\nInvalid --acknowledgement-number-min (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $ACKNOWLEDGEMENT_NUMBER_MIN -gt 4294967295 ]; then
			printf "\nInvalid --acknowledgement-number-min (must be less than 4,294,967,296). ">&2;
			print_usage_then_exit;
		fi

		ACKNOWLEDGEMENT_NUMBER_MIN_IS_VALID=1;
	fi

	ACKNOWLEDGEMENT_NUMBER_MAX_IS_VALID=0;
	if [ -n "$ACKNOWLEDGEMENT_NUMBER_MAX" ]; then
		if [ -z "$(echo $ACKNOWLEDGEMENT_NUMBER_MAX | grep '[0-9]\{1,10\}')" ]; then
			printf "\nInvalid --acknowledgement-number-max (must be a 1-10 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $ACKNOWLEDGEMENT_NUMBER_MAX -lt 0 ]; then
			printf "\nInvalid --acknowledgement-number-max (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $ACKNOWLEDGEMENT_NUMBER_MAX -gt 4294967295 ]; then
			printf "\nInvalid --acknowledgement-number-max (must be less than 4,294,967,296). ">&2;
			print_usage_then_exit;
		fi

		ACKNOWLEDGEMENT_NUMBER_MAX_IS_VALID=1;
	fi

	if [ $ACKNOWLEDGEMENT_NUMBER_MIN_IS_VALID -eq 1 ] && [ $ACKNOWLEDGEMENT_NUMBER_MAX_IS_VALID -eq 1 ] && [ $ACKNOWLEDGEMENT_NUMBER_MIN -ge $ACKNOWLEDGEMENT_NUMBER_MAX ]; then
		printf "\nInvalid --acknowledgement-number-min or --acknowledgement-number-max (minimum must be less than maximum). ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$DATA_OFFSET" ] && [ -n "$DATA_OFFSET_MIN" ]; then
		printf "\nInvalid combination of --data-offset and --data-offset-min. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$DATA_OFFSET" ] && [ -n "$DATA_OFFSET_MAX" ]; then
		printf "\nInvalid combination of --data-offset and --data-offset-max. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$DATA_OFFSET" ]; then
		if [ -z "$(echo $DATA_OFFSET | grep '[0-9]\{1,2\}')" ]; then
			printf "\nInvalid --data-offset (must be a 1-2 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $DATA_OFFSET -lt 0 ]; then
			printf "\nInvalid --data-offset (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $DATA_OFFSET -gt 8 ]; then
			printf "\nInvalid --data-offset (must be less than 9). ">&2;
			print_usage_then_exit;
		fi
	fi

	DATA_OFFSET_MIN_IS_VALID=0;
	if [ -n "$DATA_OFFSET_MIN" ]; then
		if [ -z "$(echo $DATA_OFFSET_MIN | grep '[0-9]\{1,2\}')" ]; then
			printf "\nInvalid --data-offset-min (must be a 1-2 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $DATA_OFFSET_MIN -lt 0 ]; then
			printf "\nInvalid --data-offset-min (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $DATA_OFFSET_MIN -gt 8 ]; then
			printf "\nInvalid --data-offset-min (must be less than 9). ">&2;
			print_usage_then_exit;
		fi

		DATA_OFFSET_MIN_IS_VALID=1;
	fi

	DATA_OFFSET_MAX_IS_VALID=0;
	if [ -n "$DATA_OFFSET_MAX" ]; then
		if [ -z "$(echo $DATA_OFFSET_MAX | grep '[0-9]\{1,2\}')" ]; then
			printf "\nInvalid --data-offset-max (must be a 1-2 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $DATA_OFFSET_MAX -lt 0 ]; then
			printf "\nInvalid --data-offset-max (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $DATA_OFFSET_MAX -gt 8 ]; then
			printf "\nInvalid --data-offset-max (must be less than 9). ">&2;
			print_usage_then_exit;
		fi

		DATA_OFFSET_MAX_IS_VALID=1;
	fi

	if [ $DATA_OFFSET_MIN_IS_VALID -eq 1 ] && [ $DATA_OFFSET_MAX_IS_VALID -eq 1 ] && [ $DATA_OFFSET_MIN -ge $DATA_OFFSET_MAX ]; then
		printf "\nInvalid --data-offset-min or --data-offset-max (minimum must be less than maximum). ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$FLAGS_SET" ]; then
		if [ -n "$(echo $FLAGS_SET | grep '\([CWR|ECE|URG|ACK|PSH|REST|SYN|FIN],\)\{1,7\},[CWR|ECE|URG|ACK|PSH|REST|SYN|FIN]')" ]; then
			#multiple flags
			i=1;
			while true; do
				FLAG=$(echo $FLAGS_SET | cut -d ',' -f $i);
				if [ -z "$FLAG" ]; then break; fi

				case $FLAG in
					CWR) FLAGS_SET_CWR=1; ;;
					ECE) FLAGS_SET_ECE=1; ;;
					URG) FLAGS_SET_URG=1; ;;
					ACK) FLAGS_SET_ACK=1; ;;
					PSH) FLAGS_SET_PSH=1; ;;
					RST) FLAGS_SET_RST=1; ;;
					SYN) FLAGS_SET_SYN=1; ;;
					FIN) FLAGS_SET_FIN=1; ;;
					*) printf "\nInvalid --flags-on (flag \#$i). ">&2; print_usage_then_exit; ;;
				esac

				i=$(($i+1));
			done;
		elif [ -n "$(echo $FLAGS_SET | grep '[CWR|ECE|URG|ACK|PSH|REST|SYN|FIN]')" ]
			#a flag
			case $FLAGS_SET in
				CWR) FLAGS_SET_CWR=1; ;;
				ECE) FLAGS_SET_ECE=1; ;;
				URG) FLAGS_SET_URG=1; ;;
				ACK) FLAGS_SET_ACK=1; ;;
				PSH) FLAGS_SET_PSH=1; ;;
				RST) FLAGS_SET_RST=1; ;;
				SYN) FLAGS_SET_SYN=1; ;;
				FIN) FLAGS_SET_FIN=1; ;;
				*) printf "\nInvalid --flags-on. ">&2; print_usage_then_exit; ;;
			esac
		else
			printf "\nInvalid --flags-on. ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$FLAGS_UNSET" ]; then
		if [ -n "$(echo $FLAGS_UNSET | grep '\([CWR|ECE|URG|ACK|PSH|REST|SYN|FIN],\)\{1,7\},[CWR|ECE|URG|ACK|PSH|REST|SYN|FIN]')" ]; then
			#multiple flags
			i=1;
			while true; do
				FLAG=$(echo $FLAGS_UNSET | cut -d ',' -f $i);
				if [ -z "$FLAG" ]; then break; fi

				case $FLAG in
					CWR) FLAGS_UNSET_CWR=1; ;;
					ECE) FLAGS_UNSET_ECE=1; ;;
					URG) FLAGS_UNSET_URG=1; ;;
					ACK) FLAGS_UNSET_ACK=1; ;;
					PSH) FLAGS_UNSET_PSH=1; ;;
					RST) FLAGS_UNSET_RST=1; ;;
					SYN) FLAGS_UNSET_SYN=1; ;;
					FIN) FLAGS_UNSET_FIN=1; ;;
					*) printf "\nInvalid --flags-off (flag \#$i). ">&2; print_usage_then_exit; ;;
				esac

				i=$(($i+1));
			done;
		elif [ -n "$(echo $FLAGS_UNSET | grep '[CWR|ECE|URG|ACK|PSH|REST|SYN|FIN]')" ]
			#a flag
			case $FLAGS_UNSET in
				CWR) FLAGS_UNSET_CWR=1; ;;
				ECE) FLAGS_UNSET_ECE=1; ;;
				URG) FLAGS_UNSET_URG=1; ;;
				ACK) FLAGS_UNSET_ACK=1; ;;
				PSH) FLAGS_UNSET_PSH=1; ;;
				RST) FLAGS_UNSET_RST=1; ;;
				SYN) FLAGS_UNSET_SYN=1; ;;
				FIN) FLAGS_UNSET_FIN=1; ;;
				*) printf "\nInvalid --flags-off. ">&2; print_usage_then_exit; ;;
			esac
		else
			printf "\nInvalid --flags-off. ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ $FLAGS_SET_CWR -eq 1 ] && [ $FLAGS_UNSET_CWR -eq 1 ]; then
		printf "\nInvalid flags: CWR cannot be both set and unset. ">&2;
		print_usage_then_exit;
	fi

	if [ $FLAGS_SET_ECE -eq 1 ] && [ $FLAGS_UNSET_ECE -eq 1 ]; then
		printf "\nInvalid flags: ECE cannot be both set and unset. ">&2;
		print_usage_then_exit;
	fi

	if [ $FLAGS_SET_URG -eq 1 ] && [ $FLAGS_UNSET_URG -eq 1 ]; then
		printf "\nInvalid flags: URG cannot be both set and unset. ">&2;
		print_usage_then_exit;
	fi

	if [ $FLAGS_SET_ACK -eq 1 ] && [ $FLAGS_UNSET_ACK -eq 1 ]; then
		printf "\nInvalid flags: ACK cannot be both set and unset. ">&2;
		print_usage_then_exit;
	fi

	if [ $FLAGS_SET_PSH -eq 1 ] && [ $FLAGS_UNSET_PSH -eq 1 ]; then
		printf "\nInvalid flags: PSH cannot be both set and unset. ">&2;
		print_usage_then_exit;
	fi

	if [ $FLAGS_SET_RST -eq 1 ] && [ $FLAGS_UNSET_RST -eq 1 ]; then
		printf "\nInvalid flags: RST cannot be both set and unset. ">&2;
		print_usage_then_exit;
	fi

	if [ $FLAGS_SET_SYN -eq 1 ] && [ $FLAGS_UNSET_SYN -eq 1 ]; then
		printf "\nInvalid flags: SYN cannot be both set and unset. ">&2;
		print_usage_then_exit;
	fi

	if [ $FLAGS_SET_FIN -eq 1 ] && [ $FLAGS_UNSET_FIN -eq 1 ]; then
		printf "\nInvalid flags: FIN cannot be both set and unset. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$WINDOW" ] && [ -n "$WINDOW_MIN" ]; then
		printf "\nInvalid combination of --window and --window-min. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$WINDOW" ] && [ -n "$WINDOW_MAX" ]; then
		printf "\nInvalid combination of --window and --window-max. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$WINDOW" ]; then
		if [ -z "$(echo $WINDOW | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --window (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $WINDOW -lt 0 ]; then
			printf "\nInvalid --window (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $WINDOW -gt 65535 ]; then
			printf "\nInvalid --window (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi
	fi

	WINDOW_MIN_IS_VALID=0;
	if [ -n "$WINDOW_MIN" ]; then
		if [ -z "$(echo $WINDOW_MIN | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --window-min (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $WINDOW_MIN -lt 0 ]; then
			printf "\nInvalid --window-min (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $WINDOW_MIN -gt 65535 ]; then
			printf "\nInvalid --window-min (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi

		WINDOW_MIN_IS_VALID=1;
	fi

	WINDOW_MAX_IS_VALID=0;
	if [ -n "$WINDOW_MAX" ]; then
		if [ -z "$(echo $WINDOW_MAX | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --window-max (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $WINDOW_MAX -lt 0 ]; then
			printf "\nInvalid --window-max (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $WINDOW_MAX -gt 65535 ]; then
			printf "\nInvalid --window-max (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi

		WINDOW_MAX_IS_VALID=1;
	fi

	if [ $WINDOW_MIN_IS_VALID -eq 1 ] && [ $WINDOW_MAX_IS_VALID -eq 1 ] && [ $WINDOW_MIN -ge $WINDOW_MAX ]; then
		printf "\nInvalid --window-min or --window-max (minimum must be less than maximum). ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$CHECKSUM" ] && [ -n "$CHECKSUM_MIN" ]; then
		printf "\nInvalid combination of --checksum and --checksum-min. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$CHECKSUM" ] && [ -n "$CHECKSUM_MAX" ]; then
		printf "\nInvalid combination of --checksum and --checksum-max. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$CHECKSUM" ]; then
		if [ -z "$(echo $CHECKSUM | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --checksum (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $CHECKSUM -lt 0 ]; then
			printf "\nInvalid --checksum (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $CHECKSUM -gt 65535 ]; then
			printf "\nInvalid --checksum (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi
	fi

	CHECKSUM_MIN_IS_VALID=0;
	if [ -n "$CHECKSUM_MIN" ]; then
		if [ -z "$(echo $CHECKSUM_MIN | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --checksum-min (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $CHECKSUM_MIN -lt 0 ]; then
			printf "\nInvalid --checksum-min (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $CHECKSUM_MIN -gt 65535 ]; then
			printf "\nInvalid --checksum-min (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi

		CHECKSUM_MIN_IS_VALID=1;
	fi

	CHECKSUM_MAX_IS_VALID=0;
	if [ -n "$CHECKSUM_MAX" ]; then
		if [ -z "$(echo $CHECKSUM_MAX | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --checksum-max (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $CHECKSUM_MAX -lt 0 ]; then
			printf "\nInvalid --checksum-max (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $CHECKSUM_MAX -gt 65535 ]; then
			printf "\nInvalid --checksum-max (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi

		CHECKSUM_MAX_IS_VALID=1;
	fi

	if [ $CHECKSUM_MIN_IS_VALID -eq 1 ] && [ $CHECKSUM_MAX_IS_VALID -eq 1 ] && [ $CHECKSUM_MIN -ge $CHECKSUM_MAX ]; then
		printf "\nInvalid --checksum-min or --checksum-max (minimum must be less than maximum). ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$URGENT_POINTER" ] && [ -n "$URGENT_POINTER_MIN" ]; then
		printf "\nInvalid combination of --urgent-pointer and --urgent-pointer-min. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$URGENT_POINTER" ] && [ -n "$URGENT_POINTER_MAX" ]; then
		printf "\nInvalid combination of --urgent-pointer and --urgent-pointer-max. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$URGENT_POINTER" ]; then
		if [ -z "$(echo $URGENT_POINTER | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --urgent-pointer (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $URGENT_POINTER -lt 0 ]; then
			printf "\nInvalid --urgent-pointer (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $URGENT_POINTER -gt 65535 ]; then
			printf "\nInvalid --urgent-pointer (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi
	fi

	URGENT_POINTER_MIN_IS_VALID=0;
	if [ -n "$URGENT_POINTER_MIN" ]; then
		if [ -z "$(echo $URGENT_POINTER_MIN | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --urgent-pointer-min (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $URGENT_POINTER_MIN -lt 0 ]; then
			printf "\nInvalid --urgent-pointer-min (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $URGENT_POINTER_MIN -gt 65535 ]; then
			printf "\nInvalid --urgent-pointer-min (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi

		URGENT_POINTER_MIN_IS_VALID=1;
	fi

	URGENT_POINTER_MAX_IS_VALID=0;
	if [ -n "$URGENT_POINTER_MAX" ]; then
		if [ -z "$(echo $URGENT_POINTER_MAX | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --urgent-pointer-max (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $URGENT_POINTER_MAX -lt 0 ]; then
			printf "\nInvalid --urgent-pointer-max (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $URGENT_POINTER_MAX -gt 65535 ]; then
			printf "\nInvalid --urgent-pointer-max (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi

		URGENT_POINTER_MAX_IS_VALID=1;
	fi

	if [ $URGENT_POINTER_MIN_IS_VALID -eq 1 ] && [ $URGENT_POINTER_MAX_IS_VALID -eq 1 ] && [ $URGENT_POINTER_MIN -ge $URGENT_POINTER_MAX ]; then
		printf "\nInvalid --urgent-pointer-min or --urgent-pointer-max (minimum must be less than maximum). ">&2;
		print_usage_then_exit;
	fi
fi

if [ $ONLY_VALIDATION -eq 1 ]; then exit 0; fi

BIT_OFFSET_SOURCE_PORT=$OFFSET_HEADER_BEGIN;
BIT_OFFSET_DESTINATION_PORT=$(($BIT_OFFSET_SOURCE_PORT+16));
BIT_OFFSET_SEQUENCE_NUMBER=$(($BIT_OFFSET_DESTINATION_PORT+16));
BIT_OFFSET_ACKNOWLEDGEMENT_NUMBER=$(($BIT_OFFSET_SEQUENCE_NUMBER+32));
BIT_OFFSET_DATA_OFFSET=$(($BIT_OFFSET_ACKNOWLEDGEMENT_NUMBER+32));
BIT_OFFSET_RESERVED=$(($BIT_OFFSET_DATA_OFFSET+4));
BIT_OFFSET_FLAGS_CWR=$(($BIT_OFFSET_RESERVED+4));
BIT_OFFSET_FLAGS_ECE=$(($BIT_OFFSET_FLAGS_CWR+1));
BIT_OFFSET_FLAGS_URG=$(($BIT_OFFSET_FLAGS_ECE+1));
BIT_OFFSET_FLAGS_ACK=$(($BIT_OFFSET_FLAGS_URG+1));
BIT_OFFSET_FLAGS_PSH=$(($BIT_OFFSET_FLAGS_ACK+1));
BIT_OFFSET_FLAGS_RST=$(($BIT_OFFSET_FLAGS_PSH+1));
BIT_OFFSET_FLAGS_SYN=$(($BIT_OFFSET_FLAGS_RST+1));
BIT_OFFSET_FLAGS_FIN=$(($BIT_OFFSET_FLAGS_SYN+1));
BIT_OFFSET_WINDOW=$(($BIT_OFFSET_FLAGS_FIN+1));
BIT_OFFSET_CHECKSUM=$(($BIT_OFFSET_WINDOW+16));
BIT_OFFSET_URGENT_POINTER=$(($BIT_OFFSET_CHECKSUM+16));
BIT_OFFSET_OPTIONS=$(($BIT_OFFSET_URGENT_POINTER+16));

if [ -n "$SOURCE_PORT" ]; then
	printf "\\t\\t#Match source port\n";
	if [ $SOURCE_PORT_IS_RANGE -eq 1 ]; then
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_SOURCE_PORT,16 >= $SOURCE_PORT_BEGIN \\\\\n";
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_SOURCE_PORT,16 <= $SOURCE_PORT_END \\\\\n";
	else
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_SOURCE_PORT,16 $SOURCE_PORT \\\\\n";
	fi
else
	printf "\\t\\t#Source port is unrestricted - confirm the security implications.\n"
fi

if [ -n "$DESTINATION_PORT" ]; then
	printf "\\t\\t#Match destination port\n";
	if [ $DESTINATION_PORT_IS_RANGE -eq 1 ]; then
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_DESTINATION_PORT,16 >= $DESTINATION_PORT_BEGIN \\\\\n";
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_DESTINATION_PORT,16 <= $DESTINATION_PORT_END \\\\\n";
	else
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_DESTINATION_PORT,16 $DESTINATION_PORT \\\\\n";
	fi
else
	printf "\\t\\t#Destination port is unrestricted - confirm the security implications.\n"
fi

if [ -n "$SEQUENCE_NUMBER" ]; then
	printf "\\t#Match Sequence Number (only $SEQUENCE_NUMBER)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_SEQUENCE_NUMBER,32 $SEQUENCE_NUMBER \\\\\n";
fi

if [ -n "$SEQUENCE_NUMBER_MIN" ] && [ -z "$SEQUENCE_NUMBER_MAX" ]; then
	printf "\\t#Match Sequence Number (minimum $SEQUENCE_NUMBER)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_SEQUENCE_NUMBER,32 >= $SEQUENCE_NUMBER_MIN \\\\\n";
fi

if [ -z "$SEQUENCE_NUMBER_MIN" ] && [ -n "$SEQUENCE_NUMBER_MAX" ]; then
	printf "\\t#Match Sequence Number (maximum $SEQUENCE_NUMBER)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_SEQUENCE_NUMBER,32 <= $SEQUENCE_NUMBER_MAX \\\\\n";
fi

if [ -n "$SEQUENCE_NUMBER_MIN" ] && [ -n "$SEQUENCE_NUMBER_MAX" ]; then
	printf "\\t#Match Sequence Number ($SEQUENCE_NUMBER_MIN-$SEQUENCE_NUMBER_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_SEQUENCE_NUMBER,32 >= $SEQUENCE_NUMBER_MIN \\\\\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_SEQUENCE_NUMBER,32 <= $SEQUENCE_NUMBER_MAX \\\\\n";
fi

if [ -z "$SEQUENCE_NUMBER" ] && [ -z "$SEQUENCE_NUMBER_MIN" ] && [ -z "$SEQUENCE_NUMBER_MAX" ]; then
	printf "\\t\\t#Sequence Number is unrestricted.\n";
fi

if [ -n "$ACKNOWLEDGEMENT_NUMBER" ]; then
	printf "\\t#Match Acknowledgement Number (only $ACKNOWLEDGEMENT_NUMBER)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ACKNOWLEDGEMENT_NUMBER,32 $ACKNOWLEDGEMENT_NUMBER \\\\\n";
fi

if [ -n "$ACKNOWLEDGEMENT_NUMBER_MIN" ] && [ -z "$ACKNOWLEDGEMENT_NUMBER_MAX" ]; then
	printf "\\t#Match Acknowledgement Number (minimum $ACKNOWLEDGEMENT_NUMBER)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ACKNOWLEDGEMENT_NUMBER,32 >= $ACKNOWLEDGEMENT_NUMBER_MIN \\\\\n";
fi

if [ -z "$ACKNOWLEDGEMENT_NUMBER_MIN" ] && [ -n "$ACKNOWLEDGEMENT_NUMBER_MAX" ]; then
	printf "\\t#Match Acknowledgement Number (maximum $ACKNOWLEDGEMENT_NUMBER)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ACKNOWLEDGEMENT_NUMBER,32 <= $ACKNOWLEDGEMENT_NUMBER_MAX \\\\\n";
fi

if [ -n "$ACKNOWLEDGEMENT_NUMBER_MIN" ] && [ -n "$ACKNOWLEDGEMENT_NUMBER_MAX" ]; then
	printf "\\t#Match Acknowledgement Number ($ACKNOWLEDGEMENT_NUMBER_MIN-$ACKNOWLEDGEMENT_NUMBER_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ACKNOWLEDGEMENT_NUMBER,32 >= $ACKNOWLEDGEMENT_NUMBER_MIN \\\\\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ACKNOWLEDGEMENT_NUMBER,32 <= $ACKNOWLEDGEMENT_NUMBER_MAX \\\\\n";
fi

if [ -z "$ACKNOWLEDGEMENT_NUMBER" ] && [ -z "$ACKNOWLEDGEMENT_NUMBER_MIN" ] && [ -z "$ACKNOWLEDGEMENT_NUMBER_MAX" ]; then
	printf "\\t\\t#Acknowledgement Number is unrestricted.\n";
fi

if [ -n "$DATA_OFFSET" ]; then
	printf "\\t#Match Data Offset (only $DATA_OFFSET)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_DATA_OFFSET,32 $DATA_OFFSET \\\\\n";
fi

if [ -n "$DATA_OFFSET_MIN" ] && [ -z "$DATA_OFFSET_MAX" ]; then
	printf "\\t#Match Data Offset (minimum $DATA_OFFSET)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_DATA_OFFSET,32 >= $DATA_OFFSET_MIN \\\\\n";
fi

if [ -z "$DATA_OFFSET_MIN" ] && [ -n "$DATA_OFFSET_MAX" ]; then
	printf "\\t#Match Data Offset (maximum $DATA_OFFSET)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_DATA_OFFSET,32 <= $DATA_OFFSET_MAX \\\\\n";
fi

if [ -n "$DATA_OFFSET_MIN" ] && [ -n "$DATA_OFFSET_MAX" ]; then
	printf "\\t#Match Data Offset ($DATA_OFFSET_MIN-$DATA_OFFSET_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_DATA_OFFSET,32 >= $DATA_OFFSET_MIN \\\\\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_DATA_OFFSET,32 <= $DATA_OFFSET_MAX \\\\\n";
fi

if [ -z "$DATA_OFFSET" ] && [ -z "$DATA_OFFSET_MIN" ] && [ -z "$DATA_OFFSET_MAX" ]; then
	printf "\\t\\t#Data Offset is unrestricted.\n";
fi

printf "\\t\\t#Reserved bits must be zero.\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_RESERVED,4 0 \\\\\n";

if \
[ $FLAGS_SET_CWR -eq 0 ] && \
[ $FLAGS_SET_ECE -eq 0 ] && \
[ $FLAGS_SET_URG -eq 0 ] && \
[ $FLAGS_SET_ACK -eq 0 ] && \
[ $FLAGS_SET_PSH -eq 0 ] && \
[ $FLAGS_SET_RST -eq 0 ] && \
[ $FLAGS_SET_SYN -eq 0 ] && \
[ $FLAGS_SET_FIN -eq 0 ] && \
[ $FLAGS_UNSET_CWR -eq 0 ] && \
[ $FLAGS_UNSET_ECE -eq 0 ] && \
[ $FLAGS_UNSET_URG -eq 0 ] && \
[ $FLAGS_UNSET_ACK -eq 0 ] && \
[ $FLAGS_UNSET_PSH -eq 0 ] && \
[ $FLAGS_UNSET_RST -eq 0 ] && \
[ $FLAGS_UNSET_SYN -eq 0 ] && \
[ $FLAGS_UNSET_FIN -eq 0 ]; \
then
	printf "\\t\\t#Flags are unrestricted.\n";
else
	printf "\\t\\t#TCP Flags:\n";
fi

if [ $FLAGS_SET_CWR -eq 1 ]; then
	printf "\\t\\t#Match CWR when set.\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FLAGS_CWR,1 1 \\\\\n";
fi

if [ $FLAGS_SET_ECE -eq 1 ]; then
	printf "\\t\\t#Match ECE when set.\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FLAGS_ECE,1 1 \\\\\n";
fi

if [ $FLAGS_SET_URG -eq 1 ]; then
	printf "\\t\\t#Match URG when set.\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FLAGS_URG,1 1 \\\\\n";
fi

if [ $FLAGS_SET_ACK -eq 1 ]; then
	printf "\\t\\t#Match ACK when set.\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FLAGS_ACK,1 1 \\\\\n";
fi

if [ $FLAGS_SET_PSH -eq 1 ]; then
	printf "\\t\\t#Match PSH when set.\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FLAGS_PSH,1 1 \\\\\n";
fi

if [ $FLAGS_SET_RST -eq 1 ]; then
	printf "\\t\\t#Match RST when set.\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FLAGS_RST,1 1 \\\\\n";
fi

if [ $FLAGS_SET_SYN -eq 1 ]; then
	printf "\\t\\t#Match SYN when set.\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FLAGS_SYN,1 1 \\\\\n";
fi

if [ $FLAGS_SET_FIN -eq 1 ]; then
	printf "\\t\\t#Match FIN when set.\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FLAGS_FIN,1 1 \\\\\n";
fi

if [ $FLAGS_UNSET_CWR -eq 1 ]; then
	printf "\\t\\t#Match CWR when unset.\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FLAGS_CWR,1 0 \\\\\n";
fi

if [ $FLAGS_UNSET_ECE -eq 1 ]; then
	printf "\\t\\t#Match ECE when unset.\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FLAGS_ECE,1 0 \\\\\n";
fi

if [ $FLAGS_UNSET_URG -eq 1 ]; then
	printf "\\t\\t#Match URG when unset.\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FLAGS_URG,1 0 \\\\\n";
fi

if [ $FLAGS_UNSET_ACK -eq 1 ]; then
	printf "\\t\\t#Match ACK when unset.\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FLAGS_ACK,1 0 \\\\\n";
fi

if [ $FLAGS_UNSET_PSH -eq 1 ]; then
	printf "\\t\\t#Match PSH when unset.\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FLAGS_PSH,1 0 \\\\\n";
fi

if [ $FLAGS_UNSET_RST -eq 1 ]; then
	printf "\\t\\t#Match RST when unset.\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FLAGS_RST,1 0 \\\\\n";
fi

if [ $FLAGS_UNSET_SYN -eq 1 ]; then
	printf "\\t\\t#Match SYN when unset.\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FLAGS_SYN,1 0 \\\\\n";
fi

if [ $FLAGS_UNSET_FIN -eq 1 ]; then
	printf "\\t\\t#Match FIN when unset.\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FLAGS_FIN,1 0 \\\\\n";
fi

if [ -n "$WINDOW" ]; then
	printf "\\t#Match Window (only $WINDOW)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_WINDOW,32 $WINDOW \\\\\n";
fi

if [ -n "$WINDOW_MIN" ] && [ -z "$WINDOW_MAX" ]; then
	printf "\\t#Match Window (minimum $WINDOW)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_WINDOW,32 >= $WINDOW_MIN \\\\\n";
fi

if [ -z "$WINDOW_MIN" ] && [ -n "$WINDOW_MAX" ]; then
	printf "\\t#Match Window (maximum $WINDOW)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_WINDOW,32 <= $WINDOW_MAX \\\\\n";
fi

if [ -n "$WINDOW_MIN" ] && [ -n "$WINDOW_MAX" ]; then
	printf "\\t#Match Window ($WINDOW_MIN-$WINDOW_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_WINDOW,32 >= $WINDOW_MIN \\\\\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_WINDOW,32 <= $WINDOW_MAX \\\\\n";
fi

if [ -z "$WINDOW" ] && [ -z "$WINDOW_MIN" ] && [ -z "$WINDOW_MAX" ]; then
	printf "\\t\\t#Window is unrestricted.\n";
fi

if [ -n "$CHECKSUM" ]; then
	printf "\\t#Match Checksum (only $CHECKSUM)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CHECKSUM,32 $CHECKSUM \\\\\n";
fi

if [ -n "$CHECKSUM_MIN" ] && [ -z "$CHECKSUM_MAX" ]; then
	printf "\\t#Match Checksum (minimum $CHECKSUM)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CHECKSUM,32 >= $CHECKSUM_MIN \\\\\n";
fi

if [ -z "$CHECKSUM_MIN" ] && [ -n "$CHECKSUM_MAX" ]; then
	printf "\\t#Match Checksum (maximum $CHECKSUM)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CHECKSUM,32 <= $CHECKSUM_MAX \\\\\n";
fi

if [ -n "$CHECKSUM_MIN" ] && [ -n "$CHECKSUM_MAX" ]; then
	printf "\\t#Match Checksum ($CHECKSUM_MIN-$CHECKSUM_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CHECKSUM,32 >= $CHECKSUM_MIN \\\\\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CHECKSUM,32 <= $CHECKSUM_MAX \\\\\n";
fi

if [ -z "$CHECKSUM" ] && [ -z "$CHECKSUM_MIN" ] && [ -z "$CHECKSUM_MAX" ]; then
	printf "\\t\\t#Checksum is unrestricted.\n";
fi

if [ -n "$URGENT_POINTER" ]; then
	printf "\\t#Match Urgent Pointer (only $URGENT_POINTER)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_URGENT_POINTER,32 $URGENT_POINTER \\\\\n";
fi

if [ -n "$URGENT_POINTER_MIN" ] && [ -z "$URGENT_POINTER_MAX" ]; then
	printf "\\t#Match Urgent Pointer (minimum $URGENT_POINTER)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_URGENT_POINTER,32 >= $URGENT_POINTER_MIN \\\\\n";
fi

if [ -z "$URGENT_POINTER_MIN" ] && [ -n "$URGENT_POINTER_MAX" ]; then
	printf "\\t#Match Urgent Pointer (maximum $URGENT_POINTER)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_URGENT_POINTER,32 <= $URGENT_POINTER_MAX \\\\\n";
fi

if [ -n "$URGENT_POINTER_MIN" ] && [ -n "$URGENT_POINTER_MAX" ]; then
	printf "\\t#Match Urgent Pointer ($URGENT_POINTER_MIN-$URGENT_POINTER_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_URGENT_POINTER,32 >= $URGENT_POINTER_MIN \\\\\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_URGENT_POINTER,32 <= $URGENT_POINTER_MAX \\\\\n";
fi

if [ -z "$URGENT_POINTER" ] && [ -z "$URGENT_POINTER_MIN" ] && [ -z "$URGENT_POINTER_MAX" ]; then
	printf "\\t\\t#Urgent Pointer is unrestricted.\n";
fi

exit 0;
