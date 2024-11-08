#!/bin/sh

print_description() {
	printf "A program that assists a developer in parsing arguments for use in their user-facing shell scripts.\n">&2;
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
	printf "Usage: $0 <arguments>\n">&2;
	printf "Flags used by themselves: \n">&2;
	printf " -e (prints an explanation of the functions' purpose) (exit code 2)\n">&2;
	printf " -h (prints an explanation of the functions' available parameters, and their effect) (exit code 2)\n">&2;
	printf " -d (prints the functions' dependencies: newline delimited list) (exit code 2)\n">&2
	printf " -ehd (prints the above three) (exit code 2)\n">&2;
	printf "\n">&2;
	printf "Parameters:\n">&2;
	printf "\n">&2;
	printf "  Optional: --arguments string (comma delimited/separated list).\n">&2;
	printf "  Optional: --flags string (comma delimited/separated list).\n">&2;
	printf "\n">&2;
	printf " The \"arguments\" list contains parameter names that require values.\n">&2;
	printf " Your shell will likely support any type of argument including numbers, strings, regex, etc in this type of parameter.\n">&2;
	printf " \"arguments\" are provided by the user in the form of:\n">&2;
	printf "   1. \"--argument 'value'\" (allows string literals).\n">&2;
	printf "   2. \"--argument \"value\"\" (allows $ parameter expansion).\n">&2;
	printf "   3. \"--argument value\" (dependent on the shell used to call the script).\n">&2;
	printf "\n">&2;
	printf " The \"flags\" list contains parameter names that are initially zero, and those values should be toggled on when the flag is present.\n">&2;
	printf " These arguments are akin to boolean values, which will change the execution of your program.\n">&2;
	printf " \"flags\" are provided by the user in the form of \"--flag\".\n">&2;
	printf "\n">&2;
	printf " If you choose to omit both arguments and flags, you intend your program to called without any parameters.\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi;

sanitise_space_separated_values() {
	if [ "$1" = "" ]; then
		echo "";
	else
		echo "$1" | sed 's/[[:space:]]\+/ /g' | sed 's/^["]\+[[:space:]]\+\(.*\)[[:space:]]\+["]\+$/\1/g';
	fi
}

ARGUMENTS="";
FLAGS="";

while true; do
	case "$1" in
		--arguments)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				ARGUMENTS=$2;
				shift 2;
			fi
		;;
		--flags)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				FLAGS=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "\nUnrecognised argument $1. ">&2; print_usage_then_exit; ;;
	esac
done;

#initialise arguments
printf "#ARGUMENTS:\n";

ARGUMENTS_CLEANED=$(sanitise_space_separated_values "$ARGUMENTS");

if [ -n "$ARGUMENTS_CLEANED" ]; then
	if [ "$(echo \"$ARGUMENTS_CLEANED\" | grep '[,]\+')" = "" ]; then
		printf "$ARGUMENTS_CLEANED=\"\";\n";
	else
		i=1;
		while true; do
			ARG=$(echo "$ARGUMENTS" | cut -d ',' -f $i);
			if [ -z "$ARG" ]; then break; fi

			printf "$ARG=\"\";\n";

			i=$(($i+1));
		done;
	fi
fi
printf "\n";

#initialise flags
printf "#FLAGS:\n";

#Replace double spaces with a single space, then remove any leading or trailing spaces
FLAGS_CLEANED=$(sanitise_space_separated_values "$FLAGS");

if [ -n "$FLAGS_CLEANED" ]; then
	if [ "$(echo \"$FLAGS_CLEANED\" | grep '[,]\+')" = "" ]; then
		printf "$FLAGS_CLEANED=0;\n";
	else
		j=1;
		while true; do
			THIS_FLAG=$(echo "$FLAGS" | cut -d ',' -f $j);
			if [ -z "$THIS_FLAG" ]; then break; fi

			printf "$THIS_FLAG=0;\n";

			j=$(($j+1));
		done;
	fi
fi
printf "\n";

#print loop to parse parameters.
printf "while true; do\n";
printf "\tcase \$1 in\n";

