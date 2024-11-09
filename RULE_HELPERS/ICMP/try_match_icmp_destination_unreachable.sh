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
	printf "Dependencies: \n">&2;
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
	printf "Flags used by themselves: \n">&2;
	printf " -e (prints an explanation of the functions' purpose) (exit code 2)\n">&2;
	printf " -h (prints an explanation of the functions' available parameters, and their effect) (exit code 2)\n">&2;
	printf " -d (prints the functions' dependencies: newline delimited list) (exit code 2)\n">&2
	printf " -ehd (prints the above three) (exit code 2)\n">&2;
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
	printf "  Restrict the checksum to a specific value.\n">&2;
	printf "\n">&2;
	printf " Optional: --checksum-min x (where x is 0-65535)\n">&2;
	printf "  Restrict the checksum to a minimum.\n">&2;
	printf "\n">&2;
	printf " Optional: --checksum-max x (where x is 0-65535)\n">&2;
	printf "  Restrict the checksum to a maximum.\n">&2;
	printf "\n">&2;
	printf " You must not combine --checksum with --checksum-min or --checksum-max\n">&2;
	printf " You are not required to provide both --checksum-min and --checksum-max\n">&2;
	printf " When supplied together, --checksum-min must be less than --checksum-max\n">&2;
	printf "\n">&2;
	printf " Optional: --length x (where x is 0-255)\n">&2;
	printf "  Restrict the length to a specific number of bytes.\n">&2;
	printf "\n">&2;
	printf " Optional: --length-min x (where x is 0-255)\n">&2;
	printf "  Restrict the length to a minimum number of bytes.\n">&2;
	printf "\n">&2;
	printf " Optional: --length-max x (where x is 0-255)\n">&2;
	printf "  Restrict the length to a maximum numebr of bytes.\n">&2;
	printf "\n">&2;
	printf " You must not combine --length with --length-min or --length-max\n">&2;
	printf " You are not required to provide both --length-min and --length-max\n">&2;
	printf " When supplied together, --length-min must be less than --length-max\n">&2;
	printf "\n">&2;
	printf " Optional: --next-hop-mtu x (where x is 0-65535)\n">&2;
	printf "  Contains the MTU of the next-hop network if the code is 4 (Payload too big, Dont Fragment bit is set).\n">&2;
	printf "  Restrict the next-hop-mtu to a specific number of bytes.\n">&2;
	printf "\n">&2;
	printf " Optional: --next-hop-mtu-min x (where x is 0-65535)\n">&2;
	printf "  Restrict the next-hop-mtu to a minimum number of bytes.\n">&2;
	printf "\n">&2;
	printf " Optional: --next-hop-mtu-max x (where x is 0-65535)\n">&2;
	printf "  Restrict the next-hop-mtu to a maximum numebr of bytes.\n">&2;
	printf "\n">&2;
	printf " You must not combine --next-hop-mtu with --next-hop-mtu-min or --next-hop-mtu-max\n">&2;
	printf " You are not required to provide both --next-hop-mtu-min and --next-hop-mtu-max\n">&2;
	printf " When supplied together, --next-hop-mtu-min must be less than --next-hop-mtu-max\n">&2;
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
CHECKSUM_MIN="";
CHECKSUM_MAX="";
LENGTH="";
LENGTH_MIN="";
LENGTH_MAX="";
NEXT_HOP_MTU="";
NEXT_HOP_MTU_MIN="";
NEXT_HOP_MTU_MAX="";

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

		--next-hop-mtu-min)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				NEXT_HOP_MTU_MIN=$2;
				shift 2;
			fi
		;;

		--next-hop-mtu-max)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				NEXT_HOP_MTU_MAX=$2;
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
			printf "\nInvalid --checksum (must be 0 or greater). ">&2;
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

		CHECKSUM_MIN_IS_VALID=1;
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

		CHECKSUM_MAX_IS_VALID=1;
	fi

	if [ $CHECKSUM_MIN_IS_VALID -eq 1 ] && [ $CHECKSUM_MIN_IS_VALID -eq 1 ] && [ $CHECKSUM_MIN -ge $CHECKSUM_MAX ]; then
		printf "\nInvalid --checksum-min and --checksum-max (minimum must be less than maximum). ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$LENGTH" ] && [ -n "$LENGTH_MIN" ]; then
		printf "\nInvalid combination of --length and --length-min. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$LENGTH" ] && [ -n "$LENGTH_MAX" ]; then
		printf "\nInvalid combination of --length and --length-max. ">&2;
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

		LENGTH_MIN_IS_VALID=1;
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

		LENGTH_MAX_IS_VALID=1;
	fi

	if [ $LENGTH_MIN_IS_VALID -eq 1 ] && [ $LENGTH_MIN_IS_VALID -eq 1 ] && [ $LENGTH_MIN -ge $LENGTH_MAX ]; then
		printf "\nInvalid --length-min and --length-max (minimum must be less than maximum). ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$CODE" ] && [ "$CODE" != "4" ] && [ -n "$NEXT_HOP_MTU" ]; then
		printf "\nInvalid --code and --next-hop-mtu (if code is not 4, next-hop-mtu is irrelevant.) ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$NEXT_HOP_MTU" ] && [ -n "$NEXT_HOP_MTU_MIN" ]; then
		printf "\nInvalid combination of --next-hop-mtu and --next-hop-mtu-min. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$NEXT_HOP_MTU" ] && [ -n "$NEXT_HOP_MTU_MAX" ]; then
		printf "\nInvalid combination of --next-hop-mtu and --next-hop-mtu-max. ">&2;
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

		if [ $NEXT_HOP_MTU -gt 65535 ]; then
			printf "\nInvalid --next-hop-mtu (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi
	fi

	NEXT_HOP_MTU_MIN_IS_VALID=0;
	if [ -n "$NEXT_HOP_MTU_MIN" ]; then
		if [ -z "$(echo $NEXT_HOP_MTU_MIN | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --next-hop-mtu-min (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $NEXT_HOP_MTU_MIN -lt 0 ]; then
			printf "\nInvalid --next-hop-mtu-min (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $NEXT_HOP_MTU_MIN -gt 65535 ]; then
			printf "\nInvalid --next-hop-mtu-min (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi

		NEXT_HOP_MTU_MIN_IS_VALID=1;
	fi

	NEXT_HOP_MTU_MAX_IS_VALID=0;
	if [ -n "$NEXT_HOP_MTU_MAX" ]; then
		if [ -z "$(echo $NEXT_HOP_MTU_MAX | grep '[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --next-hop-mtu-max (must be a 1-5 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $NEXT_HOP_MTU_MAX -lt 0 ]; then
			printf "\nInvalid --next-hop-mtu-max (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $NEXT_HOP_MTU_MAX -gt 65535 ]; then
			printf "\nInvalid --next-hop-mtu-max (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi

		NEXT_HOP_MTU_MAX_IS_VALID=1;
	fi

	if [ $NEXT_HOP_MTU_MIN_IS_VALID -eq 1 ] && [ $NEXT_HOP_MTU_MIN_IS_VALID -eq 1 ] && [ $NEXT_HOP_MTU_MIN -ge $NEXT_HOP_MTU_MAX ]; then
		printf "\nInvalid --next-hop-mtu-min and --next-hop-mtu-max (minimum must be less than maximum). ">&2;
		print_usage_then_exit;
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

printf "\\t#Match Type (Destination Unreachable)\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_TYPE,8 3 \\\\\n";

if [ -n "$CODE" ]; then
	printf "\\t#Match Code\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CODE,8 $CODE \\\\\n";
else
	printf "\\t#Code is unrestricted.\n";
fi

if [ -n "$CHECKSUM" ]; then
	printf "\\t#Match Checksum (only $CHECKSUM)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CHECKSUM,16 $CHECKSUM \\\\\n";
fi

if [ -n "$CHECKSUM_MIN" ] && [ -z "$CHECKSUM_MAX" ]; then
	printf "\\t#Match Checksum (minimum $CHECKSUM_MIN)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CHECKSUM,16 >= $CHECKSUM_MIN \\\\\n";
fi

if [ -z "$CHECKSUM_MIN" ] && [ -n "$CHECKSUM_MAX" ]; then
	printf "\\t#Match Checksum (maximum $CHECKSUM_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CHECKSUM,16 <= $CHECKSUM_MAX \\\\\n";
fi

if [ -n "$CHECKSUM_MIN" ] && [ -n "$CHECKSUM_MAX" ]; then
	printf "\\t#Match Checksum ($CHECKSUM_MIN-$CHECKSUM_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CHECKSUM,16 >= $CHECKSUM_MIN \\\\\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_CHECKSUM,16 <= $CHECKSUM_MAX \\\\\n";
fi

if [ -z "$CHECKSUM" ] && [ -z "$CHECKSUM_MIN" ] && [ -z "$CHECKSUM_MAX" ]; then
	printf "\\t#Checksum is unrestricted.\n";
fi

if [ -n "$LENGTH" ]; then
	printf "\\t#Match Length (only $LENGTH)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_LENGTH,16 $LENGTH \\\\\n";
fi

if [ -n "$LENGTH_MIN" ] && [ -z "$LENGTH_MAX" ]; then
	printf "\\t#Match Length (minimum $LENGTH_MIN)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_LENGTH,16 >= $LENGTH_MIN \\\\\n";
fi

if [ -z "$LENGTH_MIN" ] && [ -n "$LENGTH_MAX" ]; then
	printf "\\t#Match Length (maximum $LENGTH_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_LENGTH,16 <= $LENGTH_MAX \\\\\n";
fi

if [ -n "$LENGTH_MIN" ] && [ -n "$LENGTH_MAX" ]; then
	printf "\\t#Match Length ($LENGTH_MIN-$LENGTH_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_LENGTH,16 >= $LENGTH_MIN \\\\\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_LENGTH,16 <= $LENGTH_MAX \\\\\n";
fi

if [ -z "$LENGTH" ] && [ -z "$LENGTH_MIN" ] && [ -z "$LENGTH_MAX" ]; then
	printf "\\t#Length is unrestricted.\n";
fi

if [ -n "$NEXT_HOP_MTU" ]; then
	printf "\\t#Match Next Hop MTU (only $NEXT_HOP_MTU)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_NEXT_HOP_MTU,16 $NEXT_HOP_MTU \\\\\n";
fi

if [ -n "$NEXT_HOP_MTU_MIN" ] && [ -z "$NEXT_HOP_MTU_MAX" ]; then
	printf "\\t#Match Next Hop MTU (minimum $NEXT_HOP_MTU_MIN)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_NEXT_HOP_MTU,16 >= $NEXT_HOP_MTU_MIN \\\\\n";
fi

if [ -z "$NEXT_HOP_MTU_MIN" ] && [ -n "$NEXT_HOP_MTU_MAX" ]; then
	printf "\\t#Match Next Hop MTU (maximum $NEXT_HOP_MTU_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_NEXT_HOP_MTU,16 <= $NEXT_HOP_MTU_MAX \\\\\n";
fi

if [ -n "$NEXT_HOP_MTU_MIN" ] && [ -n "$NEXT_HOP_MTU_MAX" ]; then
	printf "\\t#Match Next Hop MTU ($NEXT_HOP_MTU_MIN-$NEXT_HOP_MTU_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_NEXT_HOP_MTU,16 >= $NEXT_HOP_MTU_MIN \\\\\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_NEXT_HOP_MTU,16 <= $NEXT_HOP_MTU_MAX \\\\\n";
fi

if [ -z "$NEXT_HOP_MTU" ] && [ -z "$NEXT_HOP_MTU_MIN" ] && [ -z "$NEXT_HOP_MTU_MAX" ]; then
	printf "\\t#Next Hop MTU is unrestricted.\n";
fi

exit 0;
