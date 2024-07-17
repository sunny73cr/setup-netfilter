#!/bin/sh

usage () {
	echo "">&2;
	echo "Usage: $0 <arguments>">&2;
	echo "--port <string>">&2;
	echo "Optional: --port-label <string>">&2;
	exit 2;
}

PORT="";

if [ "$1" = "" ]; then usage; fi

while true; do
	case "$1" in
		--port )
			PORT="$2";
			#if not enough arguments
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		--port-label)
			PORT_LABEL="$2";
			#if not enough arguments
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		"" ) break; ;;
		*)
			echo "">&2;
			echo "Unrecognised option: $1 $2">&2;
			usage;
		;;
	esac
done

if [ -z "$PORT" ]; then
	if [ -n "$PORT_LABEL" ]; then
		echo "$0; you must provide a $PORT_LABEL port (--port <number>).">&2;
	else
		echo "$0; you must provide a port (--port <number>).">&2;
	fi
	exit 2;
fi

if [ "$(echo "$PORT" | cut -d '-' -f 1)" = "$PORT" ]; then
	#not a range
	if [ -z "$(echo "$PORT" | grep -P '[0-9]+')" ]; then
		if [ -n "$PORT_LABEL" ]; then
			echo "$0; $PORT_LABEL port is not a number.">&2;
		else
			echo "$0; port is not a number.">&2;
		fi
		exit 2;
	fi

	if [ "$PORT" -lt 1 ]; then
		if [ -n "$PORT_LABEL" ]; then
			echo "$0; $PORT_LABEL port is not in range.">&2;
		else
			echo "$0; port is not in range.">&2;
		fi
		exit 2;
	fi

	if [ "$PORT" -gt 65535 ]; then
		if [ -n "$PORT_LABEL" ]; then
			echo "$0; $PORT_LABEL port is not in range.">&2;
		else
			echo "$0; port is not in range.">&2;
		fi
		exit 2;
	fi
else
	#a port range
	PORT_RANGE_START=$(echo "$PORT" | cut -d '-' -f 1);
	
	if [ -z "$(echo "$PORT_RANGE_START" | grep -P '[0-9]+')" ]; then
		if [ -n "$PORT_LABEL" ]; then
			echo "$0; $PORT_LABEL port range start is not a number.">&2;
		else
			echo "$0; port range start is not a number.">&2;
		fi
		exit 2;
	fi

	if [ "$PORT_RANGE_START" -lt 1 ]; then
		if [ -n "$PORT_LABEL" ]; then
			echo "$0; $PORT_LABEL port range start is not a port number.">&2;
		else
			echo "$0; port range start is not a port number.">&2;
		fi
		exit 2;
	fi

	if [ "$PORT_RANGE_START" -gt 65535 ]; then
		if [ -n "$PORT_LABEL" ]; then
			echo "$0; $PORT_LABEL port range start is not a port number.">&2;
		else
			echo "$0; port range start is not a port number.">&2;
		fi
		exit 2;
	fi
	
	PORT_RANGE_END=$(echo "$PORT" | cut -d '-' -f 2);

	if [ -z "$(echo "$PORT_RANGE_END" | grep -P '[0-9]+')" ]; then
		if [ -n "$PORT_LABEL" ]; then
			echo "$0; $PORT_LABEL port range end is not a number.">&2;
		else
			echo "$0; port range end is not a number.">&2;
		fi
		exit 2;
	fi

	if [ "$PORT_RANGE_END" -lt 1 ]; then
		if [ -n "$PORT_LABEL" ]; then
			echo "$0; $PORT_LABEL port range end is not a port number.">&2;
		else
			echo "$0; port range end is not a port number.">&2;
		fi
		exit 2;
	fi

	if [ "$PORT_RANGE_END" -gt 65535 ]; then
		if [ -n "$PORT_LABEL" ]; then
			echo "$0; $PORT_LABEL port range end is not a port number.">&2;
		else
			echo "$0; port range end is not a port number.">&2;
		fi
		exit 2;
	fi
fi

exit 0;
