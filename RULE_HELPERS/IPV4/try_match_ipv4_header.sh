#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_VALIDATE_LAYER_4_PROTOCOL_ID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_layer_4_protocol_id_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_LAYER_4_PROTOCOL_ID ]; then
	echo "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_LAYER_4_PROTOCOL_ID\" is missing or is not executable.";
	exit 3;
fi

DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_address_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS ]; then
	echo "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_PATH_VALIDATE_IPV4_NETWORK="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_ipv4_network_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_IPV4_NETWORK ]; then
	echo "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_IPV4_NETWORK\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_PATH_VALIDATE_DIFFERENTIATED_SERVICES_CODE="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_differentiated_services_code_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_DIFFERENTIATED_SERVICES_CODE ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_DIFFERENTIATED_SERVICES_CODE\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_cidr_network_to_base_address.sh";

if [ ! -x $DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_cidr_network_to_end_address.sh";

if [ ! -x $DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_ipv4_address_to_decimal_number.sh";

if [ ! -x $DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_description() {
	printf "A program that prints part of an NFT rule 'match' section. The match intends to match an IPV4 header.\n">&2;
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
	printf "$DEPENDENCY_PATH_VALIDATE_LAYER_4_PROTOCOL_ID\n">&2;
	printf "$DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS\n">&2;
	printf "$DEPENDENCY_PATH_VALIDATE_IPV4_NETWORK\n">&2;
	printf "$DEPENDENCY_PATH_VALIDATE_DIFFERENTIATED_SERVICES_CODE\n">&2;
	printf "$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS\n">&2;
	printf "$DEPENDENCY_PATH_CONVERT_CIDR_NETWORK_TO_END_ADDRESS\n">&2;
	printf "$DEPENDENCY_PATH_CONVERT_IPV4_ADDRESS_TO_DECIMAL\n">&2;
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
	printf " Optional: --offset-marker nh|ih\n">&2;
	printf "  the place at which to begin the raw payload expressions.\n">&2;
	printf "  here, nh means network header (or the usual place for the IPV4 header).\n">&2;
	printf "  this is most commonly what you are looking to match, unless the IPV4 header\n">&2;
	printf "  is part of the content in an encapsulating protocol (see ICMP Destination Host Unreachable).\n">&2;
	printf "  For these encapsulating protocols, the offset marker should be ih; with the predefined \"offset-header-begin\"\n">&2;
	printf "  supplied in the --offset-header-begin parameter.\n">&2;
	printf "\n">&2;
	printf " Optional: --offset-header-begin X (where X is a number from 0-65536)\n">&2;
	printf "  this indicates to the program where the beginning of the IPV4 header is.\n">&2;
	printf "  this is important for encapsulating protocols like an ICMP Destination Host Unreachable packet;\n">&2;
	printf "  otherwise, the header simply will not match.\n">&2;
	printf "\n">&2;
	printf " where the --offset-marker is not provided, the default is \"nh\" (the standard place to match an IPV4 header).\n">&2;
	printf " if --offset-header-begin is not provided, it will default to 0. If --offset-marker is \"ih\", it will potentially fail to match.\n">&2;
	printf "\n">&2;
	printf " Optional: --layer-4-protocol-id X (where X is a valid and assigned protocol number, according to IANA specifications)\n">&2;
	printf "  examples are: 1 - ICMP, 2 - IGMP, 6 - TCP, 17 - UDP... etc\n">&2;
	printf "\n">&2;
	printf " Optional: --source-address-ipv4 X.X.X.X (where X is 0-255).\n">&2;
	printf "\n">&2;
	printf " Optional: --source-network-ipv4 X.X.X.X/Y (where X is 0-255, and Y is 1-32).\n">&2;
	printf "\n">&2;
	printf " Optional: --destination-address-ipv4 X.X.X.X (where X is 0-255).\n">&2;
	printf "\n">&2;
	printf " Optional: --destination-network-ipv4 X.X.X.X/Y (where X is 0-255, and Y is 1-32).\n">&2;
	printf "\n">&2;
	printf " it is strongly recommended to supply an address, or a network; but you cannot supply both.\n">&2;
	printf " it is strongly recommended to supply both a source and destination address or network.\n">&2;
	printf " it is strongly recommended to provide networks, compared to multiple invocations using singular addresses.\n">&2;
	printf " this way, it is much faster to generate the rule, and is also faster for NFT to match the packet.\n">&2;
	printf "\n">&2;
	printf " Optional: --diff-serv-code CS0|CS1|CS2|CS3|CS4|CS5|CS6|CS7|AF11|AF12|AF13|AF21|AF22|AF23|AF31|AF32|AF33|AF41|AF42|AF43|EF|VOICE-ADMIT \n">&2;
	printf "\n">&2;
	printf " Optional: --congestion-notification not-ect|ect|ce \n">&2;
	printf "  confirm if the flags field indicates one of:\n">&2;
	printf "   1. not-ect-capable transport / no ability to handle ECT bits.\n">&2;
	printf "   2. ect-capable transport / ability to indicate, identify, and react according to link congestion\n">&2;
	printf "   3. ect-capable transport, and congestion is actively experienced. Routers may be throttling links.\n">&2;
	printf "\n">&2;
	printf " Optional: --length x (where x is 0-65535)\n">&2;
	printf "  Restrict the packet to an exact length.\n">&2;
	printf "\n">&2;
	printf " Optional: --length-min x (where x is -065535).\n">&2;
	printf "  Restrict the packet to a minimum length.\n">&2;
	printf "\n">&2;
	printf " Optional: --length-max x (where x is 0-65535).\n">&2;
	printf "  Restrict the packet to a maximum length.\n">&2;
	printf "\n">&2;
	printf " You mus not combine min or max length with an exact length.\n">&2;
	printf " You are not required to supply both a min and max length.\n">&2;
	printf " When supplied together, min length must be less than max length.\n">&2;
	printf "\n">&2;
	printf " Optional: --identification x (where x is 0-65535)\n">&2;
	printf "  Restrict the ID field to an exact number.\n">&2;
	printf "\n">&2;
	printf " Optional: --identification-min x (where x is 0-65535)\n">&2;
	printf "  Restrict the ID field to a minimum number.\n">&2;
	printf "\n">&2;
	printf " Optional: --identification-max x (where x is 0-65535)\n">&2;
	printf "  Restrict the ID field to a maximum number.\n">&2;
	printf "\n">&2;
	printf " You must not combine --identification with --identification-min or --identification-max.\n">&2;
	printf " You are not required to supply both --identification-min and --identification-max.\n">&2;
	printf " When supplied together, --identificatio-min must be less than --identification-max.\n">&2;
	printf "\n">&2;
	printf " Optional: --fragments-enabled yes|no\n">&2;
	printf "  in order to comply with a Maximum Segment Size (MSS), or Maximum Transmission Unit (MTU); where the frame would otherwise be dropped:\n">&2;
	printf "  yes: intermediaries may fragment frames\n">&2;
	printf "  no: intermediaries may not fragment frames; drop them.\n">&2;
	printf "  not provided: no preference, packets may or may not be fragmented.\n">&2;
	printf "\n">&2;
	printf " Optional: --fragments-continue yes|no\n">&2;
	printf "  yes: more fragments will be transmitted.\n">&2;
	printf "  no: this is the last fragment in the frame.\n">&2;
	printf "  not provided: no preference for the point in fragment transmission.\n">&2;
	printf "\n">&2;
	printf " You must not combine --fragments-enabled 'yes' and --fragments-continue 'yes'\n">&2;
	printf "\n">&2;
	printf " Optional: --frag-offset x (where x is 0-8192)\n">&2;
	printf "  confirm if the packet offset is an exact number.\n">&2;
	printf "\n">&2;
	printf " Optional: --frag-offset-min x (where x is 0-8912)\n">&2;
	printf "  limit the offset of this fragment of the frame to a minimum.\n">&2;
	printf "\n">&2;
	printf " Optional: --frag-offset-max x (where x is 0-8192)\n">&2;
	printf "  limit the offset of this fragment of the frame to a maximum.\n">&2;
	printf "\n">&2;
	printf " You must not combine min or max frag offset with an exact offset restriction.\n">&2;
	printf " You are not required to supply both a min and max frag offset.\n">&2;
	printf " When supplied together, --frag-offset-min must be less than --frag-offset-max\n">&2;
	printf "\n">&2;
	printf " Optional: --ttl x (where x is 1-255)\n">&2;
	printf "  restrict to a number of routers the packet may traverse.\n">&2;
	printf "\n">&2;
	printf " Optional: --ttl-min x (where x is 1-255)\n">&2;
	printf "  restrict the minimum number of routers the packet may traverse.\n">&2;
	printf "\n">&2;
	printf " Optional: --ttl-max x (where x is 1-255)\n">&2;
	printf "  restrict the maximum number of routers the packet may traverse.\n">&2;
	printf "\n">&2;
	printf " You must not combine --ttl with --ttl-min or --ttl-max\n">&2;
	printf " You are not required to supply both --ttl-min and --ttl-max\n">&2;
	printf " When supplied together, --ttl-min must be less than --ttl-max\n">&2;
	printf "\n">&2;
	printf " Optional: --header-checksum x (where x is 0-65535)\n">&2;
	printf "  match a specific header checksum (if you are identifying a previously sent transmission)\n">&2;
	printf "\n">&2;
	printf " Optional: --header-checksum-min x (where x is 0-65535)\n">&2;
	printf "  Restrict the header checksum to a minimum\n">&2;
	printf "\n">&2;
	printf " Optional: --header-checksum-max x (where x is 0-65535)\n">&2;
	printf "  Restrict the header checksum to a maximum\n">&2;
	printf "\n">&2;
	printf " You must not combine --header-checksum with --header-checksum-min or --header-checksum-max\n">&2;
	printf " You are not required to supply both --header-checksum-min and --header-checksum-max\n">&2;
	printf " When supplied together, --header-checksum-min must be less than --header-checksum-max\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf "  enabling this flag causes the program to skip validating inputs (if you know they are valid already).\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validation\n">&2;
	printf "  enabling this flag causes the program to exit after performing validation.\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
OFFSET_MARKER="nh";
OFFSET_HEADER_BEGIN=0;
LAYER_4_PROTOCOL_ID="";
SOURCE_ADDRESS_IPV4="";
DESTINATION_ADDRESS_IPV4="";
SOURCE_NETWORK_IPV4="";
DESTINATION_NETWORK_IPV4="";
DIFF_SERV_DROP_PROBABILITY="";
DIFF_SERV_CLASS="";
CONGESTION_NOTIFICATION="";
LENGTH="";
LENGTH_MIN="";
LENGTH_MAX="";
IDENTIFICATION="";
IDENTIFICATION_MIN="";
IDENTIFICATION_MAX="";
FRAG_OFFSET="";
FRAG_OFFSET_MIN="";
FRAG_OFFSET_MAX="";
TTL="";
TTL_MIN="";
TTL_MAX="";
HEADER_CHECKSUM="";
HEADER_CHECKSUM_MIN="";
HEADER_CHECKSUM_MAX="";

#FLAGS:
FRAGMENTS_ENABLED=-1;
FRAGMENTS_CONTINUE=-1;
SKIP_VALIDATION=-1;
ONLY_VALIDATE=0;

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

		--layer-4-protocol-id)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				LAYER_4_PROTOCOL_ID=$2;
				shift 2;
			fi
		;;

		--source-address-ipv4)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				SOURCE_ADDRESS_IPV4=$2;
				shift 2;
			fi
		;;

		--source-network-ipv4)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				SOURCE_NETWORK_IPV4=$2;
				shift 2;
			fi
		;;

		--destination-address-ipv4)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				DESTINATION_ADDRESS_IPV4=$2;
				shift 2;
			fi
		;;

		--destination-network-ipv4)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				DESTINATION_NETWORK_IPV4=$2;
				shift 2;
			fi
		;;

		--diff-serv-code)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				DIFF_SERV_CODE=$2;
				shift 2;
			fi
		;;

		--congestion-notification)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				CONGESTION_NOTIFICATION=$2;
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

		--identification)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				IDENTIFICATION=$2;
				shift 2;
			fi
		;;

		--identification-min)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				IDENTIFICATION_MIN=$2;
				shift 2;
			fi
		;;

		--identification-max)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				IDENTIFICATION_MAX=$2;
				shift 2;
			fi
		;;

		--fragments-enabled)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				FRAGMENTS_ENABLED=$2;
				shift 2;
			fi
		;;


		--fragments-continue)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				FRAGMENTS_CONTINUE=$2;
				shift 2;
			fi
		;;

		--frag-offset)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				FRAG_OFFSET=$2;
				shift 2;
			fi
		;;

		--frag-offset-min)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				FRAG_OFFSET_MIN=$2;
				shift 2;
			fi
		;;

		--frag-offset-max)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				FRAG_OFFSET_MAX=$2;
				shift 2;
			fi
		;;

		--ttl)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				TTL=$2;
				shift 2;
			fi
		;;

		--ttl-min)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				TTL_MIN=$2;
				shift 2;
			fi
		;;

		--ttl-max)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				TTL_MAX=$2;
				shift 2;
			fi
		;;

		--header-checksum)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				HEADER_CHECKSUM=$2;
				shift 2;
			fi
		;;

		--header-checksum-min)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				HEADER_CHECKSUM_MIN=$2;
				shift 2;
			fi
		;;

		--header-checksum-max)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				HEADER_CHECKSUM_MAX=$2;
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
	if [ -n "$OFFSET_MARKER" ]; then
		case $OFFSET_MARKER in
			nh) ;;
			ih) ;;
			*) printf "\nInvalid --offset-marker. ">&2; print_usage_then_exit; ;;
		esac
	fi

	if [ -n "$OFFSET_HEADER_BEGIN" ]; then
		if [ -z "$(echo $OFFSET_HEADER_BEGIN | grep '[-]\{0,1\}[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --offset-header-begin (must be a 1-5 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $OFFSET_HEADER_BEGIN -lt 0 ]; then
			printf "\nInvalid --offset-header-begin (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$LAYER_4_PROTOCOL_ID" ]; then
		$DEPENDENCY_PATH_VALIDATE_LAYER_4_PROTOCOL_ID --id $LAYER_4_PROTOCOL_ID;
		case $? in
			0) ;;
			1) printf "\nInvalid --layer-4-protocol-id. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency \"$DEPENDENCY_PATH_VALIDATE_LAYER_4_PROTOCOL_ID\" produced a failure exit code.">&2; exit 3; ;;
		esac
	fi

	if [ -n "$SOURCE_ADDRESS_IPV4" ] && [ -n "$SOURCE_NETWORK_IPV4" ]; then
		printf "\nInvalid combination of --source-address-ipv4 and --source-network-ipv4. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$SOURCE_ADDRESS_IPV4" ]; then
		$DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS --address $SOURCE_ADDRESS_IPV4;
		case $? in
			0) ;;
			1) printf "\nInvalid --source-address-ipv4. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency \"$DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS\" produced a failure exit code.">&2; exit 3; ;;
		esac
	fi

	if [ -n "$SOURCE_NETWORK_IPV4" ]; then
		$DEPENDENCY_PATH_VALIDATE_IPV4_NETWORK --network $SOURCE_NETWORK_IPV4;
		case $? in
			0) ;;
			1) printf "\nInvalid --source-network-ipv4. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency \"$DEPENDENCY_PATH_VALIDATE_IPV4_NETWORK\" produced a failure exit code.">&2; exit 3; ;;
		esac
	fi

	if [ -n "$DESTINATION_ADDRESS_IPV4" ] && [ -n "$DESTINATION_NETWORK_IPV4" ]; then
		printf "\nInvalid combination of --destination-address-ipv4 and --destination-network-ipv4. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$DESTINATION_ADDRESS_IPV4" ]; then
		$DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS --address $DESTINATION_ADDRESS_IPV4;
		case $? in
			0) ;;
			1) printf "\nInvalid --destination-address-ipv4. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency \"$DEPENDENCY_PATH_VALIDATE_IPV4_ADDRESS\" produced a failure exit code.">&2; exit 3; ;;
		esac
	fi

	if [ -n "$DESTINATION_NETWORK_IPV4" ]; then
		$DEPENDENCY_PATH_VALIDATE_IPV4_NETWORK --network $DESTINATION_NETWORK_IPV4;
		case $? in
			0) ;;
			1) printf "\nInvalid --destination-network-ipv4. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency \"$DEPENDENCY_PATH_VALIDATE_IPV4_NETWORK\" produced a failure exit code.">&2; exit 3; ;;
		esac
	fi

	if [ -n "$DIFF_SERV_CODE" ]; then
		case $DIFF_SERV_CODE in
			CS0|CS1|CS2|CS3|CS4|CS5|CS6|CS7|AF11|AF12|AF13|AF21|AF22|AF23|AF31|AF32|AF33|AF41|AF42|AF43|EF|VOICE-ADMIT) ;;
			*) printf "\nInvalid --diff-serv-code. ">&2; print_usage_then_exit; ;;
		esac
	fi

	if [ -n "$CONGESTION_NOTIFICATION" ]; then
		case $CONGESTION_NOTIFICATION in
			not-ect) ;;
			ect) ;;
			ce) ;;
			*) printf "\nInvalid --congestion-notification. ">&2; print_usage_then_exit; ;;
		esac
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
		if [ -z "$(echo $LENGTH | grep '[-]\{0,1\}[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --length (must be a 1-5 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH -lt 0 ]; then
			printf "\nInvalid --length (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH -gt 65535 ]; then
			printf "\nInvalid --length (must be less than 65,536). ">&2;
			print_usage_then_exit;
		fi
	fi

	LENGTH_MIN_IS_VALID=0;
	if [ -n "$LENGTH_MIN" ]; then
		if [ -z "$(echo $LENGTH_MIN | grep '[-]\{0,1\}[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --length-min (must be a 1-5 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH -lt 0 ]; then
			printf "\nInvalid --length-min (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH -gt 65535 ]; then
			printf "\nInvalid --length-min (must be less than 65,536). ">&2;
			print_usage_then_exit;
		fi

		LENGTH_MIN_IS_VALID=1;
	fi

	LENGTH_MAX_IS_VALID=0;
	if [ -n "$LENGTH_MAX" ]; then
		if [ -z "$(echo $LENGTH_MAX | grep '[-]\{0,1\}[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --length-max (must be a 1-5 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH -lt 0 ]; then
			printf "\nInvalid --length-max (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH -gt 65535 ]; then
			printf "\nInvalid --length-max (must be less than 65,536). ">&2;
			print_usage_then_exit;
		fi

		LENGTH_MAX_IS_VALID=1;
	fi

	if [ $LENGTH_MIN_IS_VALID -eq 1 ] && [ $LENGTH_MAX_IS_VALID -eq 1 ] && [ $LENGTH_MIN -ge $LENGTH_MAX ]; then
		printf "\nInvalid --length-min or --length-max (minimum cannot be greater than or equal to maximum.) ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$IDENTIFICATION" ] && [ -n "$IDENTIFICATION_MIN" ]; then
		printf "\nInvalid combination of --identification and --identification-min. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$IDENTIFICATION" ] && [ -n "$IDENTIFICATION_MAX" ]; then
		printf "\nInvalid combination of --identification and --identification-max. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$IDENTIFICATION" ]; then
		if [ -z "$(echo $IDENTIFICATION | grep '[-]\{0,1\}[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --identification (must be a 1-5 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $IDENTIFICATION -lt 0 ]; then
			printf "\nInvalid --identification (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $IDENTIFICATION -gt 65535 ]; then
			printf "\nInvalid --identification (must be less than 65,536). ">&2;
			print_usage_then_exit;
		fi
	fi

	IDENTIFICATION_MIN_IS_VALID=0;
	if [ -n "$IDENTIFICATION_MIN" ]; then
		if [ -z "$(echo $IDENTIFICATION_MIN | grep '[-]\{0,1\}[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --identification-min (must be a 1-5 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $IDENTIFICATION_MIN -lt 0 ]; then
			printf "\nInvalid --identification-min (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $IDENTIFICATION_MIN -gt 65535 ]; then
			printf "\nInvalid --identification-min (must be less than 65,536). ">&2;
			print_usage_then_exit;
		fi

		IDENTIFICATION_MIN_IS_VALID=1;
	fi

	IDENTIIFCAITON_MAX_IS_VALID=0;
	if [ -n "$IDENTIFICATION_MAX" ]; then
		if [ -z "$(echo $IDENTIFICATION_MAX | grep '[-]\{0,1\}[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --identification (must be a 1-5 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $IDENTIFICATION_MAX -lt 0 ]; then
			printf "\nInvalid --identification-max (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $IDENTIFICATION_MAX -gt 65535 ]; then
			printf "\nInvalid --identification-max (must be less than 65,536). ">&2;
			print_usage_then_exit;
		fi

		IDENTIIFCAITON_MAX_IS_VALID=1;
	fi

	if [ $IDENTIFICATION_MIN_IS_VALID -eq 1 ] && [ $IDENTIFICATION_MAX_IS_VALID -eq 1 ] && [ $IDENTIFICATION_MIN -ge $IDENTIFICATION_MAX ]; then
		printf "\nInvalid --identification-min or --identification-max (minimum cannot be greater than or equal to maximum.) ">&2;
		print_usage_then_exit;
	fi

	if [ "$FRAGMENTS_ENABLED" = "no" ] && [ "$FRAGMENTS_CONTINUE" = "yes" ]; then
		printf "\nWhile --fragments-enabled is no, --fragments-continue must be no. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$FRAGMENTS_ENABLED" ]; then
		case $FRAGMENTS_ENABLED in
			yes) ;;
			no) ;;
			*) printf "\nInvalid --fragments-enabled. ">&2; print_usage_then_exit; ;;
		esac
	fi

	if [ -n "$FRAGMENTS_CONTINUE" ]; then
		case $FRAGMENTS_CONTINUE in
			yes) ;;
			no) ;;
			*) printf "\nInvalid --fragments-continue. ">&2; print_usage_then_exit; ;;
		esac
	fi

	if [ -n "$FRAG_OFFSET" ] && [ -n "$FRAG_OFFSET_MIN" ]; then
		printf "\nInvalid combination of --frag-offset and --frag-offset-min. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$FRAG_OFFSET" ] && [ -n "$FRAG_OFFSET_MAX" ]; then
		printf "\nInvalid combination of --frag-offset and --frag-offset-max. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$FRAG_OFFSET" ]; then
		if [ -z "$(echo $FRAG_OFFSET | grep '[-]\{0,1\}[0-9]\{1,4\}')" ]; then
			printf "\nInvalid --frag-offset (must be a 1-4 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $FRAG_OFFSET -lt 0 ]; then
			printf "\nInvalid --frag-offset (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $FRAG_OFFSET -gt 8191 ]; then
			printf "\nInvalid --frag-offset (must be less than 8192). ">&2;
			print_usage_then_exit;
		fi
	fi

	FRAG_OFFSET_MIN_IS_VALID=0;
	if [ -n "$FRAG_OFFSET_MIN" ]; then
		if [ -z "$(echo $FRAG_OFFSET_MIN | grep '[-]\{0,1\}[0-9]\{1,4\}')" ]; then
			printf "\nInvalid --frag-offset-min (must be a 1-4 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $FRAG_OFFSET_MIN -lt 0 ]; then
			printf "\nInvalid --frag-offset-min (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $FRAG_OFFSET_MIN -gt 8191 ]; then
			printf "\nInvalid --frag-offset-min (must be less than 8192). ">&2;
			print_usage_then_exit;
		fi

		FRAG_OFFSET_MIN_IS_VALID=1;
	fi

	FRAG_OFFSET_MAX_IS_VALID=0;
	if [ -n "$FRAG_OFFSET_MAX" ]; then
		if [ -z "$(echo $FRAG_OFFSET_MAX | grep '[-]\{0,1\}[0-9]\{1,4\}')" ]; then
			printf "\nInvalid --frag-offset-max (must be a 1-4 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $FRAG_OFFSET_MAX -lt 0 ]; then
			printf "\nInvalid --frag-offset-max (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $FRAG_OFFSET_MAX -gt 8191 ]; then
			printf "\nInvalid --frag-offset-max (must be less than 8192). ">&2;
			print_usage_then_exit;
		fi

		FRAG_OFFSET_MAX_IS_VALID=1;
	fi

	if [ $FRAG_OFFSET_MIN_IS_VALID -eq 1 ] && [ $FRAG_OFFSET_MAX_IS_VALID -eq 1 ] && [ $FRAG_OFFSET_MIN -ge $FRAG_OFFSET_MAX ]; then
		printf "\nInvalid --frag-offset-min or --frag-offset-max (minimum cannot be greater than or equal to maximum) ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$TTL" ] && [ -n "$TTL_MIN" ]; then
		printf "\nInvalid combination of --ttl and --ttl-min. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$TTL" ] && [ -n "$TTL_MAX" ]; then
		printf "\nInvalid combination of --ttl and --ttl-max. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$TTL" ]; then
		if [ -z "$(echo $TTL | grep '[-]\{0,1\}[0-9]\{1,3\}')" ]; then
			printf "\nInvalid --ttl (must be a 1-3 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $TTL -lt 0 ]; then
			printf "\nInvalid --ttl (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $TTL -gt 255 ]; then
			printf "\nInvalid --ttl (must be less than 256). ">&2;
			print_usage_then_exit;
		fi
	fi

	TTL_MIN_IS_VALID=0;
	if [ -n "$TTL_MIN" ]; then
		if [ -z "$(echo $TTL_MIN | grep '[-]\{0,1\}[0-9]\{1,3\}')" ]; then
			printf "\nInvalid --ttl-min (must be a 1-3 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $TTL_MIN -lt 0 ]; then
			printf "\nInvalid --ttl-min (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $TTL_MIN -gt 255 ]; then
			printf "\nInvalid --ttl-min (must be less than 256). ">&2;
			print_usage_then_exit;
		fi

		TTL_MIN_IS_VALID=1;
	fi

	TTL_MAX_IS_VALID=0;
	if [ -n "$TTL_MAX" ]; then
		if [ -z "$(echo $TTL_MAX | grep '[-]\{0,1\}[0-9]\{1,3\}')" ]; then
			printf "\nInvalid --ttl-max (must be a 1-3 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $TTL_MAX -lt 0 ]; then
			printf "\nInvalid --ttl-max (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $TTL_MAX -gt 255 ]; then
			printf "\nInvalid --ttl-max (must be less than 256). ">&2;
			print_usage_then_exit;
		fi

		TTL_MAX_IS_VALID=1;
	fi

	if [ $TTL_MIN_IS_VALID -eq 1 ] && [ $TTL_MIN_IS_VALID -eq 1 ] && [ $TTL_MIN -ge $TTL_MAX ]; then
		printf "\nInvalid --ttl-min or --ttl-max (minimum cannot be greater than or equal to maximum) ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$HEADER_CHECKSUM" ] && [ -n "$HEADER_CHECKSUM_MIN" ]; then
		printf "\nInvalid combination of --header-checksum and --header-checksum-min. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$HEADER_CHECKSUM" ] && [ -n "$HEADER_CHECKSUM_MAX" ]; then
		printf "\nInvalid combination of --header-checksum and --header-checksum-max. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$HEADER_CHECKSUM" ]; then
		if [ -z "$(echo $HEADER_CHECKSUM | grep '[-]\{0,1\}[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --header-checksum (must be a 1-5 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $HEADER_CHECKSUM -lt 0 ]; then
			printf "\nInvalid --header-checksum (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $HEADER_CHECKSUM -gt 65535 ]; then
			printf "\nInvalid --header-checksum (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi
	fi

	HEADER_CHECKSUM_MIN_IS_VALID=0;
	if [ -n "$HEADER_CHECKSUM_MIN" ]; then
		if [ -z "$(echo $HEADER_CHECKSUM_MIN | grep '[-]\{0,1\}[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --header-checksum-min (must be a 1-5 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $HEADER_CHECKSUM_MIN -lt 0 ]; then
			printf "\nInvalid --header-checksum-min (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $HEADER_CHECKSUM_MIN -gt 65535 ]; then
			printf "\nInvalid --header-checksum-min (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi
	fi

	HEADER_CHECKSUM_MAX_IS_VALID=0;
	if [ -n "$HEADER_CHECKSUM_MAX" ]; then
		if [ -z "$(echo $HEADER_CHECKSUM_MAX | grep '[-]\{0,1\}[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --header-checksum-max (must be a 1-5 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $HEADER_CHECKSUM_MAX -lt 0 ]; then
			printf "\nInvalid --header-checksum-max (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $HEADER_CHECKSUM_MAX -gt 65535 ]; then
			printf "\nInvalid --header-checksum-max (must be less than 65536). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ $HEADER_CHECKSUM_MIN_IS_VALID -eq 1 ] && [ $HEADER_CHECKSUM_MAX_IS_VALID -eq 1 ] && [ $HEADER_CHECKSUM_MIN -ge $HEADER_CHECKSUM_MAX ]; then
		printf "\nInvalid --header-checksum-min or --header-checksum-max (minimum cannot be greater than or equal to maximum) ">&2;
		print_usage_then_exit;
	fi
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

SOURCE_ADDRESS_IPV4_DECIMAL="";
if [ -n "$SOURCE_ADDRESS_IPV4" ]; then
	SOURCE_ADDRESS_IPV4_DECIMAL=$($DEPENDENCY_SCRIPT_CONVERT_IPV4_ADDRESS_TO_DECIMAL --address $SOURCE_ADDRESS_IPV4);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_SCRIPT_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" produced a failure exit code. ">&2; print_usage_then_exit; ;;
	esac
fi

SOURCE_BASE_ADDRESS_IPV4="";
SOURCE_BASE_ADDRESS_IPV4_DECIMAL="";
SOURCE_END_ADDRESS_IPV4="";
SOURCE_END_ADDRESS_IPV4_DECIMAL="";
if [ -n "$SOURCE_NETWORK_IPV4" ]; then
	SOURCE_BASE_ADDRESS_IPV4=$($DEPENDENCY_SCRIPT_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS --network $SOURCE_NETWORK_IPV4);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_SCRIPT_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS\" produced a failure exit code. ">&2; print_usage_then_exit; ;;
	esac

	SOURCE_BASE_ADDRESS_IPV4_DECIMAL=$($DEPENDENCY_SCRIPT_CONVERT_IPV4_ADDRESS_TO_DECIMAL --address $SOURCE_BASE_ADDRESS_IPV4);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_SCRIPT_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" produced a failure exit code. ">&2; print_usage_then_exit; ;;
	esac

	SOURCE_END_ADDRESS_IPV4=$($DEPENDENCY_SCRIPT_CONVERT_CIDR_NETWORK_TO_END_ADDRESS --network $SOURCE_NETWORK_IPV4);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_SCRIPT_CONVERT_CIDR_NETWORK_TO_END_ADDRESS\" produced a failure exit code. ">&2; print_usage_then_exit; ;;
	esac

	SOURCE_END_ADDRESS_IPV4_DECIMAL=$($DEPENDENCY_SCRIPT_CONVERT_IPV4_ADDRESS_TO_DECIMAL --address $SOURCE_END_ADDRESS_IPV4);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_SCRIPT_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" produced a failure exit code. ">&2; print_usage_then_exit; ;;
	esac
fi

DESTINATION_ADDRESS_IPV4_DECIMAL="";
if [ -n "$DESTINATION_ADDRESS_IPV4" ]; then
	DESTINATION_ADDRESS_IPV4_DECIMAL=$($DEPENDENCY_SCRIPT_CONVERT_IPV4_ADDRESS_TO_DECIMAL --address $DESTINATION_ADDRESS_IPV4);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_SCRIPT_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" produced a failure exit code. ">&2; print_usage_then_exit; ;;
	esac
fi

DESTINATION_BASE_ADDRESS_IPV4="";
DESTINATION_BASE_ADDRESS_IPV4_DECIMAL="";
DESTINATION_END_ADDRESS_IPV4="";
DESTINATION_END_ADDRESS_IPV4_DECIMAL="";
if [ -n "$DESTINATION_NETWORK_IPV4" ]; then
	DESTINATION_BASE_ADDRESS_IPV4=$($DEPENDENCY_SCRIPT_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS --network $DESTINATION_NETWORK_IPV4);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_SCRIPT_CONVERT_CIDR_NETWORK_TO_BASE_ADDRESS\" produced a failure exit code. ">&2; print_usage_then_exit; ;;
	esac

	DESTINATION_BASE_ADDRESS_IPV4_DECIMAL=$($DEPENDENCY_SCRIPT_CONVERT_IPV4_ADDRESS_TO_DECIMAL --address $DESTINATION_BASE_ADDRESS_IPV4);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_SCRIPT_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" produced a failure exit code. ">&2; print_usage_then_exit; ;;
	esac

	DESTINATION_END_ADDRESS_IPV4=$($DEPENDENCY_SCRIPT_CONVERT_CIDR_NETWORK_TO_END_ADDRESS --network $DESTINATION_NETWORK_IPV4);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_SCRIPT_CONVERT_CIDR_NETWORK_TO_END_ADDRESS\" produced a failure exit code. ">&2; print_usage_then_exit; ;;
	esac

	DESTINATION_END_ADDRESS_IPV4_DECIMAL=$($DEPENDENCY_SCRIPT_CONVERT_IPV4_ADDRESS_TO_DECIMAL --address $DESTINATION_END_ADDRESS_IPV4);
	case $? in
		0) ;;
		*) printf "$0: dependency \"$DEPENDENCY_SCRIPT_CONVERT_IPV4_ADDRESS_TO_DECIMAL\" produced a failure exit code. ">&2; print_usage_then_exit; ;;
	esac
fi


OFFSET_VERSION=$OFFSET_HEADER_BEGIN;
OFFSET_IHL=$(($OFFSET_BEGIN+4));
OFFSET_DIFF_SERV_CODE=$(($OFFSET_IHL+4));
OFFSET_CONGESTION_NOTIFICATION=$(($OFFSET_DIFF_SERV_CODE+6));
OFFSET_LENGTH=$(($OFFSET_CONGESTION_NOTIFICATION+2));
OFFSET_IDENTIFICATION=$(($OFFSET_LENGTH+16));
OFFSET_RESERVED_BIT=$(($OFFSET_IDENTIFICATION+16));
OFFSET_FRAGMENTS_ENABLED=$(($OFFSET_RESERVED_BIT+1));
OFFSET_FRAGMENTS_CONTINUE=$(($OFFSET_FRAGMENTS_ENABLED+1));
OFFSET_FRAG_OFFSET=$(($OFFSET_FRAGMENTS_CONTINUE+1));
OFFSET_TTL=$(($OFFSET_FRAG_OFFSET+13));
OFFSET_LAYER_4_PROTOCOL_ID=$(($OFFSET_TTL+8));
OFFSET_HEADER_CHECKSUM=$(($OFFSET_LAYER_4_PROTOCOL_ID+8));
OFFSET_SOURCE_HOST_ID=$(($OFFSET_HEADER_CHECKSUM+16));
OFFSET_DESTINATION_HOST_ID=$(($OFFSET_SOURCE_HOST_ID+32));
OFFSET_OPTIONS=$(($OFFSET_DESTINATION_HOST_ID+32));

printf "\\t#Confirm VERSION is 4\n";
printf "\\t\\t@$OFFSET_MARKER,$OFFSET_VERSION,4 4 \\\\\n";

printf "\\t#Confirm IHL is 5 (32-bit words) in length / no \"options\" are present.\n";
printf "\\t\\t@$OFFSET_MARKER,$OFFSET_IHL,4 5 \\\\\n";

if [ -n "$DIFF_SERV_CODE" ]; then
	printf "\\t#Match Differentiated Services Code ";
	DIFF_SERV_DECIMAL=-1;
	case $DIFF_SERV_CODE in
		CS0) DIFF_SERV_DECIMAL=0; ;;
		CS1) DIFF_SERV_DECIMAL=8; ;;
		CS2) DIFF_SERV_DECIMAL=16; ;;
		CS3) DIFF_SERV_DECIMAL=24; ;;
		CS4) DIFF_SERV_DECIMAL=32; ;;
		CS5) DIFF_SERV_DECIMAL=40; ;;
		CS6) DIFF_SERV_DECIMAL=48; ;;
		CS7) DIFF_SERV_DECIMAL=56; ;;
		AF11) DIFF_SERV_DECIMAL=10; ;;
		AF12) DIFF_SERV_DECIMAL=12; ;;
		AF13) DIFF_SERV_DECIMAL=14; ;;
		AF21) DIFF_SERV_DECIMAL=18; ;;
		AF22) DIFF_SERV_DECIMAL=20; ;;
		AF23) DIFF_SERV_DECIMAL=22; ;;
		AF31) DIFF_SERV_DECIMAL=26; ;;
		AF32) DIFF_SERV_DECIMAL=28; ;;
		AF33) DIFF_SERV_DECIMAL=30; ;;
		AF41) DIFF_SERV_DECIMAL=34; ;;
		AF42) DIFF_SERV_DECIMAL=36; ;;
		AF43) DIFF_SERV_DECIMAL=38; ;;
		EF) DIFF_SERV_DECIMAL=46; ;;
		VOICE-ADMIT) DIFF_SERV_DECIMAL=44; ;;
	esac

	printf "($DIFF_SERV_CODE)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_DIFF_SERV_CODE,6 $DIFF_SERV_DECIMAL \\\\\n";
