#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

print_description() {
	printf "A program that returns a 0 exit code if the Differentiated Services Code Point (DSCP) is valid, and 1 if it is not.\n">&2;
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
	printf "Flags used by themselves: \n">&2;
	printf " -e (prints an explanation of the functions' purpose) (exit code 2)\n">&2
	printf " -h (prints an explanation of the functions' available parameters, and their effect) (exit code 2)\n">&2;
	printf " -d (prints the functions' dependencies: newline delimited list) (exit code 2)\n">&2;
	printf " -ehd (prints the above three) (exit code 2)\n">&2;
	printf "\n">&2;
	printf "Parameters:\n">&2;
	printf "\n">&2;
	printf " Required: --code\n">&2;
	printf "  This is a decimal code relating to an assigned \"DSCP Code\" as defined by IANA.\n">&2;
	printf "  Refer to: https://iana.org/assignments/dscp-registry/dscp-registry.xhtml\n">&2;
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

#FLAGS:

while true; do
	case $1 in
		#Approach to parsing arguments:
		#If the length of 'all arguments' is less than 2 (shift reduces this number),
		#since this is an argument parameter and requires a value; the program cannot continue.
		#Else, if the argument was provided, and its 'value' is empty; the program cannot continue.
		#Else, assign the argument, and shift 2 (both the argument indicator and its value / move next)

		--code)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				CODE=$2;
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

if [ -z "$CODE" ]; then
	printf "\nMissing --code. ">&2;
	print_usage_then_exit;
fi

if [ -z "$(echo $CODE | grep '[0-9]\{1,2\}')" ]; then
	printf "\nInvalid --code. Must be a decimal number. ">&2;
	print_usage_then_exit;
fi

case $CODE in
	0) exit 0; ;; #CS0
	8) exit 0; ;; #CS1
	16) exit 0; ;; #CS2
	24) exit 0; ;; #CS3
	32) exit 0; ;; #CS4
	40) exit 0; ;; #CS5
	48) exit 0; ;; #CS6
	56) exit 0; ;; #CS7
	10) exit 0; ;; #AF11
	12) exit 0; ;; #AF12
	14) exit 0; ;; #AF13
	18) exit 0; ;; #AF21
	20) exit 0; ;; #AF22
	22) exit 0; ;; #AF23
	26) exit 0; ;; #AF31
	28) exit 0; ;; #AF32
	30) exit 0; ;; #AF33
	34) exit 0; ;; #AF41
	36) exit 0; ;; #AF42
	38) exit 0; ;; #AF43
	46) exit 0; ;; #EF
	44) exit 0; ;; #VOICE-ADMIT
	*) exit 1; ;;
esac

exit 0;
