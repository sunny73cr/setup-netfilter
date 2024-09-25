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
