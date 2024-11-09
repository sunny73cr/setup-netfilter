#!/bin/sh

#Source: https://www.iana.org/assignments/ieee-802-numbers/ieee-802.numbers.xhtml
#Source: https://standards-oui.ieee.org/ethertype/eth.csv
#TODO: Add all ethertypes to the switch case

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

print_description() {
	printf "A program that validates a provided layer 2 protocol ID (in hexadecimal format).\n">&2;
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
	printf "Flags used by themselves: \n">&2;
	printf " -e (prints an explanation of the functions' purpose) (exit code 2)\n">&2
	printf " -h (prints an explanation of the functions' available parameters, and their effect) (exit code 2)\n">&2;
	printf " -d (prints the functions' dependencies: newline delimited list) (exit code 2)\n">&2;
	printf " -ehd (prints the above three) (exit code 2)\n">&2;
	printf "\n">&2;
	printf "Parameters:\n">&2;
	printf "\n">&2;
	printf " Required: --id X (where X is a 2-byte (16-bit) hexadecimal string)\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf "  Presence of this flag causes the program to skip validating inputs (if you know they are valid).\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validate\n">&2;
	printf "  Presence of this flag causes the program to exit after validating inputs.\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
ID="";

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

		--id)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				ID=$2;
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

if [ $SKIP_VALIDATION -eq 0 ]; then
	if [ -z "$ID" ]; then
		printf "\nMissing --id. ">&2;
		print_usage_then_exit;
	fi
fi

if [ $ONLY_VAlIDATE -eq 1 ]; then exit 0; fi

case "$ID" in
	"0x0800") exit 0; ;;	# IP (IPv4)
	"0x0805") exit 1; ;;	# X25
	"0x0806") exit 0; ;;	# Address Resolution Protocol
	"0x0808") exit 1; ;;	# Frame Relay ARP [RFC1701]
	"0x08FF") exit 1; ;;	# G8BPQ AX.25 over Ethernet
	"0x22F3") exit 1; ;;	# TRILL [RFC6325]
	"0x22F4") exit 1; ;;	# TRILL L2-IS-IS [RFC6325]
	"0x6558") exit 1; ;;	# Transparent Ethernet Bridging [RFC1701]
	"0x6559") exit 1; ;;	# Raw Frame Relay [RFC1701]
	"0x8035") exit 1; ;;	# Reverse ARP [RFC903]
	"0x809B") exit 1; ;;	# Appletalk
	"0x80F3") exit 1; ;;	# Appletalk Address Resolution Protocol
	"0x8137") exit 1; ;;	# Novell IPX
	"0x8191") exit 1; ;;	# NetBEUI
	"0x86DD") exit 1; ;;	# IP version 6
	"0x880B") exit 1; ;;	# Point-to-Point Protocol
	"0x8847") exit 1; ;;	# MPLS [RFC5332]
	"0x8848") exit 1; ;;	# MPLS with upstream-assigned label [RFC5332]
	"0x884C") exit 1; ;;	# MultiProtocol over ATM
	"0x8863") exit 1; ;;	# PPP over Ethernet discovery stage
	"0x8864") exit 1; ;;	# PPP over Ethernet session stage
	"0x8884") exit 1; ;;	# Frame-based ATM Transport over Ethernet
	"0x888E") exit 1; ;;	# EAP over LAN [802.1x]
	"0x88C7") exit 1; ;;	# EAPOL Pre-Authentication [802.11i]
	"0x88CC") exit 1; ;;	# Link Layer Discovery Protocol [802.1ab]
	"0x88E5") exit 1; ;;	# Media Access Control Security [802.1ae]
	"0x88E7") exit 1; ;;	# Provider Backbone Bridging [802.1ah]
	"0x88F5") exit 1; ;;	# Multiple VLAN Registration Protocol [802.1q]
	"0x88F7") exit 1; ;;	# Precision Time Protocol
	"0x8906") exit 1; ;;	# Fibre Channel over Ethernet
	"0x8914") exit 1; ;;	# FCoE Initialization Protocol
	"0x8915") exit 1; ;;	# RDMA over Converged Ethernet
	"0xA0ED") exit 1; ;;	# LoWPAN encapsulation
	"0x8100") exit 0; ;;	# VLAN tagged frame [802.1q]
	"0x88A8") exit 0; ;;	# QinQ Service VLAN tag identifier [802.1q]
	*)
		printf "\nInvalid --id. \n\n">&2;
		printf "Refer to: https://www.iana.org/assignments/ieee-802-numbers/ieee-802.numbers.xhtml\n">&2;
		printf "Refer to: https://standards-oui.ieee.org/ethertype/eth.csv\n\n">&2;
		printf "Note: not all protocols are listed. If it does not work or is not in the script, it is unsupported.\n\n">&2;
		print_usage_then_exit;
	;;
esac

exit 0;