#handle arguments
if [ -n "$ARGUMENTS_CLEANED" ]; then
	printf "\t\t#Approach to parsing arguments:\n";
	printf "\t\t#If the length of 'all arguments' is less than 2 (shift reduces this number),\n";
	printf "\t\t#since this is an argument parameter and requires a value; the program cannot continue.\n";
	printf "\t\t#Else, if the argument was provided, and its 'value' is empty; the program cannot continue.\n";
	printf "\t\t#Else, assign the argument, and shift 2 (both the argument indicator and its value / move next)\n";

	printf "\n";

	if [ "$(echo \"$ARGUMENTS_CLEANED\" | grep '[,]\+')" = "" ]; then
			printf "\t\t--$ARGUMENTS_CLEANED)\n";
			printf "\t\t\tif [ \$# -lt 2 ]; then\n";
			printf "\t\t\t\tprintf \"\\\nNot enough arguments (value for \$1 is missing.) \">&2;\n";
			printf "\t\t\t\tprint_usage_then_exit;\n";
			printf "\t\t\telif [ -z \"\$2\" ]; then\n";
			printf "\t\t\t\tprintf \"\\\nNot enough arguments (value for \$1 is empty.) \">&2;\n";
			printf "\t\t\t\tprint_usage_then_exit;\n";
			printf "\t\t\telse\n";
			printf "\t\t\t\t$ARGUMENTS_CLEANED=\$2;\n";
			printf "\t\t\t\tshift 2;\n";
			printf "\t\t\tfi\n";
			printf "\t\t;;\n\n";
	else
		k=1;
		while true; do
			ARG=$(echo "$ARGUMENTS_CLEANED" | cut -d ',' -f $k);
			if [ -z "$ARG" ]; then break; fi

			printf "\t\t--$ARG)\n";
			printf "\t\t\tif [ \$# -lt 2 ]; then\n";
			printf "\t\t\t\tprintf \"\\\nNot enough arguments (value for \$1 is missing.) \">&2;\n";
			printf "\t\t\t\tprint_usage_then_exit;\n";
			printf "\t\t\telif [ -z \"\$2\" ]; then\n";
			printf "\t\t\t\tprintf \"\\\nNot enough arguments (value for \$1 is empty.) \">&2;\n";
			printf "\t\t\t\tprint_usage_then_exit;\n";
			printf "\t\t\telse\n";
			printf "\t\t\t\t$ARG=\$2;\n";
			printf "\t\t\t\tshift 2;\n";
			printf "\t\t\tfi\n";
			printf "\t\t;;\n\n";

			k=$(($k+1));
		done;
	fi
fi

#handle flags
if [ -n "$FLAGS_CLEANED" ]; then
	printf "\t\t#Approach to parsing flags:\n";
	printf "\t\t#If the flag was provided, toggle on its value; then move next\n";
	printf "\t\t#Or shift 1 / remove the flag from the list\n";

	printf "\n";

	if [ "$(echo \"$FLAGS_CLEANED\" | grep '[,]\+')" = "" ]; then
		printf "\t\t--$FLAGS_CLEANED)\n";
		printf "\t\t\t$FLAGS_CLEANED=1;\n";
		printf "\t\t\tshift 1;\n";
		printf "\t\t;;\n\n";
	else
		l=1;
		while true; do
			FLAG=$(echo "$FLAGS" | cut -d ',' -f $l);
			if [ -z "$FLAG" ]; then break; fi

			printf "\t\t--$FLAG)\n";
			printf "\t\t\t$FLAG=1;\n";
			printf "\t\t\tshift 1;\n";
			printf "\t\t;;\n\n";

			l=$(($l+1));
		done;
	fi
fi

printf "\t\t#Handle the case of 'end' of arg parsing; where all flags are shifted from the list,\n";
printf "\t\t#or the program was called without any parameters. exit the arg parsing loop.\n";
printf "\t\t\"\") break; ;;\n\n";

printf "\t\t#Handle the case where an argument or flag was called that the program does not recognise.\n";
printf "\t\t#This should prefix the 'usage' text with the reason the program failed.\n";
printf "\t\t#The 'Standard Error' file descriptor is used to separate failure output or log messages from actual program output.\n";
printf "\t\t*) printf \"\\\nUnrecognised argument \$1. \">&2; print_usage_then_exit; ;;\n\n";

printf "\tesac\n";
printf "done;\n\n";

exit 0;
