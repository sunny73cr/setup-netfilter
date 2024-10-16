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
	printf "A program that prints part of an NFT rule 'match' section. The match intends to identify IPV4 headers.\n">&2;
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
	printf " Optional: --offset-marker nh|ih\n">&2;
	printf "  Note: here, nh means network header (or the usual place for the IPV4 header).\n">&2;
	printf "  Note: this is most commonly what you are looking to match, unless the IPV4 header\n">&2;
	printf "  Note: is part of the content in an encapsulating protocol (see ICMP Destination Host Unreachable).\n">&2;
	printf "  Note: for these encapsulating protocols, the offset marker should be ih; with the predefined \"offset-header-begin\"\n">&2;
	printf "  Note: supplied in the --offset-header-begin parameter.\n">&2;
	printf "\n">&2;
	printf " Optional: --offset-header-begin X (where X is a number from 0-65536)\n">&2;
	printf "  Note: this indicates to the program where the beginning of the IPV4 header is.\n">&2;
	printf "  Note: this is important for encapsulating protocols like an ICMP Destination Host Unreachable packet;\n">&2;
	printf "  Note: otherwise, the header simply will not match.\n">&2;
	printf "\n">&2;
	printf " Note: where the --offset-marker is not provided, the default is \"nh\" (the standard place to match an IPV4 header).\n">&2;
	printf " Note: if --offset-header-begin is not provided, it will default to 0. If --offset-marker is \"ih\", it will potentially fail to match.\n">&2;
	printf "\n">&2;
	printf " Optional: --layer-4-protocol-id X (where X is a valid and assigned protocol number, according to IANA specifications)\n">&2;
	printf "  Note: examples are: 1 - ICMP, 2 - IGMP, 6 - TCP, 17 - UDP... etc\n">&2;
	printf "\n">&2;
	printf " Optional: --source-address-ipv4 X.X.X.X (where X is 0-255).\n">&2;
	printf "\n">&2;
	printf " Optional: --source-network-ipv4 X.X.X.X/Y (where X is 0-255, and Y is 1-32).\n">&2;
	printf "\n">&2;
	printf " Optional: --destination-address-ipv4 X.X.X.X (where X is 0-255).\n">&2;
	printf "\n">&2;
	printf " Optional: --destination-network-ipv4 X.X.X.X/Y (where X is 0-255, and Y is 1-32).\n">&2;
	printf "\n">&2;
	printf " Note: it is strongly recommended to supply an address, or a network; but you cannot supply both.\n">&2;
	printf " Note: it is strongly recommended to supply both a source and destination address or network.\n">&2;
	printf " Note: it is strongly recommended to provide networks, compared to multiple invocations using singular addresses.\n">&2;
	printf " Note: this way, it is much faster to generate the rule, and is also faster for NFT to match the packet.\n">&2;
	printf "\n">&2;
	printf " Optional: --diff-serv-code x (where X is a number) \n">&2;
	printf "  Note: confirm that the differentiated services code point is one listed in IANA's registry.\n">&2;
	printf "\n">&2;
	printf " Optional: --congestion-notification not-ect|ect|ce \n">&2;
	printf "  Note: confirm if the session is or isnt ect capable, or whether congestion is ocurring.\n">&2;
	printf "\n">&2;
	printf " Optional: --length x (where x is 0-65535)\n">&2;
	printf "  Note: confirm if the packet is an exact length.\n">&2;
	printf "\n">&2;
	printf " Optional: --min-length x (where x is -065535).\n">&2;
	printf "\n">&2;
	printf " Optional: --max-length x (where x is 0-65535).\n">&2;
	printf "\n">&2;
	printf " Note: min length must not be greater than or equal to max length.\n">&2;
	printf " Note: you may not combine min or max length with an exact length.\n">&2;
	printf " Note: you are not required to supply both a min and max length.\n">&2;
	printf "\n">&2;
	printf " Optional: --identification\n">&2;
	printf "  Note: confirm if the ID field is an exact number.\n">&2;
	printf "  Note: The number should be unique, so no checks based on range can be performed.\n">&2;
	printf "\n">&2;
	printf " Optional: --flags not-ect|ect|ce\n">&2;
	printf "  Note: confirm if the flags field indicates one of:\n">&2;
	printf "  Note:  1. not-ect-capable transport / no ability to handle ECT bits.\n">&2;
	printf "  Note:  2. ect-capable transport / ability to indicate, identify, and react according to link congestion\n">&2;
	printf "  Note:  3. ect-capable transport, and congestion is actively experienced. Routers may be throttling links.\n">&2;
	printf "\n">&2;
	printf " Optional: --frag-offset x (where x is 0-8192)\n">&2;
	printf "  Note: confirm if the packet offset is an exact number.\n">&2;
	printf "\n">&2;
	printf " Optional: --min-frag-offset x (where x is 0-8912)\n">&2;
	printf "\n">&2;
	printf " Optional: --max-frag-offset x (where x is 0-8192)\n">&2;
	printf "\n">&2;
	printf " Note: min frag offset must be greater than or equal to max frag offset.\n">&2;
	printf " Note: you may not combine min or max frag offset with an exact offset restriction.\n">&2;
	printf " Note: you are not required to supply both a min and max frag offset.\n">&2;
	printf "\n">&2;
	printf " Optional: --ttl x (where x is 1-255)\n">&2;
	printf "  Note: restrict the number of routers the packet may traverse.\n">&2;
	printf "\n">&2;
	printf " Optional: --header-checksum x (where x is 0-65535)\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf "  Note: enabling this flag causes the program to skip validating inputs (if you know they are valid already).\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validation\n">&2;
	printf "  Note: enabling this flag causes the program to exit after performing validation.\n">&2;
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
DIFF_SERV_CODE="";
CONGESTION_NOTIFICATION="";
LENGTH="";
LENGTH_MIN="";
LENGTH_MAX="";
IDENTIFICATION="";
FLAGS="";
FRAG_OFFSET="";
FRAG_OFFSET_MIN="";
FRAG_OFFSET_MAX="";
TTL="";
HEADER_CHECKSUM="";

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

		--min-length)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				LENGTH_MIN=$2;
				shift 2;
			fi
		;;

		--max-length)
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

		--flags)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				FLAGS=$2;
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

		--min-frag-offset)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				FRAG_OFFSET_MIN=$2;
				shift 2;
			fi
		;;

		--max-frag-offset)
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
		printf "\nInvalid --source-address-ipv4 and --source-network-ipv4 (you cannot supply both).\n">&2;
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
		printf "\nInvalid --destination-address-ipv4 and --destination-network-ipv4 (you cannot supply both).\n">&2;
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
		$DEPENDENCY_PATH_VALIDATE_DIFF_SERV_CODE --code $DIFF_SERV_CODE;
		case $? in
			0) ;;
			1) printf "\nInvalid --diff-serv-code. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency \"$DEPENDENCY_PATH_VALIDATE_DIFF_SERV_CODE\" produced a failure exit code.">&2; exit 3; ;;
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
		printf "\nInvalid --length, --min-length. You cannot combine these arguments.\n">&2;
		print_usage_then_exit;
	fi

	if [ -n "$LENGTH" ] && [ -n "$LENGTH_MAX" ]; then
		printf "\nInvalid --length, --max-length. You cannot combine these arguments.\n">&2;
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

		if [ $LENGTH -gt 65536 ]; then
			printf "\nInvalid --length (must be less than or equal to 65,536). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$LENGTH_MIN" ]; then
		if [ -z "$(echo $LENGTH_MIN | grep '[-]\{0,1\}[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --min-length (must be a 1-5 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH -lt 0 ]; then
			printf "\nInvalid --min-length (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH -gt 65536 ]; then
			printf "\nInvalid --min-length (must be less than or equal to 65,536). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$LENGTH_MAX" ]; then
		if [ -z "$(echo $LENGTH_MAX | grep '[-]\{0,1\}[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --max-length (must be a 1-5 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH -lt 0 ]; then
			printf "\nInvalid --max-length (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $LENGTH -gt 65536 ]; then
			printf "\nInvalid --max-length (must be less than or equal to 65,536). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$LENGTH_MIN" ] && [ -n "$LENGTH_MAX" ] && [ "$LENGTH_MIN" -ge "$LENGTH_MAX" ]; then
		printf "\nInvalid --min-length or --max-length (min length cannot be greater than or equal to max length.) ">&2;
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

		if [ $IDENTIFICATION -gt 65536 ]; then
			printf "\nInvalid --identification (must be less than or equal to 65,536). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$FLAGS" ]; then
		case $FLAGS in
			dont-fragment) ;;
			more-fragments) ;;
			*) printf "\nInvalid --flags. ">&2; print_usage_then_exit; ;;
		esac
	fi

	if [ -n "$FRAG_OFFSET" ] && [ -n "$FRAG_OFFSET_MIN" ]; then
		printf "\nInvalid --frag-offset, --min-frag-offset. You cannot combine these arguments.\n">&2;
		print_usage_then_exit;
	fi

	if [ -n "$FRAG_OFFSET" ] && [ -n "$FRAG_OFFSET_MAX" ]; then
		printf "\nInvalid --frag-offset, --max-frag-offset. You cannot combine these arguments.\n">&2;
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

		if [ $FRAG_OFFSET -gt 8192 ]; then
			printf "\nInvalid --frag-offset (must be less than or equal to 8192). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$FRAG_OFFSET_MIN" ] && [ -n "$FRAG_OFFSET_MAX" ] && [ "$FRAG_OFFSET_MIN" -ge "$FRAG_OFFSET_MAX" ]; then
		printf "\nInvalid --min-frag-offset or --max-frag-offset (min frag offset cannot be greater than or equal to max frag offset.) ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$TTL" ]; then
		if [ -z "$(echo $TTL | grep '[-]\{0,1\}[0-9]\{1,3\}')" ]; then
			printf "\nInvalid --frag-offset (must be a 1-3 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $TTL -lt 0 ]; then
			printf "\nInvalid --ttl (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $TTL -gt 255 ]; then
			printf "\nInvalid --ttl (must be less than or equal to 255). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$HEADER_CHECKSUM" ]; then
		if [ -z "$(echo $HEADER_CHECKSUM | grep '[-]\{0,1\}[0-9]\{1,5\}')" ]; then
			printf "\nInvalid --frag-offset (must be a 1-5 digit integer). ">&2;
			print_usage_then_exit;
		fi

		if [ $HEADER_CHECKSUM -lt 0 ]; then
			printf "\nInvalid --header-checksum (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $HEADER_CHECKSUM -gt 65536 ]; then
			printf "\nInvalid --header-checksum (must be less than or equal to 65536). ">&2;
			print_usage_then_exit;
		fi
	fi
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

