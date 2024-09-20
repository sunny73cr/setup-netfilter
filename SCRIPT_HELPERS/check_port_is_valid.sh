#!/bin/sh

print_usage_then_exit () {
	echo "">&2;
	echo "Usage: $0 <arguments>">&2;
	echo "--port <string>">&2;
	echo "Optional: --port-label <string>">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_then_exit; fi

PORT="";

while true; do
	case $1 in
		--port)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -E '^-')" != "" ]; then
				print_usage_then_exit;
			else
				PORT=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "Unrecognised argument - ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z "$PORT" ]; then
	printf "$0: you must provide a port. (number between 1 and 65535)\n">&2;
	exit 2;
fi

if [ "$(echo "$PORT" | cut -d '-' -f 1)" = "$PORT" ]; then
	#not a range
	if [ -z "$(echo "$PORT" | grep -P '[0-9]{1,5}')" ]; then
		printf "$0: port is not a number.\n">&2;
		exit 1;
	fi

	if [ "$PORT" -lt 1 ]; then
		printf "$0: port is too low.\n">&2;
		exit 1;
	fi

	if [ "$PORT" -gt 65535 ]; then
		printf "$0: port is too high.\n">&2;
		exit 1;
	fi
else
	#a port range
	PORT_RANGE_START=$(echo "$PORT" | cut -d '-' -f 1);

	if [ -z "$(echo "$PORT_RANGE_START" | grep -P '[0-9]{1,5}')" ]; then
		printf "$0: port range lower bound is not a number.\n">&2;
		exit 1;
	fi

	if [ "$PORT_RANGE_START" -lt 1 ]; then
		printf "$0: port range start is too low.\n">&2;
		exit 1;
	fi

	if [ "$PORT_RANGE_START" -gt 65535 ]; then
		printf "$0: port range start is too high.\n">&2;
		exit 1;
	fi

	PORT_RANGE_END=$(echo "$PORT" | cut -d '-' -f 2);

	if [ -z "$(echo "$PORT_RANGE_END" | grep -P '[0-9]{1,5}')" ]; then
		printf "$0: port range end is not a number.\n">&2;
		exit 1;
	fi

	if [ "$PORT_RANGE_END" -lt 1 ]; then
		printf "$0: port range end is too low.\n">&2;
		exit 1;
	fi

	if [ "$PORT_RANGE_END" -gt 65535 ]; then
		printf "$0: port range end is too high.\n">&2;
		exit 1;
	fi
fi

exit 0;
