#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_VALIDATE_ETHER_TYPE_ID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_layer_2_protocol_id_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_ETHER_TYPE_ID ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_ETHER_TYPE_ID\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_mac_address_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_PATH_VALIDATE_VLAN_ID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_vlan_id_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_VLAN_ID ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_VLAN_ID\" is missing or is not executable." 1>&2;
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
	printf "printf\n">&2;
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
	printf " Note: you must supply the \"parent\" tag to confirm a \"child tag\".\n">&2;
	printf " Note: for example, your packet is tagged with S-Tag 2 (54), S-Tag 1 (76), and C-Tag (865).\n">&2;
	printf " Note: to confirm presense of tag 76, you must also supply tag 54 in the list.\n">&2;
	printf "\n">&2;
	printf "\n">&2;
	printf " Optional: --vlan-id-dot1q x (where x is 0-4096).\n">&2;
	printf "  Note: commonly, this value will not be 0, nor 4096.\n">&2;
	printf "  Note: additionally, it is likely not the trunk port (according to your configuration.)\n">&2;
	printf "  Note: this is typically the parameter you are looking for when restricting to a \"VLAN\".\n">&2;
	printf "  Note: the Dot1Q ID indicates the \"inner layer\" VLAN in a multi-level segmented environment.\n">&2;
	printf "\n">&2;
	printf " Note: it is strongly recommended to supply the QinQ and Dot1Q VLAN ID's relevant to this signature if they are configured.\n">&2;
	printf "\n">&2;
	printf " Optional: --source-address-mac XX:XX:XX:XX:XX:XX (where X is 0-9, a-f, or A-F; hexadecimal).\n">&2;
	printf "  Note: it is strongly recommended to supply the source MAC address, if you know it.\n">&2;
	printf "\n">&2;
	printf " Optional: --destination-address-mac XX:XX:XX:XX:XX:XX (where X is 0-9, a-f, or A-F; hexadecimal).\n">&2;
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
SOURCE_ADDRESS_MAC="";
DESTINATION_ADDRESS_MAC="";

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

		--source-address-mac)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				SOURCE_ADDRESS_MAC=$2;
				shift 2;
			fi
		;;

		--destination-address-mac)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				DESTINATION_ADDRESS_MAC=$2;
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
	$SCRIPT_DEPENDENCY_PATH_VALIDATE_ETHER_TYPE_ID --id $ETHER_TYPE_ID;
	case $? in
		0) ;;
		1) printf "\nInvalid --ether-type-id. "; print_usage_then_exit; ;;
		*) printf "$0: dependency \"$SCRIPT_DEPENDENCY_PATH_VALIDATE_ETHER_TYPE_ID\" produced a failure exit code."; exit 4; ;;
	esac

	if [ -n "$VLAN_ID_QINQ" ]; then
		if [ -n "$(echo $VLAN_ID_QINQ | grep '[,]\+')" ]; then
			#More than one QinQ tag
			i=1;
			while true; do
				TAG=$(echo $VLAN_ID_QINQ | cut -d ',' -f $i);
				if [ -z "$TAG" ]; then break; fi

				$SCRIPT_DEPENDENCY_PATH_VALIDATE_VLAN_ID --id $TAG;
				case $? in
					0) ;;
					1) printf "\nInvalid --vlan-id-qinq (value #$i). "; print_usage_then_exit; ;;
					*) printf "$0: dependency \"$SCRIPT_DEPENDENCY_PATH_VALIDATE_VLAN_ID\" produced a failure exit code."; exit 4; ;;
				esac

				i=$(($i+1));
			done
		else
			#Just one QinQ tag
			$SCRIPT_DEPENDENCY_PATH_VALIDATE_VLAN_ID --id $VLAN_ID_QINQ;
			case $? in
				0) ;;
				1) printf "\nInvalid --vlan-id-qinq. "; print_usage_then_exit; ;;
				*) printf "$0: dependency \"$SCRIPT_DEPENDENCY_PATH_VALIDATE_VLAN_ID\" produced a failure exit code."; exit 4; ;;
			esac
		fi
	fi

	if [ -n "$VLAN_ID_DOT1Q" ]; then
		$SCRIPT_DEPENDENCY_PATH_VALIDATE_VLAN_ID --id $VLAN_ID_DOT1Q;
		case $? in
			0) ;;
			1) printf "\nInvalid --vlan-id-dot1q. "; print_usage_then_exit; ;;
			*) printf "$0: dependency \"$SCRIPT_DEPENDENCY_PATH_VALIDATE_VLAN_ID\" produced a failure exit code."; exit 4; ;;
		esac
	fi

	if [ -n "$SOURCE_ADDRESS" ]; then
		$SCRIPT_DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS --address $SOURCE_ADDRESS;
		case $? in
			0) ;;
			1) printf "\nInvalid --source-address-mac. "; print_usage_then_exit; ;;
			*) printf "$0: dependency \"$SCRIPT_DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS\" produced a failure exit code."; exit 4; ;;
		esac
	fi

	if [ -n "$DESTINATION_ADDRESS" ]; then
		$SCRIPT_DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS --address $DESTINATION_ADDRESS;
		case $? in
			0) ;;
			1) printf "\nInvalid --destination-address-mac. "; print_usage_then_exit; ;;
			*) printf "$0: dependency \"$SCRIPT_DEPENDENCY_PATH_VALIDATE_MAC_ADDRESS\" produced a failure exit code."; exit 4; ;;
		esac
	fi
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi


