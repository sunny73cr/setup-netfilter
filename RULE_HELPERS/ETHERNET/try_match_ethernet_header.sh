#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_VALIDATE_ETHER_TYPE_ID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_layer_2_protocol_id_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_ETHER_TYPE_ID ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_ETHER_TYPE_ID\" is missing or is not executable.">&2;
	exit 3;
fi

DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS\" is missing or is not executable.">&2;
	exit 3;
fi

DEPENDENCY_PATH_VALIDATE_VLAN_ID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_vlan_id_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_VLAN_ID ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_VLAN_ID\" is missing or is not executable.">&2;
	exit 2;
fi

print_description() {
	printf "A program that prints part of an NFT rule 'match' section. The match intends to identify the \"Ethernet\" (Layer 2) portion of packets.\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "Dependencies: \n">&2;
	printf "printf\n">&2;
	printf "$DEPENDENCY_PATH_VALIDATE_ETHER_TYPE_ID\n">&2;
	printf "$DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS\n">&2;
	printf "$DEPENDENCY_PATH_VALIDATE_VLAN_ID\n">&2;
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
	printf " Optional: --ether-type-id x (where X is a valid 'ether type'. Typically 0x0800 for IPV4, 0x86DD for IPV6, or 0x0806 for ARP)\n">&2;
	printf "  Note: it is strongly recommended to provide this parameter.\n">&2;
	printf "\n">&2;
	printf " Optional: --vlan-id-qinq x (where x is 0-4096).\n">&2;
	printf "  Note: commonly, this value will not be 0, nor 4096.\n">&2;
	printf "  Note: additionally, it is likely not the trunk port (according to your configuration).\n">&2;
	printf "  Note: this parameter is usually not applicable to home or small business networks.\n">&2;
	printf "  Note: the QinQ ID indicates the \"upper layer\" VLAN in a multi-level segmented environment.\n">&2;
	printf "\n">&2;
	printf " Note: you may supply a list of VLAN QinQ ID's (up to a limit of 4)\n">&2;
	printf " Note: to do so, the value of --vlan-id-qinq should be a comma separated list of values. Do not terminate the list with a comma.\n">&2;
	printf " Note: the list should be supplied in 'outermost to innermost tag' order.\n">&2;
	printf " Note: for example, your packet is tagged with S-Tag 2 (54), S-Tag 1 (76), and C-Tag (865).\n">&2;
	printf " Note: to confirm presense of tag 76, you must also supply tag 54 in the list.\n">&2;
	printf "\n">&2;
	printf " Optional: --vlan-id-dot1q x (where x is 0-4096).\n">&2;
	printf "  Note: commonly, this value will not be 0, nor 4096.\n">&2;
	printf "  Note: additionally, it is likely not the trunk port (according to your configuration.)\n">&2;
	printf "  Note: this is typically the parameter you are looking for when restricting to a \"VLAN\".\n">&2;
	printf "  Note: the Dot1Q ID indicates the \"inner layer\" VLAN in a multi-level segmented environment.\n">&2;
	printf "\n">&2;
	printf " Note: it is required to supply the QinQ and Dot1Q VLAN ID's relevant to this signature if they are configured within the network.\n">&2;
	printf "\n">&2;
	printf " Optional: --source-mac-address XX:XX:XX:XX:XX:XX (where X is 0-9, a-f, or A-F; hexadecimal).\n">&2;
	printf "  Note: it is strongly recommended to supply the source MAC address, if you know it.\n">&2;
	printf "\n">&2;
	printf " Optional: --destination-mac-address XX:XX:XX:XX:XX:XX (where X is 0-9, a-f, or A-F; hexadecimal).\n">&2;
	printf "  Note: it is strongly recommended to supply the destination MAC address, if you know it.\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf "  Note: enabling this flag causes the program to skip validation (if you know the inputs are valid).\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validate\n">&2;
	printf "  Note: enabling this flag causes the program to exit after validating inputs.\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
ETHER_TYPE_ID="";
VLAN_ID_QINQ="";
VLAN_ID_DOT1Q="";
SOURCE_MAC_ADDRESS="";
DESTINATION_MAC_ADDRESS="";

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

		--ether-type-id)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				ETHER_TYPE_ID=$2;
				shift 2;
			fi
		;;

		--vlan-id-qinq)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				VLAN_ID_QINQ=$2;
				shift 2;
			fi
		;;

		--vlan-id-dot1q)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				VLAN_ID_DOT1Q=$2;
				shift 2;
			fi
		;;

		--source-mac-address)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				SOURCE_MAC_ADDRESS=$2;
				shift 2;
			fi
		;;

		--destination-mac-address)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				DESTINATION_MAC_ADDRESS=$2;
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
	$DEPENDENCY_PATH_VALIDATE_ETHER_TYPE_ID --id $ETHER_TYPE_ID;
	case $? in
		0) ;;
		1) printf "\nInvalid --ether-type-id. "; print_usage_then_exit; ;;
		*) printf "$0: dependency \"$DEPENDENCY_PATH_VALIDATE_ETHER_TYPE_ID\" produced a failure exit code ($?)."; exit 4; ;;
	esac

	if [ -n "$VLAN_ID_QINQ" ] && [ -z "$VLAN_ID_DOT1Q" ]; then
		printf "\nIf --vlan-id-qinq is present, --vlan-id-dot1q must be present. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$VLAN_ID_QINQ" ]; then
		#If VLAN_ID_QINQ matches the form (vlan,){1,3}vlan, it is a csv of vlans.
		if [ -n "$(echo $VLAN_ID_QINQ | grep '^\([0-9]\{1,4\},\)\{1,3\}[0-9]\{1,4\}$')" ]; then
			#More than one QinQ tag
			i=1;
			while true; do
				TAG=$(echo $VLAN_ID_QINQ | cut -d ',' -f $i);
				if [ -z "$TAG" ]; then break; fi

				$DEPENDENCY_PATH_VALIDATE_VLAN_ID --id $TAG;
				case $? in
					0) ;;
					1) printf "\nInvalid --vlan-id-qinq (value \#$i). ">&2; print_usage_then_exit; ;;
					*) printf "$0: dependency \"$DEPENDENCY_PATH_VALIDATE_VLAN_ID\" produced a failure exit code ($?)."; exit 4; ;;
				esac

				i=$(($i+1));
			done
		else
			if [ -n "$(echo $VLAN_ID_QINQ | grep ',')" ]; then
			#contains a comma
				printf "\nInvalid --vlan-id-qinq (bad CSV). ">&2;
				print_usage_then_exit;
			else
			#Just one QinQ tag
				$DEPENDENCY_PATH_VALIDATE_VLAN_ID --id $VLAN_ID_QINQ;
				case $? in
					0) ;;
					1) printf "\nInvalid --vlan-id-qinq. ">&2; print_usage_then_exit; ;;
					*) printf "$0: dependency \"$DEPENDENCY_PATH_VALIDATE_VLAN_ID\" produced a failure exit code ($?)."; exit 4; ;;
				esac
			fi
		fi
	fi

	if [ -n "$VLAN_ID_DOT1Q" ]; then
		$DEPENDENCY_PATH_VALIDATE_VLAN_ID --id $VLAN_ID_DOT1Q;
		case $? in
			0) ;;
			1) printf "\nInvalid --vlan-id-dot1q. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency \"$DEPENDENCY_PATH_VALIDATE_VLAN_ID\" produced a failure exit code ($?)."; exit 4; ;;
		esac
	fi

	if [ -n "$SOURCE_MAC_ADDRESS" ]; then
		$DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS --address $SOURCE_MAC_ADDRESS;
		case $? in
			0) ;;
			1) printf "\nInvalid --source-mac-address. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency \"$DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS\" produced a failure exit code ($?)."; exit 4; ;;
		esac
	fi

	if [ -n "$DESTINATION_MAC_ADDRESS" ]; then
		$DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS --address $DESTINATION_MAC_ADDRESS;
		case $? in
			0) ;;
			1) printf "\nInvalid --destination-mac-address. ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency \"$DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS\" produced a failure exit code ($?)."; exit 4; ;;
		esac
	fi
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

