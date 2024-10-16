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
	printf "printf\n">&2;
	printf "echo\n">&2;
	printf "grep\n">&2;
	printf "cut\n">&2;
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
	printf " Optional: --offset-marker th|ih\n">&2;
	printf "  Note: here, th means transport header (or the usual place of the UDP header).\n">&2;
	printf "  Note: this is commonly what you are looking to match, unless the UDP header\n">&2;
	printf "  Note: is part of the content in an encapsulating protocol (See ICMP Destination Unreachable).\n">&2;
	printf "  Note: for these encapsulating protocols, the offset marker should be ih; with a predefined \"offset-header-begin\".\n">&2;
	printf "\n">&2;
	printf " Optional: --offset-header-begin X (where x is a number from 0-65536)\n">&2;
	printf "  Note: this indicates to the program where the beginning of the UDP header is.\n">&2;
	printf "  Note: this is important for wncapsulating protocols such as an ICMP Destination Unreachable packet;\n">&2;
	printf "  Note: otherwise, the header will simply not match.\n">&2;
	printf "\n">&2;
	printf " Note: where --offset-marker is not provided, the default is \"th\" (the standard place to match a UDP header).\n">&2;
	printf " Note: if --offset-header-begin is not provided, it will default to 0. If --offset marker is \"ih\", it will likely fail to match.\n">&2;
	printf "\n">&2;
	printf " Optional: --source-port x|x-x (where x is 1-65535)\n">&2;
	printf "  Note: the source port. Depending on the IPV4/6 header, this could be either the server or client port.\n">&2;
	printf "  Note: the source port argument may be a range of ports delmited by a hyphen (eg. x-x). The ports can be in ascending or descending order.\n">&2;
	printf "\n">&2;
	printf " Optional: --destination-port x|x-x (where x is 1-65535)\n">&2;
	printf "  Note: the destination port. Depending on the IPV4/6 header, this could be either the server or client port.\n">&2;
	printf "  Note: the destination port argument may be a range of ports delmited by a hyphen (eg. x-x). The ports can be in ascending or descending order.\n">&2;
	printf "\n">&2;
	printf " Optional: --sequence-number x (where x is 0-4,294,967,295)\n">&2;
	printf "  Note: this signifies the identifier of the 'frame' or 'window' in the TCP session.\n">&2;
	printf "  Note: it should be random, so matching this field is of limited use.\n">&2;
	printf "\n">&2;
	printf " Optional: --acknowledgement-number x (where x is 0-4,294,967,295)\n">&2;
	printf "  Note: presence of this number indicates that this packet is an acknowledgement of a previous sequence number.\n">&2;
	printf "  Note: in this environment, it is effectively random and matching this field is of limited use.\n">&2;
	printf "\n">&2;
	printf " Optional: --data-offset x (where x is 5-8)\n">&2;
	printf "  Note: this field signifies the length in (32-bit) words of the TCP header.\n">&2;
	printf "  Note: the minimum is 5.\n">&2;
	printf "\n">&2;
	printf " Optional: --flags-on [CWR|ECE|URG|ACK|PSH|RST|SYN|FIN]\n">&2;
	printf "  Note: Provide a csv of TCP flags that are enabled for this packet.\n">&2;
	printf "\n">&2;
	printf " Optional: --flags-off [CWR|ECE|URG|ACK|PSH|RST|SYN|FIN]\n">&2;
	printf "  Note: Provide a csv of TCP flags that are disabled for this packet.\n">&2;
	printf "\n">&2;
	printf " Optional: --window x (where x is 0-65535)\n">&2;
	printf "  Note: The length of the TCP segment. It can be scaled with the window scaling option.\n">&2;
	printf "  Note: Window Scaling is common, so matching an exact value is not reliable.\n">&2;
	printf "\n">&2;
	printf " Optional: --checksum x (where x is 0-65536)\n">&2;
	printf "  Note: this matches a specific packet checksum.\n">&2;
	printf "  Note: this could be beneficial if you know the checksum of a previously sent/received packet.\n">&2;
	printf "\n">&2;
	printf " Optional: --urgent-pointer x (where x i 0-65535).\n">&2;
	printf "  Note: the offset from the sequence number in this segment where some 'urgent' data begins.\n">&2;
	printf "  Note: only valid when the URG flag is set.\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf "  Note: this causes the program to skip validating inputs (if you know they are valid).\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validation\n">&2;
	printf "  Note: this causes the program to exit after validating inputs.\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
