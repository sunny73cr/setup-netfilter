#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

print_description() {
	printf "A program that prints part of an NFT rule 'match' section. The match intends to identify ICMP Destination Unreachable Headers.\n">&2;
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
	printf " Optional: --code x (where x is 0-15)\n">&2;
	printf "  Code descriptions:\n">&2;
	printf "   0 - Network unreachable\n">&2;
	printf "   1 - Host unreachable\n">&2;
	printf "   2 - Protocol unreachable (the transport protocol is not supported)\n">&2;
	printf "   3 - Port unreachable (the protocol is unable to inform the host of the inbound packet)\n">&2;
	printf "   4 - The datagram is too big. Fragmentation is required, but the 'Dont Fragment' bit is enabled\n">&2;
	printf "   5 - Source Route failed\n">&2;
	printf "   6 - Destination Network unknown\n">&2;
	printf "   7 - Destination Host unknown\n">&2;
	printf "   8 - Source host isolated error\n">&2;
	printf "   9 - The destination network is administratively prohibited\n">&2;
	printf "   10 - The destination host is administratively prohibited\n">&2;
	printf "   11 - The network is unreachable for Type Of Service\n">&2;
	printf "   12 - The host is unreachable for Type Of Service\n">&2;
	printf "   13 - Communication administratively prohibited (filtering prevents forwarding)\n">&2;
	printf "   14 - Host precedence violation (the requested precedence is not permitted for the combination of host or network and port)\n">&2;
	printf "   15 - Precedence cutoff in effect (precedence of datagram is below the level set by the network administrators)\n">&2;
	printf "\n">&2;
	printf " Optional: --checksum x (where x is 0-65535)\n">&2;
	printf "  Note: useful if you know the checksum of an already sent packet.\n">&2;
	printf "\n">&2;
	printf " Optional: --length x (where x is 0-255)\n">&2;
	printf "  Note: the length of the payload in 32-bit words (4 byte chunks)\n">&2;
	printf "  Note: the length field is not always present.\n">&2;
	printf "\n">&2;
	printf " Optional: --length-min x (where x is 0-255)\n">&2;
	printf "\n">&2;
	printf " Optional: --length-max x (where x is 0-255)\n">&2;
	printf "\n">&2;
	printf " Note: you are not required to supply both a min and max length\n">&2;
	printf " Note: you cannot combine an exact length with a min or max bound restriction\n">&2;
	printf " Note: the match is not optimistic; where length is filtered, packets without a length will not be matched.\n">&2;
	printf "\n">&2;
	printf " Optional: --next-hop-mtu x (0-65535)\n">&2;
	printf "  Note: contains the MTU of the next-hop network is the code is 4.\n">&2;
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
CHECKSUM="";
LENGTH="";
LENGTH_MIN="";
LENGTH_MAX="";
NEXT_HOP_MTU="";

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

		--next-hop-mtu)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				NEXT_HOP_MTU=$2;
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
	if [ -n "$CODE" ]; then
		if [ -z "$(echo $CODE | grep '[0-9]\{1,2\}')" ]; then
			printf "\nInvalid --code (must be a 1-2 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $CODE -lt 0 ]; then
			printf "\nInvalid --code (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $CODE -gt 15 ]; then
			printf "\nInvalid --code (must be less than 16). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$CHECKSUM" ]; then
		if [ -z "$(echo $CHECKSUM | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --checksum (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $CHECKSUM -lt 0 ]; then
			printf "\nInvalid --checksum (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $CHECKSUM -gt 15 ]; then
			printf "\nInvalid --checksum (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -z "$LENGTH" ] && [ -z "$LENGTH_MIN" ]; then
		printf "\nInvalid --length and --length-min (you cannot combine these arguments). ">&2;
		print_usage_then_exit;
	fi

	if [ -z "$LENGTH" ] && [ -z "$LENGTH_MAX" ]; then
		printf "\nInvalid --length and --length-max (you cannot combine these arguments). ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$LENGTH" ]; then
		if [ -z "$(echo $LENGTH | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --length (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH -lt 0 ]; then
			printf "\nInvalid --length (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH -gt 15 ]; then
			printf "\nInvalid --length (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$LENGTH_MIN" ]; then
		if [ -z "$(echo $LENGTH_MIN | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --length-min (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH_MIN -lt 0 ]; then
			printf "\nInvalid --length-min (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH_MIN -gt 15 ]; then
			printf "\nInvalid --length-min (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$LENGTH_MAX" ]; then
		if [ -z "$(echo $LENGTH_MAX | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --length-max (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH_MAX -lt 0 ]; then
			printf "\nInvalid --length-max (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH_MAX -gt 15 ]; then
			printf "\nInvalid --length-max (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$LENGTH_MIN" ] && [ -n "$LENGTH_MAX" ] && [ $LENGTH_MIN -ge $LENGTH_MAX ]; then
		printf "\nInvalid --length-min and --length-max (must be in ascending order). ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$CODE" ] && [ "$CODE" != "4" ] && [ -n "$NEXT_HOP_MTU" ]; then
		printf "\nInvalid --code and --next-hop-mtu (if code is not 4, next-hop-mtu is irrelevant.) ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$NEXT_HOP_MTU" ]; then
		if [ -z "$(echo $NEXT_HOP_MTU | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --next-hop-mtu (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $NEXT_HOP_MTU -lt 0 ]; then
			printf "\nInvalid --next-hop-mtu (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $NEXT_HOP_MTU -gt 15 ]; then
			printf "\nInvalid --next-hop-mtu (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi
	fi
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

OFFSET_MARKER="ih";
OFFSET_HEADER_BEGIN=0;
BIT_OFFSET_TYPE=$OFFSET_HEADER_BEGIN;
BIT_OFFSET_CODE=$(($BIT_OFFSET_TYPE+8));
BIT_OFFSET_CHECKSUM=$(($BIT_OFFSET_CODE+8));
BIT_OFFSET_UNUSED=$(($BIT_OFFSET_CHECKSUM+16));
BIT_OFFSET_LENGTH=$(($BIT_OFFSET_UNUSED+8));
BIT_OFFSET_NEXT_HOP_MTU=$(($BIT_OFFSET_LENGTH+8));
BIT_OFFSET_PAYLOAD=$(($BIT_OFFSET_NEXT_HOP_MTU+16));

printf "\\t\\t#Match Type (Destination Unreachable)\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_TYPE,8 3 \\\\\n";

if [ -n "$CODE" ]; then
	printf "\\t\\t#Match Code\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CODE,8 $CODE \\\\\n";
else
	printf "\\t\\t#Code is unrestricted.\n";
fi

if [ -n "$CHECKSUM" ]; then
	printf "\\t\\t#Match Checksum\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CHECKSUM,16 $CHECKSUM \\\\\n";
else
	printf "\\t\\t#Checksum is unrestricted.\n";
fi

if [ -n "$LENGTH" ] || [ -n "$LENGTH_MIN" ] || [ -n "$LENGTH_MAX" ]; then
	printf "\\t\\t#Match length\n";
fi
if [ -n "$LENGTH" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_LENGTH,8 $LENGTH \\\\\n";
fi
if [ -n "$LENGTH_MIN" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_LENGTH,8 >= $LENGTH_MIN \\\\\n";
fi
if [ -n "$LENGTH_MAX" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_LENGTH,8 <= $LENGTH_MAX \\\\\n";
fi
if [ -z "$LENGTH" ] && [ -z "$LENGTH_MIN" ] && [ -z "$LENGTH_MAX" ]; then
	printf "\\t\\t#Length is unrestricted.\n";
fi

if [ -n "$NEXT_HOP_MTU" ]; then
	printf "\\t\\t#Match Next Hop MTU\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_NEXT_HOP_MTU,16 $NEXT_HOP_MTU \\\\\n";
else
	printf "\\t\\t#Next Hop MTU is unrestricted.\n";
fi

exit 0;