#If Service VLANS present, count them.
QINQ_TAG_COUNT=0;
if [ -n "$VLAN_ID_QINQ" ] && [ -n "$(echo $VLAN_ID_QINQ | grep '^\([0-9]\{1,4\},\)\{1,3\}[0-9]\{1,4\}$')" ]; then
	#Remove every character except the delimeter
	#(match not comma, replace with nothing, globally)
	VLAN_ID_QINQ_DELIMITERS=$(echo $VLAN_ID_QINQ | sed 's/[^,]\{1,3\}//g');

	#The length of the list is the number of delimiters plus one.
	QINQ_TAG_COUNT=$((${#VLAN_ID_QINQ_DELIMITERS}+1));
fi

OFFSET_MARKER="ll";
BIT_OFFSET_HEADER_BEGIN=0;
BIT_OFFSET_DESTINATION_MAC=$BIT_OFFSET_HEADER_BEGIN;
BIT_OFFSET_SOURCE_MAC=$(($BIT_OFFSET_DESTINATION_MAC+48));
BIT_OFFSET_VLAN_QINQ_1=-1;
BIT_OFFSET_VLAN_QINQ_2=-1;
BIT_OFFSET_VLAN_QINQ_3=-1;
BIT_OFFSET_VLAN_QINQ_4=-1;

if [ $QINQ_TAG_COUNT -gt 0 ]; then
	VLAN_QINQ_1=$(echo $VLAN_ID_QINQ | cut -d ',' -f 1);
	VLAN_QINQ_2=$(echo $VLAN_ID_QINQ | cut -d ',' -f 2);
	VLAN_QINQ_3=$(echo $VLAN_ID_QINQ | cut -d ',' -f 3);
	VLAN_QINQ_4=$(echo $VLAN_ID_QINQ | cut -d ',' -f 4);
fi

case $QINQ_TAG_COUNT in
	0)
		if [ -n "$VLAN_ID_DOT1Q" ]; then
			BIT_OFFSET_VLAN_8021Q=$(($BIT_OFFSET_SOURCE_MAC+48));
			BIT_OFFSET_ETHERTYPE=$(($BIT_OFFSET_VLAN_8021Q+32));
			BIT_OFFSET_PAYLOAD=$(($BIT_OFFSET_ETHERTYPE+16));
		else
			BIT_OFFSET_ETHERTYPE=$(($BIT_OFFSET_SOURCE_MAC+48));
			BIT_OFFSET_PAYLOAD=$(($BIT_OFFSET_ETHERTYPE+16));
		fi
	;;
	1)
		BIT_OFFSET_VLAN_QINQ_1=$(($BIT_OFFSET_SOURCE_MAC+48));
		if [ -n "$VLAN_ID_DOT1Q" ]; then
			BIT_OFFSET_VLAN_8021Q=$(($BIT_OFFSET_VLAN_QINQ_1+32));
			BIT_OFFSET_ETHERTYPE=$(($BIT_OFFSET_VLAN_8021Q+32));
			BIT_OFFSET_PAYLOAD=$(($BIT_OFFSET_ETHERTYPE+16));
		fi
	;;
	2)
		BIT_OFFSET_VLAN_QINQ_1=$(($BIT_OFFSET_SOURCE_MAC+48));
		BIT_OFFSET_VLAN_QINQ_2=$(($BIT_OFFSET_VLAN_QINQ_1+32));
		if [ -n "$VLAN_ID_DOT1Q" ]; then
			BIT_OFFSET_VLAN_8021Q=$(($BIT_OFFSET_VLAN_QINQ_2+32));
			BIT_OFFSET_ETHERTYPE=$(($BIT_OFFSET_VLAN_8021Q+32));
			BIT_OFFSET_PAYLOAD=$(($BIT_OFFSET_ETHERTYPE+16));
		fi
	;;
	3)
		BIT_OFFSET_VLAN_QINQ_1=$(($BIT_OFFSET_SOURCE_MAC+48));
		BIT_OFFSET_VLAN_QINQ_2=$(($BIT_OFFSET_VLAN_QINQ_1+32));
		BIT_OFFSET_VLAN_QINQ_3=$(($BIT_OFFSET_VLAN_QINQ_2+32));
		if [ -n "$VLAN_ID_DOT1Q" ]; then
			BIT_OFFSET_VLAN_8021Q=$(($BIT_OFFSET_VLAN_QINQ_3+32));
			BIT_OFFSET_ETHERTYPE=$(($BIT_OFFSET_VLAN_8021Q+32));
			BIT_OFFSET_PAYLOAD=$(($BIT_OFFSET_ETHERTYPE+16));
		fi
	;;
	4)
		BIT_OFFSET_VLAN_QINQ_1=$(($BIT_OFFSET_SOURCE_MAC+48));
		BIT_OFFSET_VLAN_QINQ_2=$(($BIT_OFFSET_VLAN_QINQ_1+32));
		BIT_OFFSET_VLAN_QINQ_3=$(($BIT_OFFSET_VLAN_QINQ_2+32));
		BIT_OFFSET_VLAN_QINQ_4=$(($BIT_OFFSET_VLAN_QINQ_3+32));
		if [ -n "$VLAN_ID_DOT1Q" ]; then
			BIT_OFFSET_VLAN_8021Q=$(($BIT_OFFSET_VLAN_QINQ_4+32));
			BIT_OFFSET_ETHERTYPE=$(($BIT_OFFSET_VLAN_8021Q+32));
			BIT_OFFSET_PAYLOAD=$(($BIT_OFFSET_ETHERTYPE+16));
		fi
	;;