SOURCE_PORT="";
SOURCE_PORT_BEGIN=0;
SOURCE_PORT_END=0;
SOURCE_PORT_IS_RANGE=0;
DESTINATION_PORT="";
DESTINATION_PORT_BEGIN=0;
DESTINATION_PORT_END=0;
DESTINATION_PORT_IS_RANGE=0;
SEQUENCE_NUMBER="";
ACKNOWLEDGEMENT_NUMBER="";
DATA_OFFSET="";
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
CHECKSUM="";
URGENT_POINTER="";
OFFSET_MARKER="th";
OFFSET_HEADER_BEGIN=0;

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
		if [ -n "$(echo $SOURCE_PORT | grep '-')" ]; then
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
		if [ -n "$(echo $DESTINATION_PORT | grep '-')" ]; then
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

	if [ -n "$DATA_OFFSET" ]; then
		if [ -z "$(echo $DATA_OFFSET | grep '[0-9]\{1,2\}')" ]; then
			printf "\nInvalid --data-offset (must be a 1-2 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $DATA_OFFSET -lt 5 ]; then
			printf "\nInvalid --data-offset (must be greater than 5). ">&2;
			print_usage_then_exit;
		fi

		if [ $DATA_OFFSET -gt 16 ]; then
			printf "\nInvalid --data-offset (must be less than or equal to 16). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$FLAGS_SET" ]; then
		if [ -z "$(echo $FLAGS_SET | grep ',')" ]; then
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
				*) printf "\nInvalid --flags. "; print_usage_then_exit; ;;
			esac
		else
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
					*) printf "\nInvalid --flags (flag \#$i). "; print_usage_then_exit; ;;
				esac

				i=$(($i+1));
			done;
		fi
	fi

	if [ -n "$FLAGS_UNSET" ]; then
		if [ -z "$(echo $FLAGS_UNSET | grep ',')" ]; then
			#a flag
			case $FLAG in
				CWR) FLAGS_UNSET_CWR=1; ;;
				ECE) FLAGS_UNSET_ECE=1; ;;
				URG) FLAGS_UNSET_URG=1; ;;
				ACK) FLAGS_UNSET_ACK=1; ;;
				PSH) FLAGS_UNSET_PSH=1; ;;
				RST) FLAGS_UNSET_RST=1; ;;
				SYN) FLAGS_UNSET_SYN=1; ;;
				FIN) FLAGS_UNSET_FIN=1; ;;
				*) printf "\nInvalid --flags. "; print_usage_then_exit; ;;
			esac
		else
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
					*) printf "\nInvalid --flags (flag \#$i). "; print_usage_then_exit; ;;
				esac

				i=$(($i+1));
			done;
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

	if [ -n "$WINDOW" ]; then
		if [ -z "$(echo $WINDOW | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --window (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $WINDOW -lt 0 ]; then
			printf "\nInvalid --window (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $WINDOW -gt 65536 ]; then
			printf "\nInvalid --window (must be less than 65537). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$CHECKSUM" ]; then
		if [ -z "$(echo $CHECKSUM | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --checksum (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $CHECKSUM -lt 1 ]; then
			printf "\nInvalid --checksum (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $CHECKSUM -gt 65535 ]; then
			printf "\nInvalid --checksum (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$URGENT_POINTER" ]; then
		if [ -z "$(echo $URGENT_POINTER | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --urgent-pointer (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $URGENT_POINTER -lt 1 ]; then
			printf "\nInvalid --urgent-pointer (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $URGENT_POINTER -gt 65535 ]; then
			printf "\nInvalid --urgent-pointer (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi
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
	printf "\\t\\t#Check Sequence Number\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_SEQUENCE_NUMBER,32 $SEQUENCE_NUMBER \\\\\n";
else
	printf "\\t\\t#Sequence Number is unrestricted.\n";
fi

if [ -n "$ACKNOWLEDGEMENT_NUMBER" ]; then
	printf "\\t\\t#Check Acknowledgement Number\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ACKNOWLEDGEMENT_NUMBER,32 $ACKOWLEDGEMENT_NUMBER \\\\\n";
else
	printf "\\t\\t#Acknowledgement Number is unrestricted.\n";
fi

if [ -n "$DATA_OFFSET" ]; then
	printf "\\t\\t#Check Data Offset\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_DATA_OFFSET,4 $DATA_OFFSET \\\\\n";
else
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
	printf "\\t\\t#Match Window Size.\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_WINDOW,16 $WINDOW \\\\\n";
else
	printf "\\t\\t#Window Size is unrestricted.\n";
fi

if [ -n "$CHECKSUM" ]; then
	printf "\\t\\t#Match checksum\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CHECKSUM,16 $CHECKSUM \\\\\n";
else
	printf "\\t\\t#Checksum is unrestricted.\n";
fi

if [ -n "$URGENT_POINTER" ]; then
	printf "\\t\\t#Match Urgent Pointer\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_URGENT_POINTER,16 $URGENT_POINTER \\\\\n";
else
	printf "\\t\\t#Urgent Pointer is unrestricted.\n";
fi

exit 0;
