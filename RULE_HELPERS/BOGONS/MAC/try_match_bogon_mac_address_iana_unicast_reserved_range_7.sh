#!/bin/sh

print_description() {
	printf "A program that prints a portion of an NFT rule match section. The match identifies packets with a source or destination MAC (ether) address between 00:00:5E:90:01:01 and 00:00:5E:90:01:FF (inclusive) (IANA Reserved Unicast Range '7').\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "Dependencies: \n">&2;
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
	printf "Flags used by themselves: \n">&2;
	printf " -e (prints an explanation of the functions' purpose) (exit code 2)\n">&2;
	printf " -h (prints an explanation of the functions' available parameters, and their effect) (exit code 2)\n">&2;
	printf " -d (prints the functions' dependencies: newline delimited list) (exit code 2)\n">&2
	printf " -ehd (prints the above three) (exit code 2)\n">&2;
	printf "\n">&2;
	printf "Parameters:\n">&2;
	printf "\n">&2;
	printf "  Required: --source-or-destination ('source' or 'destination', without quotes.)\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
SOURCE_OR_DESTINATION="";

#FLAGS:

while true; do
	case $1 in
		#Approach to parsing arguments:
		#If the length of 'all arguments' is less than 2 (shift reduces this number),
		#since this is an argument parameter and requires a value; the program cannot continue.
		#Else, if the argument was provided, and its 'value' is empty; the program cannot continue.
		#Else, assign the argument, and shift 2 (both the argument indicator and its value / move next)

		--source-or-destination)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				SOURCE_OR_DESTINATION=$2;
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

if [ -z "$SOURCE_OR_DESTINATION" ]; then
	printf "\nMissing --source-or-destination. ">&2;
	print_usage_then_exit;
fi

MAC_ADDRESS_TYPE="";

case "$SOURCE_OR_DESTINATION" in
	"source") MAC_ADDRESS_TYPE="saddr"; ;;
	"destination") MAC_ADDRESS_TYPE="daddr"; ;;
	*) printf "\nInvalid --source-or-destination. ">&2; print_usage_then_exit; ;;
esac

printf "\\t\\tether $MAC_ADDRESS_TYPE >= 00:00:5E:90:01:01 \\\\\n";
printf "\\t\\tether $MAC_ADDRESS_TYPE <= 00:00:5E:90:01:FF \\\\\n";

exit 0;
