#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_VALIDATE_PORT="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_port_or_range_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_PORT ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_PORT\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_description() {
	printf "A program that prints part of an NFT rule 'match' section. The match intends to identify UDP headers.\n">&2;
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
	printf " Optional: --length x (where x is 0-65536).\n">&2;
	printf "  Restrict the packet to an exact length.\n">&2;
	printf "\n">&2;
	printf " Optional: --length-min x (where x is 0-65536).\n">&2;
	printf "  Restrict the packet to a minimum length.\n">&2;
	printf "\n">&2;
	printf " Optional: --length-max x (where x is 0-65536).\n">&2;
	printf "  Restrict the packet to a maximum length.\n">&2;
	printf "\n">&2;
	printf " You must not supply an exact packet length alongside a minimum or maximum length restriction.\n">&2;
	printf " You are not required to supply both a minimum and maximum packet length.\n">&2;
	printf " When supplied together, --length-min must be less than --length-max\n">&2;
	printf "\n">&2;
	printf " Optional: --checksum x (where x is 0-65536)\n">&2;
	printf "  Restrict the packet to an exact checksum.\n">&2;
	printf "  this could be beneficial if you know the checksum of a previously sent/received packet.\n">&2;
	printf "\n">&2;
	printf " Optional: --checksum-min x (where x is 0-65536)\n">&2;
	printf "  Restrict the packet checksum to a minimum.\n">&2;
	printf "  this could be beneficial if you know the checksum of a previously sent/received packet.\n">&2;
	printf "\n">&2;
	printf " Optional: --checksum-max x (where x is 0-65536)\n">&2;
	printf "  Restrict the packet checksum to a maximum.\n">&2;
	printf "  this could be beneficial if you know the checksum of a previously sent/received packet.\n">&2;
	printf "\n">&2;
	printf " You must not supply an exact packet checksum alongside a minimum or maximum checksum restriction.\n">&2;
	printf " You are not required to supply both a minimum and maximum packet checksum.\n">&2;
	printf " When supplied together, --checksum-min must be less than --checksum-max\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf "  this causes the program to skip validating inputs (if you know they are valid).\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validation\n">&2;
	printf "  this causes the program to exit after validating inputs.\n">&2;
	printf "\n">&2;
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
LENGTH="";
LENGTH_MIN="";
LENGTH_MAX="";
CHECKSUM="";
CHECKSUM_MIN="";
CHECKSUM_MAX="";

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

		--length)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				LENGTH=$2;
				shift 2;
			fi
		;;

		--length-min)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				LENGTH_MIN=$2;
				shift 2;
			fi
		;;

		--length-max)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				LENGTH_MAX=$2;
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
		if [ -n "$(echo $SOURCE_PORT | grep '[0-9]\{1,5\}-[0-9]\{1,5\}')" ]; then
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
		elif [ -n "$(echo $SOURCE_PORT | grep '[0-9]\{1,5\}')" ]
			if [ $SOURCE_PORT -lt 1 ]; then
				printf "\nInvalid --source-port (must be greater than 0). ">&2;
				print_usage_then_exit;
			fi

			if [ $SOURCE_PORT -gt 65535 ]; then
				printf "\nInvalid --source-port (must be less than 65536). ">&2;
				print_usage_then_exit;
			fi
		else
			printf "\nInvalid --source-port. ">&2;
			print_usage_then_exit;
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
		elif [ -n "$(echo $DESTINATION_PORT | grep '[0-9]\{1,5\}')" ]
			if [ $DESTINATION_PORT -lt 1 ]; then
				printf "\nInvalid --destination-port (must be greater than 0). ">&2;
				print_usage_then_exit;
			fi

			if [ $DESTINATION_PORT -gt 65535 ]; then
				printf "\nInvalid --destination-port (must be less than 65536). ">&2;
				print_usage_then_exit;
			fi
		else
			printf "\nInvalid --destination-port. ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$LENGTH" ] && [ -n "$LENGTH_MIN" ]; then
		printf "\nInvalid combination of --length and --length-min. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$LENGTH" ] && [ -n "$LENGTH_MAX" ]; then
		printf "\nInvalid combinations of --length and --length-max. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$LENGTH" ]; then
		if [ -z "$(echo $LENGTH | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --length (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH -lt 1 ]; then
			printf "\nInvalid --length (must be greater than 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH -gt 65535 ]; then
			printf "\nInvalid --length (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi
	fi

	LENGTH_MIN_IS_VALID=0;
	if [ -n "$LENGTH_MIN" ]; then
		if [ -z "$(echo $LENGTH_MIN | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --length-min (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH_MIN -lt 0 ]; then
			printf "\nInvalid --length-min (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH_MIN -gt 65535 ]; then
			printf "\nInvalid --length-min (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi

		LENGTH_MIN_IS_VALID=0;
	fi

	LENGTH_MAX_IS_VALID=0;
	if [ -n "$LENGTH_MAX" ]; then
		if [ -z "$(echo $LENGTH_MAX | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --length-max (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH_MAX -lt 0 ]; then
			printf "\nInvalid --length-max (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH_MAX -gt 65535 ]; then
			printf "\nInvalid --length-max (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi

		LENGTH_MAX_IS_VALID=0;
	fi

	if [ $LENGTH_MIN_IS_VALID -eq 1 ] && [ $LENGTH_MAX_IS_VALID -eq 1 ] && [ $LENGTH_MIN -ge $LENGTH_MAX ]; then
		printf "\nInvalid --length-min or --length-max (minimum must be less than maximum.)">&2;
		print_usage_then_exit;
	fi

	if [ -n "$CHECKSUM" ] && [ -n "$CHECKSUM_MIN" ]; then
		printf "\nInvalid combination of --checksum and --checksum-min. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$CHECKSUM" ] && [ -n "$CHECKSUM_MAX" ]; then
		printf "\nInvalid combinations of --checksum and --checksum-max. ">&2;
		print_usage_then_exit;
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

	CHECKSUM_MIN_IS_VALID=0;
	if [ -n "$CHECKSUM_MIN" ]; then
		if [ -z "$(echo $CHECKSUM_MIN | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --checksum-min (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $CHECKSUM_MIN -lt 0 ]; then
			printf "\nInvalid --checksum-min (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $CHECKSUM_MIN -gt 65535 ]; then
			printf "\nInvalid --checksum-min (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi

		CHECKSUM_MIN_IS_VALID=0;
	fi

	CHECKSUM_MAX_IS_VALID=0;
	if [ -n "$CHECKSUM_MAX" ]; then
		if [ -z "$(echo $CHECKSUM_MAX | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --checksum-max (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $CHECKSUM_MAX -lt 0 ]; then
			printf "\nInvalid --checksum-max (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $CHECKSUM_MAX -gt 65535 ]; then
			printf "\nInvalid --checksum-max (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi

		CHECKSUM_MAX_IS_VALID=0;
	fi

	if [ $CHECKSUM_MIN_IS_VALID -eq 1 ] && [ $CHECKSUM_MAX_IS_VALID -eq 1 ] && [ $CHECKSUM_MIN -ge $CHECKSUM_MAX ]; then
		printf "\nInvalid --checksum-min or --checksum-max (minimum must be less than maximum.)">&2;
		print_usage_then_exit;
	fi
fi

if [ $ONLY_VALIDATION -eq 1 ]; then exit 0; fi

BIT_OFFSET_SOURCE_PORT=$OFFSET_HEADER_BEGIN;
BIT_OFFSET_DESTINATION_PORT=$(($BIT_OFFSET_SOURCE_PORT+16));
BIT_OFFSET_LENGTH=$(($BIT_OFFSET_DESTINATION_PORT+16));
BIT_OFFSET_CHECKSUM=$(($BIT_OFFSET_LENGTH+16));
BIT_OFFSET_DATA=$(($BIT_OFFSET_CHECKSUM+16));

if [ $SKIP_VALIDATION -eq 1 ] && [ -n "$(echo $SOURCE_PORT | grep '[0-9]\{1,5\}-[0-9]\{1,5\}')" ]; then
	DESTINATION_PORT_IS_RANGE=1;
fi

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

if [ $SKIP_VALIDATION -eq 1 ] && [ -n "$(echo $DESTINATION_PORT | grep '[0-9]\{1,5\}-[0-9]\{1,5\}')" ]; then
	DESTINATION_PORT_IS_RANGE=1;
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

if [ -n "$LENGTH" ]; then
	printf "\\t\\t#Match length (only $LENGTH)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_LENGTH,16 $LENGTH \\\\\n";
fi

if [ -n "$LENGTH_MIN" ] && [ -z "$LENGTH_MAX" ]; then
	printf "\\t\\t#Match length (minimum $LENGTH_MIN)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_LENGTH,16 >= $LENGTH_MIN \\\\\n";
fi

if [ -z "$LENGTH_MIN" ] && [ -n "$LENGTH_MAX" ]; then
	printf "\\t\\t#Match length (maximum $LENGTH_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_LENGTH,16 <= $LENGTH_MAX \\\\\n";
fi

if [ -n "$LENGTH_MIN" ] && [ -n "$LENGTH_MAX" ]; then
	printf "\\t\\t#Match length ($LENGTH_MIN-$LENGTH_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_LENGTH,16 <= $LENGTH_MAX \\\\\n";
fi

if [ -z "$LENGTH" ] && [ -z "$LENGTH_MIN" ] && [ -z "$LENGTH_MAX" ]; then
	printf "\\t\\t#Length is unrestricted\n";
fi

if [ -n "$CHECKSUM" ]; then
	printf "\\t\\t#Match checksum (only $CHECKSUM)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CHECKSUM,16 $CHECKSUM \\\\\n";
fi

if [ -n "$CHECKSUM_MIN" ] && [ -z "$CHECKSUM_MAX" ]; then
	printf "\\t\\t#Match checksum (minimum $CHECKSUM_MIN)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CHECKSUM,16 >= $CHECKSUM_MIN \\\\\n";
fi

if [ -z "$CHECKSUM_MIN" ] && [ -n "$CHECKSUM_MAX" ]; then
	printf "\\t\\t#Match checksum (maximum $CHECKSUM_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CHECKSUM,16 <= $CHECKSUM_MAX \\\\\n";
fi

if [ -n "$CHECKSUM_MIN" ] && [ -n "$CHECKSUM_MAX" ]; then
	printf "\\t\\t#Match checksum ($CHECKSUM_MIN-$CHECKSUM_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CHECKSUM,16 <= $CHECKSUM_MAX \\\\\n";
fi

if [ -z "$CHECKSUM" ] && [ -z "$CHECKSUM_MIN" ] && [ -z "$CHECKSUM_MAX" ]; then
	printf "\\t\\t#Length is unrestricted\n";
fi

exit 0;