else
	printf "\\t#Differentiated Services Code unrestricted.\n";
fi

if [ -n "$CONGESTION_NOTIFICATION" ]; then
	printf "\\t#Confirm Congestion Notification ";
	case $CONGESTION_NOTIFICATION in
		not-ect)
			printf "(Not Explicit Congestion Notification Enabled Transport)\n";
			printf "\\t\\t@$OFFSET_MARKER,$OFFSET_CONGESTION_NOTIFICATION,2 0 \\\\\n";
		;;
		ect)
			printf "(Explicit Congestion Notification Enabled Transport)\n";
			printf "\\t\\t@$OFFSET_MARKER,$OFFSET_CONGESTION_NOTIFICATION,2 { 1, 2 } \\\\\n";
		;;
		ce)
			printf "(Congestion Experienced)\n";
			printf "\\t\\t@$OFFSET_MARKER,$OFFSET_CONGESTION_NOTIFICATION,2 3 \\\\\n";
		;;
	esac
else
	printf "\\t#Congestion Notification (ECN-Capable / Congestion Experience bits) are unrestricted\n";
fi

if [ -n "$LENGTH" ]; then
	printf "\\t#Confirm Length (only $LENGTH)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_LENGTH,16 $LENGTH \\\\\n";
fi

if [ -n "$LENGTH_MIN" ] && [ -z "$LENGTH_MAX" ]; then
	printf "\\t#Confirm Length (minimum $LENGTH_MIN)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_LENGTH,16 >= $LENGTH_MIN \\\\\n";
