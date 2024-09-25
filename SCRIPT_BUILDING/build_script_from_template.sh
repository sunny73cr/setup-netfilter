#!/bin/sh

if [ -z $ENV_SETUP_NFT ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_BUILD_SCRIPT_IMPORTS="$ENV_SETUP_NFT/SCRIPT_BUILDING/build_script_imports.sh";

if [ ! -x $DEPENDENCY_PATH_BUILD_SCRIPT_IMPORTS ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_BUILD_SCRIPT_IMPORTS\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_BUILD_SCRIPT_HELP_FUNCTIONS="$ENV_SETUP_NFT/SCRIPT_BUILDING/build_script_description_dependencies_usage_functions.sh";

if [ ! -x $DEPENDENCY_PATH_BUILD_SCRIPT_HELP_FUNCTIONS ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_BUILD_SCRIPT_HELP_FUNCTIONS\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_BUILD_SCRIPT_ARGUMENT_PARSING="$ENV_SETUP_NFT/SCRIPT_BUILDING/build_script_argument_parsing.sh";

if [ ! -x $DEPENDENCY_PATH_BUILD_SCRIPT_ARGUMENT_PARSING ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_BUILD_SCRIPT_ARGUMENT_PARSING\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_description() {
	printf "A program that performs a function.\n">&2;
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
	printf "  Optional: --arguments string (a comma separated/delimited list of arguments that your program features).\n">&2;
	printf "   In your resulting program, each argument can be used in one of the following formats:\n">&2;
	printf "    1. \"--argument 'value'\"\n">&2;
	printf "    2. \"--argument \"value\"\"\n">&2;
	printf "    3. \"--argument value\"\n">&2;
	printf "\n">&2;
	printf "  Optional: --flags string (a comma separated/delimited list of boolean flags that your program features).\n">&2;
	printf "   In your resulting program, each flag is used in the following format: \"--flag\" (or it is not provided).\n">&2;
	printf "\n">&2;
	printf "  Optional: --destination-directory string (the place to create the script (local locations only)).\n">&2;
	printf "   If the directory does not exist, the directory itself and all missing parent directories will be created.\n">&2;
	printf "   If the --destination-directory argument is not provided; it defaults to the current working directory.\n">&2;
	printf "\n">&2;
	printf "  Required: --file-name string (the name of the script to create (include the extension)).\n">&2;
	printf "   The file name. Must adhere to the usual linux file name restrictions. Please don't include any newline characters, and spaces are preffered to be avoided. \n">&2;
	printf "\n">&2;
	printf "  Optional: --directory-permissions string (The linux-style octal triplet for controlling permissions over the directory. eg. 755).\n">&2;
	printf "   The linux-style octal triplet contains a sum of the values 0, 1, 2, or 4. 1 for write, 2 for execute, 4 for read. The triplet indicates permissions for the directory Owner, then the Group, then 'all Other' users.\n">&2;
	printf "   Note: the default permissions are: 755, or 'read, write, execute' for the Owner; 'read, execute' for the Group; and 'read, execute' for 'all Other' users.\n">&2;
	printf "\n">&2;
	printf "  Optional: --file-permissions string (The linux-style octal triplet for controlling permissions over the file. eg. 755).\n">&2;
	printf "   The linux-style octal triplet contains a sum of the values 0, 1, 2, or 4. 1 for write, 2 for execute, 4 for read. The triplet indicates permissions for the file Owner, then the Group, then 'all Other' users.\n">&2;
	printf "   Note: the default permissions are: 755, or 'read, write, execute' for the Owner; 'read, execute' for the Group; and 'read, execute' for 'all Other' users.\n">&2;
	printf "\n">&2;
	printf "  Optional: --no-clobber.\n">&2;
	printf "   Presence of this flag in the case that the file already exists, will cause the program to exit with a code of '4' (environmental error).\n">&2;
	printf "   \"Don't bash (clobber) my scripts over their head resulting in their removal.\"\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
ARGUMENTS="";
FLAGS="";
FILE_NAME="";

#FLAGS:
NO_CLOBBER=0;

while true; do
	case $1 in
		--arguments)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				ARGUMENTS=$2;
				shift 2;
			fi
		;;

		--flags)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				FLAGS=$2;
				shift 2;
			fi
		;;

		--destination-directory)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				DESTINATION_DIRECTORY=$2;
				shift 2;
			fi
		;;

		--file-name)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				FILE_NAME=$2;
				shift 2;
			fi
		;;

		--directory-permissions)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				DIRECTORY_PERMISSIONS=$2;
				shift 2;
			fi
		;;

		--file-permissions)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				FILE_PERMISSIONS=$2;
				shift 2;
			fi
		;;

		--no-clobber)
			NO_CLOBBER=1;
			shift 1;
		;;

		#Handle the case of 'end' of arg parsing; where all flags are shifted from the list,
		#or the program was called without any parameters. exit the arg parsing loop.
		"") break; ;;

		#Handle the case where a argument or flag was called that the program does not recognise.
		#This should prefix the 'usage' text with the reason the program failed.
		#The 'Standard Error' file descriptor is used to separate failure output or log messages from actual program output.
		*) printf "\nUnrecognised argument $1 ">&2; print_usage_then_exit; ;;

	esac