OFFSET_VERSION=$OFFSET_HEADER_BEGIN;
OFFSET_IHL=$(($OFFSET_BEGIN+4));
OFFSET_DIFF_SERV_CODE=$(($OFFSET_IHL+4));
OFFSET_CONGESTION_NOTIFICATION=$(($OFFSET_DIFF_SERV_CODE+6));
OFFSET_LENGTH=$(($OFFSET_CONGESTION_NOTIFICATION+2));
OFFSET_IDENTIFICATION=$(($OFFSET_LENGTH+16));
OFFSET_FLAGS=$(($OFFSET_IDENTIFICATION+16));
OFFSET_FRAG_OFFSET=$(($OFFSET_FLAGS+3));
OFFSET_TTL=$(($OFFSET_FRAG_OFFSET+13));
OFFSET_LAYER_4_PROTOCOL_ID=$(($OFFSET_TTL+8));
OFFSET_HEADER_CHECKSUM=$(($OFFSET_LAYER_4_PROTOCOL_ID+8));
OFFSET_SOURCE_HOST_ID=$(($OFFSET_HEADER_CHECKSUM+16));
OFFSET_DESTINATION_HOST_ID=$(($OFFSET_SOURCE_HOST_ID+32));
OFFSET_OPTIONS=$(($OFFSET_DESTINATION_HOST_ID+32));