fi

if [ -z "$LENGTH_MIN" ] && [ -n "$LENGTH_MAX" ]; then
	printf "\\t#Confirm Length (maximum $LENGTH_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_LENGTH,16 <= $LENGTH_MAX \\\\\n";
fi

if [ -n "$LENGTH_MIN" ] && [ -n "$LENGTH_MAX" ]; then
	printf "\\t#Confirm Length ($LENGTH_MIN-$LENGTH_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_LENGTH,16 >= $LENGTH_MIN \\\\\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_LENGTH,16 <= $LENGTH_MAX \\\\\n";
fi

if [ -z "$LENGTH" ] && [ -z "$LENGTH_MIN" ] && [ -z "$LENGTH_MAX" ]; then
	printf "\\t#Length is unrestricted - consider the security implications\n";
fi

if [ -n "$IDENTIFICATION" ]; then
	printf "\\t#Confirm Identification (only $IDENTIFICATION)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_IDENTIFICATION,16 $IDENTIFICATION \\\\\n";
fi

if [ -n "$IDENTIFICATION_MIN" ] && [ -z "$IDENTIFICATION_MAX" ]; then
	printf "\\t#Confirm Identification (minimum $IDENTIFICATION_MIN)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_IDENTIFICATION,16 >= $IDENTIFICATION_MIN \\\\\n";