done;

if [ -n "$DESTINATION_DIRECTORY" ]; then
	if [ ! -d $DESTINATION_DIRECTORY ]; then
		#if needed, create the path include 'parent' directories
		if [ -n "$DIRECTORY_PERMISSIONS" ]; then
			DIR_PERM_OWN=$(echo $DIRECTORY_PERMISSIONS | cut -c 1);
			#TODO: use these when supporting creating dirs owned by other users.
			#DIR_PERM_GRP=$(echo $DIRECTORY_PERMISSIONS | cut -c 2);
			#DIR_PERM_OTH=$(echo $DIRECTORY_PERMISSIONS | cut -c 3);

			#is not writable
			if [ $(($DIR_PERM_OWN & 2)) -eq 0 ]; then
				printf "$0: the directory permissions you supplied indicates that it is not writable.\n">&2;
				printf "$0: the program must write to the directory to create the file.\n">&2;
				printf "$0: retry, and supply a set of permissions where the '2' or 'writable' bit is set.\n">&2;
				exit 2;
			fi

			mkdir -p -m $DIRECTORY_PERMISSIONS $DESTINATION_DIRECTORY;
		else
			mkdir -p -m 755 $DESTINATION_DIRECTORY;
		fi
	fi
else
	DESTINATION_DIRECTORY=$(pwd);

	if [ ! -w $DESTINATION_DIRECTORY ]; then
		printf "$0: the current working directory is not writable.\n">&2;
		printf "$0: please re-try, and provide a destination directory using --destination-directory path.\n">&2;
		exit 4;
	fi
fi

FILE_PATH=$(echo "$DESTINATION_DIRECTORY/$FILE_NAME" | sed 's/\/\//\//g');

if [ $NO_CLOBBER -eq 1 ]; then
	if [ -f "$FILE_PATH" ]; then
		printf "$0: A file exists at that location, and the --no-clobber flag was enabled: cannot overwrite the file.\n">&2;
		exit 4;
	fi
else
	rm "$FILE_PATH";
fi

touch "$FILE_PATH";

if [ -n "$FILE_PERMISSIONS" ]; then
	chmod $FILE_PERMISSIONS "$FILE_PATH";
else
	chmod 755 "$FILE_PATH";
fi

printf "#!/bin/sh\n\n" >> "$FILE_PATH";

$DEPENDENCY_PATH_BUILD_SCRIPT_IMPORTS >> "$FILE_PATH";
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_PATH_BUILD_SCRIPT_IMPORTS\" produced a failure exit code. Deleting the malformed script.\n">&2; rm "$FILE_PATH"; exit 3; ;;
esac

printf "\n" >> "$FILE_PATH";

$DEPENDENCY_PATH_BUILD_SCRIPT_HELP_FUNCTIONS >> "$FILE_PATH";
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_PATH_BUILD_SCRIPT_HELP_FUNCTIONS\" produced a failure exit code. Deleting the malformed script.\n">&2; rm "$FILE_PATH"; exit 3; ;;
esac

printf "\n" >> "$FILE_PATH";

#Build a command with arguments to be called later.
CMD_BUILD_SCRIPT_ARGUMENT_PARSING="$DEPENDENCY_PATH_BUILD_SCRIPT_ARGUMENT_PARSING";

#If needed, append arguments.
if [ -n "$ARGUMENTS" ]; then
	CMD_BUILD_SCRIPT_ARGUMENT_PARSING="$CMD_BUILD_SCRIPT_ARGUMENT_PARSING --arguments $ARGUMENTS";
fi

#If needed, append flags.
if [ -n "$FLAGS" ]; then
	CMD_BUILD_SCRIPT_ARGUMENT_PARSING="$CMD_BUILD_SCRIPT_ARGUMENT_PARSING --flags $FLAGS";
fi

#Call the command.
$CMD_BUILD_SCRIPT_ARGUMENT_PARSING >> "$FILE_PATH";
case $? in
	0) ;;
	*) printf "$0: dependency: \"$DEPENDENCY_PATH_BUILD_SCRIPT_ARGUMENT_PARSING\" produced a failure exit code: \"$?\". Deleting the malformed script.\n">&2; exit 3; ;;
	#rm "$FILE_PATH";
esac

exit 0;
