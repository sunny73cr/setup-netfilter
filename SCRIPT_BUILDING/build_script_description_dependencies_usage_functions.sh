#!/bin/sh

print_description() {
	printf "A program that assists a developer in writing scripts by building a template for description, dependency list and usage functions.\n">&2;
	printf "\n";
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
	printf " -d (prints the functions' dependencies: newline delimited list) (exit code 2)\n">&2;
	printf " -ehd (prints the above three) (exit code 2)\n">&2;
	printf "\n">&2;
	printf "Parameters:\n">&2;
	printf "\n None.">&2;
	printf "\n">&2;
	printf " This script should be called without parameters.\n">&2;
	printf " It is most likely that you wish to concatenate the output to a shell script file.\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; printf "Dependencies:\n">&2;  print_dependencies; printf "\n">&2; print_usage; exit 2; fi

printf "print_description() {\n";
printf "\tprintf \"A program that performs a function.\\\n\">&2;\n";
printf "}\n";
printf "\n";
printf "print_description_then_exit() {\n";
printf "\tprint_description;\n";
printf "\texit 2;\n";
printf "}\n";
printf "\n";
printf "if [ \"\$1\" = \"-e\" ]; then print_description_then_exit; fi\n";
printf "\n";
printf "print_dependencies() {\n";
printf "\tprintf \"printf\\\n\">&2;\n";
printf "\tprintf \"echo\\\n\">&2;\n";
printf "\tprintf \"\\\n\">&2;\n";
printf "}\n";
printf "\n";
printf "print_dependencies_then_exit() {\n";
printf "\tprint_dependencies;\n";
printf "\texit 2;\n";
printf "}\n";
printf "\n";
printf "if [ \"\$1\" = \"-d\" ]; then print_dependencies_then_exit; fi\n";
printf "\n";
printf "print_usage() {\n";
printf "\tprintf \"Usage: \$0 <parameters>\\\n\">&2;\n";
printf "\tprintf \" -e\\\n\">&2;\n";
printf "\tprintf \" calling the program with the '-e' flag prints an explanation of the scripts' function or purpose.\\\n\">&2;\n";
printf "\tprintf \" The program then exits with a code of 2 (user input error).\\\n\">&2;\n";
printf "\tprintf \"\\\n\">&2;\n";
printf "\tprintf \" -h\\\n\">&2;\n";
printf "\tprintf \" calling the program with the '-h' flag prints an explanation of the scripts' parameters and their effect.\\\n\">&2;\n";
printf "\tprintf \" The program then exits with a code of 2 (user input error).\\\n\">&2;\n";
printf "\tprintf \"\\\n\">&2;\n";
printf "\tprintf \" -d\\\n\">&2;\n";
printf "\tprintf \" callling the program with the '-d' flags prints a (new-line separated, and terminated) list of the programs' dependencies (what it needs to run).\\\n\">&2;\n";
printf "\tprintf \" The program then exits with a code of 2 (user input error).\\\n\">&2;\n";
printf "\tprintf \"\\\n\">&2;\n";
printf "\tprintf \" -ehd\\\n\">&2;\n";
printf "\tprintf \" calling the program with the '-ehd' flag (or, ehd-ucate me) prints the description, the dependencies list, and the usage text.\\\n\">&2;\n";
printf "\tprintf \" The program then exits with a code of 2 (user input error).\\\n\">&2;\n";
printf "\tprintf \"\\\n\">&2;\n";
printf "\tprintf \" Note that calling all scripts in a project with the flag '-ehd', then concatenating their output using file redirection (string > file),\\\n\">&2;\n";
printf "\tprintf \" Is a nice and easy way to maintain documentation for your project.\\\n\">&2;\n";
printf "\tprintf \"\\\n\">&2;\n";
printf "\tprintf \"Parameters:\\\n\">&2;\n";
printf "\tprintf \"\\\n\">&2;\n";
printf "\tprintf \"  Optional: --argument string (describe a required format).\\\n\">&2;\n";
printf "\tprintf \"  Required: --argument string (describe a required format).\\\n\">&2;\n";
printf "\tprintf \"\\\n\">&2;\n";
printf "}\n";
printf "\n";
printf "print_usage_then_exit() {\n";
printf "\tprint_usage;\n";
printf "\texit 2;\n";
printf "}\n";
printf "\n";
printf "if [ \"\$1\" = \"-h\" ]; then print_usage_then_exit; fi\n";
printf "\n";
printf "if [ \"\$1\" = \"-ehd\" ]; then print_description; printf \"\\\n\">&2; print_dependencies; printf \"\\\n\">&2; print_usage; exit 2; fi\n";

exit 0;
