#!/bin/sh

print_description() {
	printf "A program that assists a developer in writing scripts by printing a template of fault-tolerant program imports or 'dependencies'.\n">&2;
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
	printf "Flags used by themselves: \n">&2;
	printf " -e (prints an explanation of the functions' purpose) (exit code 2)\n">&2;
	printf " -h (prints an explanation of the functions' available parameters, and their effect) (exit code 2)\n">&2;
	printf " -d (prints the functions' dependencies: newline delimited list) (exit code 2)\n">&2
	printf " -ehd (prints the above three) (exit code 2)\n">&2;
	printf "\n">&2;
	printf "Parameters:\n">&2;
	printf "\n">&2;
	printf " None.\n">&2;
	printf "\n">&2;
	printf " This program should be called without parameters.\n">&2;
	printf " It is most likely that you wish to concatenate the output to a shell script file.\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; printf "Dependencies:\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

printf "if [ -z \"\$ENV_SETUP_NFT\" ]; then printf \"setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\\\n\">&2; exit 4; fi\n";
printf "\n";
printf "DEPENDENCY_PATH_SCRIPT_NAME=\"\$ENV_SETUP_NFT/path_to_script.sh\";\n";
printf "\n";
printf "if [ ! -x \$DEPENDENCY_PATH_SCRIPT_NAME ]; then\n";
printf "\tprintf \"\$0: dependency: \\\"\$DEPENDENCY_PATH_NAME\\\" is missing or is not executable.\\\n\">&2;\n";
printf "\texit 3;\n";
printf "fi\n";

exit 0;
