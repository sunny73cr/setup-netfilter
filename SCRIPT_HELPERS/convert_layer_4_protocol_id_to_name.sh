#!/bin/sh

usage () {
	echo "Usage: $0 <arguments>\n">&2;
	printf " --id [a-zA-Z0-9]\n">&2;
	printf "\n">&2;
	exit 2;
}

ID="";

if [ "$1" = "" ]; then usage; fi

while true; do
	case $1 in
		--id)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				ID=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "Unrecognised argument $1. ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z "$ID" ]; then
	echo "\nMissing --id. ">&2;
	print_usage_then_exit;
fi

case $ID in
	1) printf "icmp"; ;; 	#ICMP
	6) printf "tcp"; ;; 	#TCP
	17) printf "udp"; ;;	#UDP
	*) 			#Unknown
		echo "\nInvalid --id. ">&2; print_usage_then_exit; ;;
esac

exit 0;