fi

if [ -z "$IDENTIFICATION_MIN" ] && [ -n "$IDENTIFICATION_MAX" ]; then
	printf "\\t#Confirm Identification (maximum $IDENTIFICATION_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_IDENTIFICATION,16 <= $IDENTIFICATION_MAX \\\\\n";
fi

if [ -n "$IDENTIFICATION_MIN" ] && [ -n "$IDENTIFICATION_MAX" ]; then
	printf "\\t#Confirm Identification ($IDENTIFICATION_MIN-$IDENTIFICATION_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_IDENTIFICATION,16 >= $IDENTIFICATION_MIN \\\\\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_IDENTIFICATION,16 <= $IDENTIFICATION_MAX \\\\\n";
fi

if [ -z "$IDENTIFICATION" ] && [ -z "$IDENTIFICATION_MIN" ] && [ -z "$IDENTIFICATION_MAX" ]; then
	printf "\\t#Identification is unrestricted\n";
fi

printf "\\t#Match 'Reserved bit'\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_RESERVED_BIT,1 0 \\\\\n";

if [ $FRAGMENTS_ENABLED -eq 0 ] || [ $FRAGMENTS_ENABLED -eq 1 ]; then
	printf "\\t#Match ";
	case $FRAGMENTS_ENABLED in
		0)
			printf "'Fragments Disabled'\n";
			printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FRAGMENTS_TOGGLE,1 0 \\\\\n";
		;;
		1)
			printf "'Fragments Enabled'\n";
			printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FRAGMENTS_TOGGLE,1 1 \\\\\n";
		;;
	esac
