#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

print_description() {
	printf "A program that prints help text for all or a subset of the scripts available within setup-netfilter.\n">&2;
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
	printf "Flags used by themselves: \n">&2;
	printf " -e (prints an explanation of the functions' purpose) (exit code 2)\n">&2
	printf " -h (prints an explanation of the functions' available parameters, and their effect) (exit code 2)\n">&2;
	printf " -d (prints the functions' dependencies: newline delimited list) (exit code 2)\n">&2;
	printf " -ehd (prints the above three) (exit code 2)\n">&2;
	printf "\n">&2;
	printf "Parameters:\n">&2;
	printf "\n">&2;
	printf " Optional: --type x (where x is an option from the list below)\n">&2;
	printf "  Note: the default is 'all'. Output is lengthy and is best viewed in less.\n">&2;
	printf "\n">&2;
	printf "  all - print help for all scripts.\n">&2;
	printf "  development - scripts useful during extension of the project.\n">&2;
	printf "  script-building - when writing scripts for use in setup-netfilter.\n">&2;
	printf "  script-helpers - tools available when writing scripts for use in setup-netfilter.\n">&2;
	printf "  bogons-mac - matching MAC Bogon addresses\n">&2;
	printf "  bogons-ipv4 - matching IPV4 Bogon addresses\n">&2;
	printf "  bogons-ipv6 - matching IPV6 Bogon addresses\n">&2;
	printf "  bogons-region - matching Region-specific addresses\n">&2;
	printf "  layer-1 - matching an interface\n">&2;
	printf "  ethernet - matching an ethernet header\n">&2;
	printf "  ipv4 - matching an IPV4 header\n">&2;
	printf "  ipv6 - matching an IPV6 header\n">&2;
	printf "  tcp - matching a TCP header\n">&2;
	printf "  udp - matching a UDP header\n">&2;
	printf "  icmp - matching an ICMP header\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
TYPE="";

#FLAGS:

while true; do
	case $1 in
		#Approach to parsing arguments:
		#If the length of 'all arguments' is less than 2 (shift reduces this number),
		#since this is an argument parameter and requires a value; the program cannot continue.
		#Else, if the argument was provided, and its 'value' is empty; the program cannot continue.
		#Else, assign the argument, and shift 2 (both the argument indicator and its value / move next)

		--type)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				TYPE=$2;
				shift 2;
			fi
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

display_ehducate_scripts_in_folder() {
	SCRIPTS=$(ls -1 "$1");
	i=1;
	while true; do
		THIS_SCRIPT=$(echo $SCRIPTS | cut -d ' ' -f $i);
		if [ -z "$THIS_SCRIPT" ]; then break; fi

		$1/$THIS_SCRIPT -e;

		HELP_OUTPUT=$($1/$THIS_SCRIPT -h);
		HELP_LINE_COUNT=$(echo $HELP_OUTPUT | wc -l);
		HELP_TRIMMED=$(echo $HELP_OUTPUT | tail -n $(($HELP_LINE_COUNT-7)));
		echo $HELP_TRIMMED;

		$1/$THIS_SCRIPT -d;

		i=$(($i+1));
	done
}

display_help_script_helpers () {
	display_ehducate_scripts_in_folder "$ENV_SETUP_NFT/SCRIPT_HELPERS/";
}

display_help_script_building () {
	display_ehducate_scripts_in_folder "$ENV_SETUP_NFT/SCRIPT_BUILDING/";
}

display_help_bogons_mac () {
	display_ehducate_scripts_in_folder "$ENV_SETUP_NFT/RULE_HELPERS/BOGONS/MAC/";
}

display_help_bogons_ipv4 () {
	display_ehducate_scripts_in_folder "$ENV_SETUP_NFT/RULE_HELPERS/BOGONS/IPV4/";
}

display_help_bogons_ipv6 () {
	display_ehducate_scripts_in_folder "$ENV_SETUP_NFT/RULE_HELPERS/BOGONS/IPV6/";
}

display_help_bogons_region () {
	display_ehducate_scripts_in_folder "$ENV_SETUP_NFT/BOGONS/REGION/";
}

display_help_layer_1 () {
	display_ehducate_scripts_in_folder "$ENV_SETUP_NFT/LAYER_1/";
}

display_help_ethernet () {
	display_ehducate_scripts_in_folder "$ENV_SETUP_NFT/ETHERNET/";
}

display_help_ipv4 () {
	display_ehducate_scripts_in_folder "$ENV_SETUP_NFT/IPV4/";
}

display_help_ipv6 () {
	display_ehducate_scripts_in_folder "$ENV_SETUP_NFT/IPV6/";
}

display_help_tcp () {
	display_ehducate_scripts_in_folder "$ENV_SETUP_NFT/TCP/";
}

display_help_udp () {
	display_ehducate_scripts_in_folder "$ENV_SETUP_NFT/UDP/";
}

display_help_icmp () {
	display_ehducate_scripts_in_folder "$ENV_SETUP_NFT/ICMP/";
}

case $TYPE in
	all)
		display_help_script_helpers;
		display_help_script_building;
		display_help_bogons_mac;
		display_help_bogons_ipv4;
		display_help_bogons_ipv6;
		display_help_bogons_region;
		display_help_layer_1;
		display_help_ethernet;
		display_help_ipv4;
		display_help_ipv6;
		display_help_tcp;
		display_help_udp;
		display_help_icmp;
	;;
	development)
		display_help_script_helpers;
		display_help_script_building;
		display_help_bogons_mac;
		display_help_bogons_ipv4;
		display_help_bogons_ipv6;
		display_help_bogons_region;
		display_help_layer_1;
		display_help_ethernet;
		display_help_ipv4;
		display_help_ipv6;
		display_help_tcp;
		display_help_udp;
		display_help_icmp;
	;;
#	usage)
#         to be defined
#	;;
	script-helpers) 	display_help_script_helpers; ;;
	script-building) 	display_help_script_building; ;;
	bogons-mac) 		display_help_bogons_mac; ;;
	bogons-ipv4) 		display_help_bogons_ipv4; ;;
	bogons-ipv6) 		display_help_bogons_ipv6; ;;
	bogons-region)		display_help_bogons_region; ;;
	layer-1) 		display_help_layer_1; ;;
	ethernet) 		display_help_ethernet; ;;
	ipv4) 			display_help_ipv4; ;;
	ipv6) 			display_help_ipv6; ;;
	tcp) 			display_help_tcp; ;;
	udp) 			display_help_udp; ;;
	icmp) 			display_help_icmp; ;;
	*) printf "\nUnrecognised type. ">&2; print_usage_then_exit; ;;
esac

exit 0;