printf "\\t\\t#Confirm VERSION is 4\n";
printf "\\t\\t@$OFFSET_MARKER,$OFFSET_VERSION,4 4 \\\\\n";

printf "\\t\\t#Confirm IHL is 5 (32-bit words) in length / no \"options\" are present.\n";
printf "\\t\\t@$OFFSET_MARKER,$OFFSET_IHL,4 5 \\\\\n";

if [ -n "$DIFF_SERV_CODE" ]; then
	printf "\\t\\t#Confirm DSCP value\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_DIFF_SERV_CODE,6 $DIFF_SERV_CODE \\\\\n";
else
	printf "\\t\\t#Differentiated Services Code Point is unrestricted\n";
fi

if [ -n "$CONGESTION_NOTIFICATION" ]; then
	printf "\\t\\t#Confirm Congestion Notification\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_CONGESTION_NOTIFICATION,2 $CONGESTION_NOTIFICATION \\\\\n";
else
	printf "\\t\\t#Congestion Notification (ECN-Capable / Congestion Experience bits) are unrestricted\n";
fi

if [ -n "$LENGTH" ] || [ -n "$LENGTH_MIN" ] || [ -n "$LENGTH_MAX" ]; then
	printf "\\t\\t#Confirm Length\n";
fi
if [ -n "$LENGTH" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_LENGTH,16 $LENGTH \\\\\n";
fi
if [ -n "$LENGTH_MIN" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_LENGTH,16 >= $LENGTH \\\\\n";
fi
if [ -n "$LENGTH_MAX" ]; then
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_LENGTH,16 <= $LENGTH \\\\\n";
fi
if [ -z "$LENGTH" ] && [ -z "$LENGTH_MIN" ] && [ -z "$LENGTH_MAX" ]; then
	printf "\\t\\t#Length is unrestricted - consider the security implications\n";
fi

if [ -n "$IDENTIFICATION" ]; then
	printf "\\t\\t#Confirm Identification\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_IDENTIFICATION,16 $IDENTIFICATION \\\\\n";
else
	printf "\\t\\t#Identification is unrestricted\n";
fi

if [ -n "$FLAGS" ]; then
	printf "\\t\\t#Confirm Flags\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_FLAGS,3 $FLAGS \\\\\n";
else
	printf "\\t\\t#Dont/More Fragments Flags are unrestricted\n";
fi

if [ -n "$FRAG_OFFSET" ]; then
	printf "\\t\\t#Confirm Fragment Offset\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_FRAG_OFFSET,13 $FRAG_OFFSET \\\\\n";
else
	printf "\\t\\t#Fragment Offset is unrestricted\n";
fi

if [ -n "$TTL" ]; then
	printf "\\t\\t#Confirm Time To Live\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_TTL,8 $TTL \\\\\n";
else
	printf "\\t\\t#Time To Live is unrestricted\n";
fi

if [ -n "$LAYER_4_PROTOCOL_ID" ]; then
	printf "\\t\\t#Confirm Layer 4 Protocol ID\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_LAYER_4_PROTOCOL_ID,8 $LAYER_4_PROTOCOL_ID \\\\\n";
else
	printf "\\t\\t#Layer 4 Protocol ID is unrestricted - consider the security implications\n";
fi

if [ -n "$HEADER_CHECKSUM" ]; then
	printf "\\t\\t#Confirm Header Checksum\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_HEADER_CHECKSUM,16 $HEADER_CHECKSUM \\\\\n";
else
	printf "\\t\\t#Header Checksum is unrestricted\n";
fi

if [ -n "$SOURCE_ADDRESS_IPV4" ]; then
	printf "\\t\\t#Confirm Source Host Address\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_SOURCE_HOST_ID,32 $SOURCE_ADDRESS_IPV4 \\\\\n";
fi

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

	printf "\\t\\t#Confirm Source Host Address is in range.\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_SOURCE_HOST_ID,32 >= $SOURCE_BASE_ADDRESS_IPV4_DECIMAL \\\\\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_SOURCE_HOST_ID,32 <= $SOURCE_END_ADDRESS_IPV4_DECIMAL \\\\\n";
fi

if [ -z "$SOURCE_ADDRESS_IPV4" ] && [ -z "$SOURCE_NETWORK_IPV4" ]; then
	printf "\\t\\t#Source Address is unrestricted - consider the security implications.\n";
fi

if [ -n "$DESTINATION_ADDRESS_IPV4" ]; then
	printf "\\t\\t#Confirm Source Host Address\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_DESTINATION_HOST_ID,32 $DESTINATION_ADDRESS_IPV4 \\\\\n";
fi

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

	printf "\\t\\t#Confirm Destination Host Address is in range.\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_DESTINATION_HOST_ID,32 >= $DESTINATION_BASE_ADDRESS_IPV4_DECIMAL \\\\\n";
	printf "\\t\\t@$OFFSET_MARKER,$OFFSET_DESTINATION_HOST_ID,32 <= $DESTINATION_END_ADDRESS_IPV4_DECIMAL \\\\\n";
fi

if [ -z "$DESTINATION_ADDRESS_IPV4" ] && [ -z "$DESTINATION_NETWORK_IPV4" ]; then
	printf "\\t\\t#Destination Address is unrestricted - consider the security implications.\n";
fi

exit 0;