else
	printf "\\t#Preference for Fragments Enabled/Disabled is not enforced.\n";
fi

if [ $FRAGMENTS_CONTINUE -eq 0 ] || [ $FRAGMENTS_CONTINUE -eq 1 ]; then
	printf "\\t#Match "
	case $FRAGMENTS_CONTINUE in
		0)
			printf "'Last Fragment in Frame'\n";
			printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FRAGMENTS_CONTINUE,1 0 \\\\\n";
		;;
		1)
			printf "'Fragments Continue'\n";
			printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_FRAGMENTS_CONTINUE,1 1 \\\\\n";
		;;
	esac
else
	printf "\\t#Preference for More Fragments/Last Fragment is not enforced.\n";
fi

if [ -n "$FRAG_OFFSET" ]; then
	printf "\\t#Match Fragment Offset (only $FRAG_OFFSET)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_FRAG_OFFSET,13 $FRAG_OFFSET \\\\\n";
fi

if [ -n "$FRAG_OFFSET_MIN" ] && [ -z "$FRAG_OFFSET_MAX" ]; then
	printf "\\t#Match Fragment Offset (minimum $FRAG_OFFSET_MIN)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_FRAG_OFFSET,13 >= $FRAG_OFFSET_MIN \\\\\n";
fi

if [ -z "$FRAG_OFFSET_MIN" ] && [ -n "$FRAG_OFFSET_MAX" ]; then
	printf "\\t#Match Fragment Offset (maximum $FRAG_OFFSET_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_FRAG_OFFSET,13 <= $FRAG_OFFSET_MAX \\\\\n";