if [ -n "$VLAN_ID_QINQ" ]; then
	printf "\\t\\t#Confirm the presence and order of each QinQ VLAN tag.";

	if [ -n "$(echo $VLAN_ID_QINQ | grep '[,]\+')" ]; then
		#More than one QinQ tag

		#Remove every character except the delimeter
		#(match not comma, replace with nothing, globally)
		VLAN_ID_QINQ_DELIMITERS-$(echo $VLAN_ID_QINQ | sed 's/[^,]*//g');

		#The length of the list is the number of delimiters plus one.
		QINQ_TAG_COUNT=$((${#VLAN_ID_QINQ_DELIMITERS}+1));

		#Iterate and confirm each tag is present, and in the supplied order.
		i=1;
		#The tags begin after the destination and source MAC addresses: 96 bits offset.
		PACKET_POS=96;
		while true; do
			TAG=$(echo $VLAN_ID_QINQ | cut -d ',' -f $i);
			if [ -z "$TAG" ]; then break; fi

			#Confirm the S-Tag is the ethertype 88A8 (for 802.1AD).
			printf "\\t\\t@ll,$PACKET_POS,16 0x88A8 \\\\\n";
			#Confirm the S-Tag is what is required at this position.
			printf "\\t\\t@ll,$(($PACKET_POS+16)),16 $TAG \\\\\n";

			i=$(($i+1));
			PACKET_POS=$(($PACKET_POS+32));
		done;

		#now, confirm the Dot1Q tag, if present.
		if [ -n "$VLAN_ID_DOT1Q" ]; then
			#Confirm the C-Tag is the ethertype 8100 (for 802.1Q).
			printf "\\t\\t@ll,$PACKET_POS,16 0x8100 \\\\\n";
			#Confirm the S-Tag is what is required at this position.
			printf "\\t\\t@ll,$(($PACKET_POS+16)),16 $VLAN_ID_DOT1Q \\\\\n";
		fi
	else
		#Just one QinQ tag
		#QinQ tag begins after destination and source mac address (96 bits)

		#Confirm the S-Tag is the ethertype 88A8 (for 802.1AD).
		printf "\\t\\t@ll,96,16 0x88A8 \\\\\n";
		#Confirm the S-Tag is what is required at this position.
		printf "\\t\\t@ll,112,16 $VLAN_ID_QINQ \\\\\n";

		if [ -n "$VLAN_ID_DOT1Q" ]; then
			#Confirm the C-Tag is the ethertype 8100 (for 802.1Q).
			printf "\\t\\t@ll,128,16 0x8100 \\\\\n";
			#Confirm the C-Tag is what is required at this position.
			printf "\\t\\t@ll,144,16 $VLAN_ID_DOT1Q \\\\\n";
		fi
	fi
fi

if [ -n "$VLAN_ID_DOT1Q" ]; then
	printf "\\t\\t#Confirm the presence and type of the VLAN tag."
	printf "\\t\\tvlan id $VLAN_ID_DOT1Q\n";
	printf "\\t\\tvlan type 0x8100 \\\\\n";
fi

if [ -n "$ETHER_TYPE_ID" ]; then
	printf "\\t\\t#Confirm the ether type\n"
	printf "\\t\\tether type $ETHER_TYPE_ID \\\\\n";
fi

printf "\\t\\t#Confirm the source MAC address.\n";
if [ -n "$SOURCE_ADDRESS" ]; then
	printf "\\t\\tether saddr $SOURCE_ADDRESS \\\\\n";
else
	printf "\\t\\t#ether saddr ANY - Please consider the security implications.\n";
fi

printf "\\t\\t#Confirm the destination MAC address.\n";
if [ -n "$DESTINATION_ADDRESS" ]; then
	printf "\\t\\tether daddr $DESTINATION_ADDRESS \\\\\n";
else
	printf "\\t\\t#ether daddr ANY - Please consider the security implications.\n";
fi

exit 0;
