#!/bin/sh

print_usage_then_exit () {
	printf "Usage: $0 <arguments>\n">&2;
	printf " --name string\n">&2;
	printf "\n";
	printf " Optional: --newline-suffix-output\n";
	printf " Note: this causes the program to output a newline after the result.\n";
	printf "\n";
	exit 2;
}

if [ "$1" = "" ]; then usage; fi

NAME="";
NEWLINE_SUFFIX_OUTPUT=0;

while true; do
	case $1 in
		--name)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				NAME=$2;
				shift 2;
			fi
		;;
		--newline-suffix-output)
			NEWLINE_SUFFIX_OUTPUT=1;
			shift 1;
		;;
		"") break; ;;
		*) printf "\nUnrecognised argument $1. ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z "$NAME" ]; then
	echo "\nInvalid --name. ">&2;
	print_usage_then_exit;
fi

USER_ID="$(sudo cat /etc/passwd | grep -P "^$NAME:" | cut -d ":" -f 3)";

printf "$USER_ID";

if [ $NEWLINE_SUFFIX_OUTPUT -eq 1 ]; then
	printf "\n";
fi

exit 0;