fi

if [ -n "$FRAG_OFFSET_MIN" ] && [ -n "$FRAG_OFFSET_MAX" ]; then
	printf "\\t#Match Fragment Offset ($FRAG_OFFSET_MIN-$FRAG_OFFSET_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_FRAG_OFFSET,13 >= $FRAG_OFFSET_MIN \\\\\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_FRAG_OFFSET,13 <= $FRAG_OFFSET_MAX \\\\\n";
fi

if [ -z "$FRAG_OFFSET" ] && [ -z "$FRAG_OFFSET_MIN" ] && [ -z "$FRAG_OFFSET_MAX" ]; then
	printf "\\t#Fragment Offset is unrestricted\n";
fi

if [ -n "$TTL" ]; then
	printf "\\t#Confirm Time To Live (only $TTL)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_TTL,8 $TTL \\\\\n";
fi

if [ -n "$TTL_MIN" ] && [ -z "$TTL_MAX" ]; then
	printf "\\t#Confirm Time To Live (minimum $TTL_MIN)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_TTL,8 >= $TTL_MIN \\\\\n";
fi

if [ -z "$TTL_MIN" ] && [ -n "$TTL_MAX" ]; then
	printf "\\t#Confirm Time To Live (maximum $TTL_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_TTL,8 <= $TTL_MAX \\\\\n";