esac

if [ -n "$DESTINATION_MAC_ADDRESS" ]; then
	#nft expects a hexadecimal number, prefix with 0x and strip colons
	DESTINATION_MAC_CLEANED="0x$(echo $DESTINATION_MAC_ADDRESS | sed 's/://g')";
	printf "\\t#Match Destination MAC address\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_DESTINATION_MAC,48 $DESTINATION_MAC_CLEANED \\\\\n";
else
	printf "\\t#Destination MAC Address unrestricted - Please consider the security implications.\n";
fi

if [ -n "$SOURCE_MAC_ADDRESS" ]; then
	#nft expects a hexadecimal number, prefix with 0x and strip colons
	SOURCE_MAC_CLEANED="0x$(echo $SOURCE_MAC_ADDRESS | sed 's/://g')";
	printf "\\t#Match Source MAC address\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_SOURCE_MAC,48 $SOURCE_MAC_CLEANED \\\\\n";
else
	printf "\\t#Source MAC Address unrestricted - Please consider the security implications.\n";
fi

if [ $QINQ_TAG_COUNT -gt 0 ]; then
	printf "\\t#Match QINQ VLAN Tags\n";
fi
case $QINQ_TAG_COUNT in
	1)
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_VLAN_QINQ_1,32 $VLAN_QINQ_1 \\\\\n";
	;;
	2)
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_VLAN_QINQ_1,32 $VLAN_QINQ_1 \\\\\n";
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_VLAN_QINQ_2,32 $VLAN_QINQ_2 \\\\\n";
	;;
	3)
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_VLAN_QINQ_1,32 $VLAN_QINQ_1 \\\\\n";
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_VLAN_QINQ_2,32 $VLAN_QINQ_2 \\\\\n";
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_VLAN_QINQ_3,32 $VLAN_QINQ_3 \\\\\n";
	;;
	4)
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_VLAN_QINQ_1,32 $VLAN_QINQ_1 \\\\\n";
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_VLAN_QINQ_2,32 $VLAN_QINQ_2 \\\\\n";
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_VLAN_QINQ_3,32 $VLAN_QINQ_3 \\\\\n";
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_VLAN_QINQ_4,32 $VLAN_QINQ_4 \\\\\n";
	;;
esac

if [ -n "$VLAN_ID_DOT1Q" ]; then
	printf "\\t#Match VLAN ID DOT1Q\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_VLAN_8021Q,32 $VLAN_ID_DOT1Q \\\\\n";
fi

if [ -n "$ETHER_TYPE_ID" ]; then
	printf "\\t#Match Ether Type\n"
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ETHERTYPE,16 $ETHER_TYPE_ID \\\\\n";
else
	printf "\\t#Ether Type is unrestricted - consider the security implications.\n";
fi

exit 0;