fi

if [ -n "$TTL_MIN" ] && [ -n "$TTL_MAX" ]; then
	printf "\\t#Confirm Time To Live ($TTL_MIN-$TTL_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_TTL,8 >= $TTL_MIN \\\\\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_TTL,8 <= $TTL_MAX \\\\\n";
fi

if [ -z "$TTL" ] && [ -z "$TTL_MIN" ] && [ -z "$TTL_MAX" ]; then
	printf "\\t#Time To Live is unrestricted\n";
fi

if [ -n "$LAYER_4_PROTOCOL_ID" ]; then
	printf "\\t#Confirm Layer 4 Protocol ID\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_LAYER_4_PROTOCOL_ID,8 $LAYER_4_PROTOCOL_ID \\\\\n";
else
	printf "\\t#Layer 4 Protocol ID is unrestricted - consider the security implications\n";
fi

if [ -n "$HEADER_CHECKSUM" ]; then
	printf "\\t#Confirm Header Checksum (only $HEADER_CHECKSUM)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_HEADER_CHECKSUM,16 $HEADER_CHECKSUM \\\\\n";
fi

if [ -n "$HEADER_CHECKSUM_MIN" ] && [ -z "$HEADER_CHECKSUM_MAX" ]; then
	printf "\\t#Match Header Checksum (minimum $HEADER_CHECKSUM_MIN)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_HEADER_CHECKSUM,16 >= $HEADER_CHECKSUM_MIN \\\\\n";
fi

if [ -z "$HEADER_CHECKSUM_MIN" ] && [ -n "$HEADER_CHECKSUM_MAX" ]; then
	printf "\\t#Match Header Checksum (maximum $HEADER_CHECKSUM_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_HEADER_CHECKSUM,16 <= $HEADER_CHECKSUM_MAX \\\\\n";
fi

if [ -n "$HEADER_CHECKSUM_MIN" ] && [ -n "$HEADER_CHECKSUM_MAX" ]; then
	printf "\\t#Match Header Checksum ($HEADER_CHECKSUM_MIN-$HEADER_CHECKSUM_MAX)\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_HEADER_CHECKSUM,16 >= $HEADER_CHECKSUM_MIN \\\\\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_HEADER_CHECKSUM,16 <= $HEADER_CHECKSUM_MAX \\\\\n";
fi

if [ -z "$HEADER_CHECKSUM" ] && [ -z "$HEADER_CHECKSUM_MIN" ] && [ -z "$HEADER_CHECKSUM_MAX" ]; then
	printf "\\t#Header Checksum is unrestricted\n";
fi

#Source Address / Network

if [ -n "$SOURCE_ADDRESS_IPV4_DECIMAL" ]; then
	printf "\\t#Confirm Source Host Address\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_SOURCE_HOST_ID,32 $SOURCE_ADDRESS_IPV4 \\\\\n";
fi

if [ -n "$SOURCE_BASE_ADDRESS_IPV4_DECIMAL" ] || [ -n "$SOURCE_END_ADDRESS_IPV4_DECIMAL" ]; then
	printf "\\t#Confirm Source Host Address is in range.\n";
fi

if [ -n "$SOURCE_BASE_ADDRESS_IPV4_DECIMAL" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_SOURCE_HOST_ID,32 >= $SOURCE_BASE_ADDRESS_IPV4_DECIMAL \\\\\n";
fi

if [ -n "$SOURCE_END_ADDRESS_IPV4_DECIMAL" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_SOURCE_HOST_ID,32 <= $SOURCE_END_ADDRESS_IPV4_DECIMAL \\\\\n";
fi

if [ -z "$SOURCE_ADDRESS_IPV4_DECIMAL" ] && [ -z "$SOURCE_BASE_ADDRESS_IPV4_DECIMAL" ] && [ -z "$SOURCE_END_ADDRESS_IPV4_DECIMAL" ]; then
	printf "\\t#Source Address is unrestricted - consider the security implications.\n";
fi

#Destination Address / Network

if [ -n "$DESTINATION_ADDRESS_IPV4_DECIMAL" ]; then
	printf "\\t#Confirm Destination Host Address\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_DESTINATION_HOST_ID,32 $DESTINATION_ADDRESS_IPV4_DECIMAL \\\\\n";
fi

if [ -n "$DESTINATION_BASE_ADDRESS_IPV4_DECIMAL" ] || [ -n "$DESTINATION_END_ADDRESS_IPV4_DECIMAL" ]; then
	printf "\\t#Confirm Destination Host Address is in range.\n";
fi

if [ -n "$DESTINATION_BASE_ADDRESS_IPV4_DECIMAL" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_DESTINATION_HOST_ID,32 >= $DESTINATION_BASE_ADDRESS_IPV4_DECIMAL \\\\\n";
fi

if [ -n "$DESTINATION_END_ADDRESS_IPV4_DECIMAL" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_DESTINATION_HOST_ID,32 <= $DESTINATION_END_ADDRESS_IPV4_DECIMAL \\\\\n";
fi

if [ -z "$DESTINATION_ADDRESS_IPV4_DECIMAL" ] && [ -z "$DESTINATION_BASE_ADDRESS_IPV4_DECIMAL" ] && [ -z "$DESTINATION_END_ADDRESS_IPV4_DECIMAL" ]; then
	printf "\\t#Destination Address is unrestricted - consider the security implications.\n";
fi

exit 0;
