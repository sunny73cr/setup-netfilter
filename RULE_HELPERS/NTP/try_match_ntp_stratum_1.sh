#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

DEPENDENCY_PATH_VALIDATE_SERVICE_ID="$ENV_SETUP_NFT/SCRIPT_HELPERS/check_service_user_id_is_valid.sh";

if [ ! -x $DEPENDENCY_PATH_VALIDATE_SERVICE_ID ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_VALIDATE_SERVICE_ID\" is missing or is not executable.\n">&2;
	exit 3;
fi

DEPENDENCY_PATH_CONVERT_ASCII_TO_DECIMAL="$ENV_SETUP_NFT/SCRIPT_HELPERS/convert_ascii_to_decimal.sh";

if [ ! -x $DEPENDENCY_PATH_CONVERT_ASCII_TO_DECIMAL ]; then
	printf "$0: dependency: \"$DEPENDENCY_PATH_CONVERT_ASCII_TO_DECIMAL\" is missing or is not executable.\n">&2;
	exit 3;
fi

print_description() {
	printf "A program that prints part of an NFT rule 'match' section. The match intends to match NTP Stratum 1 packets.\n">&2;
}

print_description_then_exit() {
	print_description;
	exit 2;
}

if [ "$1" = "-e" ]; then print_description_then_exit; fi

print_dependencies() {
	printf "Dependencies: \n">&2;
	printf "printf\n">&2;
	printf "echo\n">&2;
	printf "date\n">&2;
	printf "$DEPENDENCY_PATH_VALIDATE_SERVICE_ID\n">&2;
	printf "$DEPENDENCY_PATH_CONVERT_ASCII_TO_DECIMAL\n">&2;
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
	printf " -e (prints an explanation of the functions' purpose.) (exit code 2)\n">&2;
	printf " -h (prints an explanation of the functions' available parameters, and their effect) (exit code 2)\n">&2;
	printf " -d (prints the functions' dependencies; newline delimited list) (exit code 2)\n">&2;
	printf " -ehd (prints the above three)\n">&2;
	printf "\n">&2;
	printf "Parameters:\n">&2;
	printf "\n">&2;
	printf " Required: --type request|response\n">&2;
	printf "  this controls the packet direction. Clients make requests, and servers make responses.\n">&2;
	printf "\n">&2;
	printf " Optional: --service-user-id x (where x is 1-65535)\n">&2;
	printf "  this relates to an entry in /etc/passwd\n">&2;
	printf "  without this restrictions, NTP Stratum 2 packets are permitted into any service.\n">&2;
	printf "\n">&2;
	printf " Optional: --leap-indicator none|59|61|unsync\n">&2;
	printf "  typically none or unsync(hronised). 59 indicates today is a short day, and 61 indicates today is a long day.\n">&2;
	printf "\n">&2;
	printf " Optional: --network-type bad-wan|wan|man|lan\n">&2;
	printf "  this provides hints to the script where --root-delay-range or --root-dispersion-range is not provided.\n">&2;
	printf "  the default is 'wan'.\n">&2;
	printf "  it assumes the maximum root delay/dispersion should be: bad-wan=400ms, wan=60ms, man=15ms, lan=5ms\n">&2;
	printf "\n">&2;
	printf " Optional: --root-delay-range x-x (where x is 0-1000 milliseconds)\n">&2;
	printf "  The total round-trip delay to the reference clock, including transmission of a request, receipt of a response, plus total dispersion, plus peer jitter.\n">&2;
	printf "\n">&2;
	printf " Optional: --root-dispersion-range x-x (where x is 0-1000 milliseconds)\n">&2;
	printf "  The total dispersion to the reference clock\n">&2;
	printf "\n">&2;
	printf " you cannot provide both --root-delay-range and --network-type, or --root-dispersion-range and --network-type\n">&2;
	printf "\n">&2;
	printf " The --root-delay is (hopefully), less than or equal to the average response time of most small-packet tranmissions within a network.">&2;
	printf " For a typical response time, three cases exist:\n">&2;
	printf "  1. Within the local network\n">&2;
	printf "  2. Within a 'larger' local network (University, Larger Organisation)\n">&2;
	printf "  3. Within the 'Internet'; where NTP servers are 'remote'\n">&2;
	printf " accurate analysis of an appropriate root delay requires a long form speedtest; it would be better to assume a typical 'maximum' and stick with that.\n">&2;
	printf " this is out of scope for the project, and typical latency can change over time, and with network conditions.\n">&2;
	printf " the ('safe-enough') default maximum root dispersion is:\n">&2;
	printf " ~400ms for old (or slow) (WAN) networks; like satellite or cell tower networks.\n">&2;
	printf " ~150ms for modern internet (WAN) networks (Large/Distributed 'Copper'/ADSL/VDSL networks)\n">&2;
	printf " ~30-60ms for an 'extra-modern' internet (WAN) network (Fibre/Sparsely populated 'Copper'/ADSL/VDSL).\n">&2;
	printf " ~5-15ms for a typical 'MAN' (University, large organisation, etc) network\n">&2;
	printf " ~<1-5ms for a local network.\n">&2;
	printf "\n">&2;
	printf " if the root dispersion is roughly equal to the root delay, and or latency of an NTP packet, your device may be sycnhronising with a NTP server that is itself synchronised to a distant peer in the wider network.\n">&2;
	printf " in this case, it is better to simply synchronise with the authoritative server, instead of that peer. The NTP algorithm may do this automatically.\n">&2;
	printf "\n">&2;
	printf " Optional: --reference-id (where x is one of the options following:)\n">&2;
	printf "  1. GOES - Geosynchronous Orbit Environment Satellite\n">&2;
	printf "  2. GPS - Global Positioning System\n">&2;
	printf "  3. PPS - Generic 'Pulse Per Second'\n">&2;
	printf "  4. GAL - Galileo Positioning System\n">&2;
	printf " ">&2;
	printf "  If the --enable-rare-clocks flag is enabled, these options are additionally available to match:">&2;
	printf "  It is unlikely that most people would choose to use one of the following, considering the likely available sources.">&2;
	printf "   5. DFM - UTC (DFM)\n">&2;
	printf "   6. IRIG - Inter-Range Instrumentation Group\n">&2;
	printf "   7. WWVB - Low Frequency Radio WWVB Fort Collins, CO 60KHz\n">&2;
	printf "   8. DCF - Low Frequency Radio DCF77 Manflingen, DE 77.5KHz\n">&2;
	printf "   9. HBG - Low Frequency Radio HBG Prangins, HB 75KHz\n">&2;
	printf "   10. MSF - Low Frequency Radio MSF Anthorn, UK 60KHz\n">&2;
	printf "   11. JJY - Low Frequency Radio JJY Fukushima, JP 40KHz\n">&2;
	printf "   12. LORC - Medium Frequency Radio LORAN C Station, 100KHz\n">&2;
	printf "   13. TDF - Medium Frequency Radio Allouis, FR 162KHz\n">&2;
	printf "   14. CHU - High Frequency Radio CHU Ottawa, Ontario\n">&2;
	printf "   15. WWV - High Frequency Radio WWV Ft. Collins, CO\n">&2;
	printf "   16. WWVH - High Frequency Radio WWVH Kauai, HI\n">&2;
	printf "   17. NIST - NIST Telephone Modem\n">&2;
	printf "   18. ACTS - NIST Telephone Modem\n">&2;
	printf "   19. UNSO - UNSO Telephone Modem\n">&2;
	printf "   20. PTB - European Telephone Modem\n">&2;
	printf "\n">&2;
	printf " Optional: --enable-rare-clocks\n">&2;
	printf "  Does what it says on the tin. Enable rarer clocks to match as reference IDs.\n">&2;
	printf "\n">&2;
	printf " Optional: --clock-is-synchronised\n">&2;
	printf "  this indicates that the Reference Timestamp of this synchronisation should be fairly close to the current date and time.\n">&2;
	printf "  This should assist in preventing a (poorly designed, yet) malicious network client from attempting to skew the clients' clock.\n">&2;
	printf "  In the case that your device cannot reach a legitimate NTP server, it will simply remain unsychronised; yet it will hold a more accurate time.\n">&2;
	printf "\n">&2;
	printf " Optional: --reference-timestamp-leniency x (where x is 0-512)\n">&2;
	printf "  this argument controls the leniency in seconds when matching reference timestamps that are skewed from the system clock.\n">&2;
	printf "  this leniency in seconds indicates the maxmimum allowable clock skew both before and after the current system time.\n">&2;
	printf "  if --reference-timestamp-leniency is 6; 3 seconds in the past or future is OK to accept.\n">&2;
	printf "  The default --reference-timestamp-leniency is 6.\n">&2;
	printf "  Due to the absence of floating point numbers, the leniency in seconds should be an even number.\n">&2;
	printf "  if the leniency in seconds is not even, the script will add one second in order to make it evenly divisible.\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf "  this flag causes the program to skip validating inputs (if you know they are valid.)\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validate\n">&2;
	printf "  this flag causes the program to exit after validating inputs.\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
REQUEST_OR_RESPONSE="";
SERVICE_UID="";
LEAP_INDICATOR="";
NETWORK_TYPE="";
ROOT_DELAY_RANGE="";
ROOT_DELAY_RANGE_BEGIN="";
ROOT_DELAY_RANGE_END="";
ROOT_DISPERSION_RANGE="";
ROOT_DISPERSION_RANGE_BEGIN="";
ROOT_DISPERSION_RANGE_END="";
REFERENCE_ID="";
REFERENCE_TIMESTAMP_LENIENCY=6;

#FLAGS:
ENABLE_RARE_CLOCKS=0;
CLOCK_IS_SYNCHRONISED=0;
SKIP_VALIDATION=0;
ONLY_VALIDATE=0;

while true; do
	case $1 in
		#Approach to parsing arguments:
		#If the length of 'all arguments' is less than 2 (shift reduces this number),
		#since this is an argument parameter and requires a value; the program cannot continue.
		#Else, if the argument was provided, and its 'value' is empty; the program cannot continue.
		#Else, assign the argument, and shift 2 (both the argument indicator and its value / move next)

		--type)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				REQUEST_OR_RESPONSE=$2;
				shift 2;
			fi
		;;

		--service-user-id)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				SERVICE_UID=$2;
				shift 2;
			fi
		;;

		--leap-indicator)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				LEAP_INDICATOR=$2;
				shift 2;
			fi
		;;

		--network-type)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				NETWORK_TYPE=$2;
				shift 2;
			fi
		;;

		--root-delay-range)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				ROOT_DELAY_RANGE=$2;
				shift 2;
			fi
		;;

		--root-dispersion-range)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				ROOT_DISPERSION_RANGE=$2;
				shift 2;
			fi
		;;

		--reference-id)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				REFERENCE_ID=$2;
				shift 2;
			fi
		;;

		--reference-timestamp-leniency)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				print_usage_then_exit;
			else
				REFERENCE_TIMESTAMP_LENIENCY=$2;
				shift 2;
			fi
		;;

		#Approach to parsing flags:
		#If the flag was provided, toggle on its value; then move next
		#Or shift 1 / remove the flag from the list

		--enable-rare-clocks)
			ENABLE_RARE_CLOCKS=1;
			shift 1;
		;;

		--clock-is-synchronised)
			CLOCK_IS_SYNCHRONISED=1;
			shift 1;
		;;

		--skip-validation)
			SKIP_VALIDATION=1;
			shift 1;
		;;

		--only-validate)
			ONLY_VALIDATE=1;
			shift 1;
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

#Why, user?
if [ $SKIP_VALIDATION -eq 1 ] && [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

if [ $SKIP_VALIDATION -eq 0 ]; then
	if [ -z "$REQUEST_OR_RESPONSE" ]; then
		printf "\nMissing --type. ">&2;
		print_usage_then_exit;
	fi

	case $REQUEST_OR_RESPONSE in
		request) ;;
		response) ;;
		*) printf "\nInvalid --type. ">&2; print_usage_then_exit; ;;
	esac

	if [ -n "$SERVICE_UID" ]; then
		$DEPENDENCY_PATH_VALIDATE_SERVICE_ID --id $SERVICE_UID;
		case $? in
			0) ;;
			1) printf "\nInvalid --service-user-id (Confirm the /etc/passwd entry). ">&2; print_usage_then_exit; ;;
			*) printf "$0: dependency \"$DEPENDENCY_PATH_VALIDATE_SERVICE_ID\" produced a failure exit code \"$?\".">&2; exit 3; ;;
		esac
	fi

	if [ -n "$LEAP_INDICATOR" ]; then
		case $LEAP_INDICATOR in
			none) ;;
			59) ;;
			61) ;;
			unsync) ;;
			*) printf "\nInvalid --leap-indicator. ">&2; print_usage_then_exit; ;;
		esac
	fi

	if [ -n "$NETWORK_TYPE" ] && [ -z "$ROOT_DELAY_RANGE" ]; then
		printf "\nInvalid combination of --network-type and --root-delay-range. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$NETWORK_TYPE" ] && [ -n "$ROOT_DISPERSION_RANGE" ]; then
		printf "\nInvalid combination of --network-type and --root-dispersion-range. ">&2;
		print_usage_then_exit;
	fi

	if [ -n "$NETWORK_TYPE" ]; then
		case $NETWORK_TYPE in
			bad-wan) ;;
			wan) ;;
			man) ;;
			lan) ;;
			*) printf "\nInvalid --network-type. ">&2; print_usage_then_exit; ;;
		esac
	fi

	if [ -n "$ROOT_DELAY_RANGE" ]; then
		if [ -z "$(echo $ROOT_DELAY_RANGE | grep '[]-')" ]; then
			printf "\nInvalid --root-delay-range (range must be delimited by a hyphen). ">&2;
			print_usage_then_exit;
		fi

		ROOT_DELAY_RANGE_BEGIN=$(echo $ROOT_DELAY_RANGE | cut -d '-' -f 1);

		if [ -z "$(echo $ROOT_DELAY_RANGE_BEGIN | grep '[0-9]\{1,4\}')" ]; then
			printf "\nInvalid --root-delay-range (first half is not a 1-4 digit number.) ">&2;
			print_usage_then_exit;
		fi

		ROOT_DELAY_RANGE_END=$(echo $ROOT_DELAY_RANGE | cut -d '-' -f 2);

		if [ -z "$(echo $ROOT_DELAY_RANGE_END | grep '[0-9]\{1,4\}')" ]; then
			printf "\nInvalid --root-delay-range (second half is not a 1-4 digit number.) ">&2;
			print_usage_then_exit;
		fi

		#Reorder if supplied backwards.
		if [ $ROOT_DELAY_RANGE_BEGIN -gt $ROOT_DELAY_RANGE_END ]; then
			TMP=$ROOT_DELAY_RANGE_BEGIN;
			ROOT_DELAY_RANGE_BEGIN=$ROOT_DELAY_RANGE_END;
			ROOT_DELAY_RANGE_END=$TMP;
		fi

		if [ $ROOT_DELAY_RANGE_BEGIN -lt 0 ]; then
			printf "\nInvalid --root-delay-range (beginning must be greater than or equal to 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $ROOT_DELAY_RANGE_BEGIN -gt 1000 ]; then
			printf "\nInvalid --root-delay-range (beginning must be less than or equal to 1000). ">&2;
			print_usage_then_exit;
		fi

		if [ $ROOT_DELAY_RANGE_END -lt 0 ]; then
			printf "\nInvalid --root-delay-range (end must be greater than or equal to 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $ROOT_DELAY_RANGE_END -gt 1000 ]; then
			printf "\nInvalid --root-delay-range (end must be less than or equal to 1000). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$ROOT_DISPERSION_RANGE" ]; then
		if [ -z "$(echo $ROOT_DISPERSION_RANGE | grep '-')" ]; then
			printf "\nInvalid --root-dispersion-range (range must be delimited by a hyphen). ">&2;
			print_usage_then_exit;
		fi

		ROOT_DISPERSION_RANGE_BEGIN=$(echo $ROOT_DISPERSION_RANGE | cut -d '-' -f 1);

		if [ -z "$(echo $ROOT_DISPERSION_RANGE_BEGIN | grep '[0-9]\{1,4\}')" ]; then
			printf "\nInvalid --root-dispersion-range (first half is not a 1-4 digit number.) ">&2;
			print_usage_then_exit;
		fi

		ROOT_DISPERSION_RANGE_END=$(echo $ROOT_DISPERSION_RANGE | cut -d '-' -f 2);

		if [ -z "$(echo $ROOT_DISPERSION_RANGE_END | grep '[0-9]\{1,4\}')" ]; then
			printf "\nInvalid --root-dispersion-range (second half is not a 1-4 digit number.) ">&2;
			print_usage_then_exit;
		fi

		#Reorder if supplied backwards.
		if [ $ROOT_DISPERSION_RANGE_BEGIN -gt $ROOT_DISPERSION_RANGE_END ]; then
			TMP=$ROOT_DISPERSION_RANGE_BEGIN;
			ROOT_DISPERSION_RANGE_BEGIN=$ROOT_DISPERSION_RANGE_END;
			ROOT_DISPERSION_RANGE_END=$TMP;
		fi

		if [ $ROOT_DISPERSION_RANGE_BEGIN -lt 0 ]; then
			printf "\nInvalid --root-dispersion-range (beginning must be greater than or equal to 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $ROOT_DISPERSION_RANGE_BEGIN -gt 1000 ]; then
			printf "\nInvalid --root-dispersion-range (beginning must be less than or equal to 1000). ">&2;
			print_usage_then_exit;
		fi

		if [ $ROOT_DISPERSION_RANGE_END -lt 0 ]; then
			printf "\nInvalid --root-dispersion-range (end must be greater than or equal to 0). ">&2;
			print_usage_then_exit;
		fi

		if [ $ROOT_DISPERSION_RANGE_END -gt 1000 ]; then
			printf "\nInvalid --root-dispersion-range (end must be less than or equal to 1000). ">&2;
			print_usage_then_exit;
		fi
	fi

	if [ -n "$REFERENCE_ID" ]; then
		case $REFERENCE_ID in
			GOES|GPS|PPS|GAL) ;;
			DFM|IRIG|WWVB|DCF|HBG|MSF|JJY|LORC|TDF|CHU|WWV|WWVH|NIST|ACTS|UNSO|PTB)
				if [ $ENABLE_RARE_CLOCKS -eq -0 ]; then
					printf "\nForbidden --reference-id. Please set the flag --enable-rare-clocks. ">&2;
					print_usage_then_exit;
				fi
			;;
			*) printf "\nInvalid --reference-id. ">&2; print_usage_then_exit; ;;
		esac
	fi

	if [ -n "$REFERENCE_TIMESTAMP_LENIENCY" ]; then
		if [ -z "$(echo $REFERENCE_TIMESTAMP_LENIENCY | grep '[0-9]\{1,3\}')" ]; then
			printf "\nInvalid --reference-timestamp-leniency (must be a 1-3 digit number). ">&2;
			print_usage_then_exit;
		fi

		if [ $REFERENCE_TIMESTAMP_LENIENCY -lt 0 ]; then
			printf "\nInvalid --reference-timestamp-leniency (must be 0 or greater). ">&2;
			print_usage_then_exit;
		fi

		if [ $REFERENCE_TIMESTAMP_LENIENCY -gt 512 ]; then
			printf "\nInvalid --reference-timestamp-leniency (must be 512 or less). ">&2;
			print_usage_then_exit;
		fi
	fi
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

REFERENCE_ID_DECIMAL="";
if [ -n "$REFERENCE_ID" ]; then
	#These values were generated by $ENV_SETUP_NFT/SCRIPT_HELPERS/convert_ascii_to_decimal.sh
	case $REFERENCE_ID in
		GOES) REFERENCE_ID_DECIMAL=1196377427; ;;
		GPS) REFERENCE_ID_DECIMAL=1196446464; ;;
		PPS) REFERENCE_ID_DECIMAL=1347441408; ;;
		DFM) REFERENCE_ID_DECIMAL=1145457920; ;;
		GAL) REFERENCE_ID_DECIMAL=1195461632; ;;
		IRIG) REFERENCE_ID_DECIMAL=1230129479; ;;
		WWVB) REFERENCE_ID_DECIMAL=1465341506; ;;
		DCF) REFERENCE_ID_DECIMAL=1145259520; ;;
		HBG) REFERENCE_ID_DECIMAL=1212303104; ;;
		MSF) REFERENCE_ID_DECIMAL=1297303040; ;;
		JJY) REFERENCE_ID_DECIMAL=1246386432; ;;
		LORC) REFERENCE_ID_DECIMAL=1280266819; ;;
		TDF) REFERENCE_ID_DECIMAL=1413760512; ;;
		CHU) REFERENCE_ID_DECIMAL=1128813824; ;;
		WWV) REFERENCE_ID_DECIMAL=1465341440; ;;
		WWVH) REFERENCE_ID_DECIMAL=1465341512; ;;
		NIST) REFERENCE_ID_DECIMAL=1313428308; ;;
		ACTS) REFERENCE_ID_DECIMAL=1094931539; ;;
		UNSO) REFERENCE_ID_DECIMAL=1431196495; ;;
		PTB) REFERENCE_ID_DECIMAL=1347699200; ;;
	esac
fi

#If validation was skipped, be sure to extract root delay range begin and end
if [ $SKIP_VALIDATION -eq 1 ] && [ -n "$ROOT_DELAY_RANGE" ]; then
	if [ -n "$(echo $ROOT_DELAY_RANGE | grep '[0-9]\{1,4\}-[0-9]\{1,4\}')" ]; then
		ROOT_DELAY_RANGE_BEGIN=$(echo $ROOT_DELAY_RANGE | cut -d '-' -f 1);
		ROOT_DELAY_RANGE_END=$(echo $ROOT_DELAY_RANGE | cut -d '-' -f 2);
	fi
fi

#If validation was skipped, be sure to extract root dispersion range begin and end
if [ $SKIP_VALIDATION -eq 1 ] && [ -n "$ROOT_DISPERSION_RANGE" ]; then
	if [ -n "$(echo $ROOT_DISPERSION_RANGE | grep '[0-9]\{1,4\}-[0-9]\{1,4\}')" ]; then
		ROOT_DISPERSION_RANGE_BEGIN=$(echo $ROOT_DISPERSION_RANGE | cut -d '-' -f 1);
		ROOT_DISPERSION_RANGE_END=$(echo $ROOT_DISPERSION_RANGE | cut -d '-' -f 2);
	fi
fi

if [ -n "$SERVICE_UID" ]; then
	printf "\\t#Match Service User ID\n";
	printf "\\t\\tmeta skuid $SERVICE_UID \\\\\n";
else
	printf "\\t#Service User ID is unrestricted - confirm the security implications.\n";
fi

OFFSET_MARKER="ih";
BIT_OFFSET_PACKET_BEGIN=0;
BIT_OFFSET_LEAP_INDICATOR=$BIT_OFFSET_PACKET_BEGIN;
BIT_OFFSET_VERSION=$(($BIT_OFFSET_LEAP_INDICATOR+2));
BIT_OFFSET_MODE=$(($BIT_OFFSET_VERSION+3));
BIT_OFFSET_STRATUM=$(($BIT_OFFSET_MODE+3));
BIT_OFFSET_POLL=$(($BIT_OFFSET_STRATUM+8));
BIT_OFFSET_PRECISION=$(($BIT_OFFSET_POLL+8));
BIT_OFFSET_ROOT_DELAY=$(($BIT_OFFSET_PRECISION+8));
BIT_OFFSET_ROOT_DELAY_FRACTION=$(($BIT_OFFSET_ROOT_DELAY+16));
BIT_OFFSET_ROOT_DISPERSION=$(($BIT_OFFSET_ROOT_DELAY_FRACTION+16));
BIT_OFFSET_ROOT_DISPERSION_FRACTION=$(($BIT_OFFSET_ROOT_DISPERSION+16));
BIT_OFFSET_REFERENCE_ID=$(($BIT_OFFSET_ROOT_DISPERSION_FRACTION+16));
BIT_OFFSET_REFERENCE_TIMESTAMP=$(($BIT_OFFSET_REFERENCE_ID+32));
BIT_OFFSET_ORIGIN_TIMESTAMP=$(($BIT_OFFSET_REFERENCE_TIMESTAMP+64));
BIT_OFFSET_RECEIVE_TIMESTAMP=$(($BIT_OFFSET_ORIGIN_TIMESTAMP+64));
BIT_OFFSET_TRANSMIT_TIMESTAMP=$(($BIT_OFFSET_RECEIVE_TIMESTAMP+64));
BIT_OFFSET_EXTENSION_FIELD_1=$(($BIT_OFFSET_TRANSMIT_TIMESTAMP+64));

if [ -n "$LEAP_INDICATOR" ]; then
	case $LEAP_INDICATOR in
		none)
			printf "\\t#Match Leap Indicator (0 - no leap)\n";
			printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_LEAP_INDICATOR,2 0 \\\\\n";
		;;
		59)
			printf "\\t#Match Leap Indicator (1 - todays last minute is 59secs)\n";
			printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_LEAP_INDICATOR,2 1 \\\\\n";
		;;
		61)
			printf "\\t#Match Leap Indicator (2 - todays last minute is 61secs)\n";
			printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_LEAP_INDICATOR,2 2 \\\\\n";
		;;
		unsync)
			printf "\\t#Match Leap Indicator (3 - clock unsynchronised)\n";
			printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_LEAP_INDICATOR,2 3 \\\\\n";
		;;
	esac
else
	printf "\\t#Leap Indicator is unrestricted.\n";
fi

printf "\\t#Match NTP Version 4\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_VERSION,3 4 \\\\\n";

printf "\\t#Match NTP Mode";
case $REQUEST_OR_RESPONSE in
	request)
		printf " (3 - client request)\n";
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_MODE,3 3 \\\\\n";
	;;
	response)
		printf " (4 - server response)\n";
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_MODE,3 4 \\\\\n";
	;;
esac

printf "\\t#Match NTP Stratum from 2 to 16\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_STRATUM,8 > 1 \\\\\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_STRATUM,8 < 17 \\\\\n";

printf "\\t#Match NTP Poll (Suggested 5-10) 32sec-1024sec, each level is doubled:\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_POLL,8 > 4 \\\\\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_POLL,8 < 11 \\\\\n";

printf "\\t#Match NTP Precision (Suggested -3 to -16) 125ms-0.0152ms, each level is halved:\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_PRECISION,8 < -3 \\\\\n";
printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_PRECISION,8 > -16 \\\\\n";

printf "\\t#Match NTP Maximum Root Delay ";
if [ -n "$ROOT_DELAY_RANGE_BEGIN" ] || [ -n "$ROOT_DELAY_RANGE_END" ]; then
	if [ -n "$ROOT_DELAY_RANGE_BEGIN" ] && [ -n "$ROOT_DELAY_RANGE_END" ]; then
		printf "(${ROOT_DELAY_RANGE_BEGIN}-${ROOT_DELAY_RANGE_END}ms)\n";
	elif [ -n "$ROOT_DELAY_RANGE_BEGIN" ]; then
		printf "(minimum $ROOT_DELAY_RANGE_BEGIN)\n";
	elif [ -n "$ROOT_DELAY_RANGE_END" ]; then
		printf "(maximum $ROOT_DELAY_RANGE_END)\n";
	fi

	if [ -n "$ROOT_DELAY_RANGE_BEGIN" ]; then
		#fractions= (milliseconds * 1000) / 65536
		ROOT_DELAY_RANGE_BEGIN_FRACTION=$(($ROOT_DELAY_RANGE_BEGIN*65536/1000));
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ROOT_DELAY_FRACTION,16 >= $ROOT_DELAY_RANGE_BEGIN_FRACTION \\\\\n";
	fi
	if [ -n "$ROOT_DELAY_RANGE_END" ]; then
		#fractions= (milliseconds * 1000) / 65536
		ROOT_DELAY_RANGE_END_FRACTION=$(($ROOT_DELAY_RANGE_END*65536/1000));
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ROOT_DELAY_FRACTION,16 <= $ROOT_DELAY_RANGE_END_FRACTION \\\\\n";
	fi
else
	if [ -z "$NETWORK_TYPE" ]; then
		NETWORK_TYPE="wan";
	fi
	ROOT_DELAY_MAX_FRACTION=0;
	case $NETWORK_TYPE in
		bad-wan)
			printf "(maximum 400ms).\n";
			ROOT_DELAY_MAX_FRACTION=$((400*65536/1000));
		;;
		wan)
			printf "(maximum 60ms).\n";
			ROOT_DELAY_MAX_FRACTION=$((60*65536/1000));
		;;
		man)
			printf "(maximum 15ms).\n";
			ROOT_DELAY_MAX_FRACTION=$((15*65536/1000));
		;;
		lan)
			printf "(maximum 5ms).\n";
			ROOT_DELAY_MAX_FRACTION=$((5*65536/1000));
		;;
	esac

	printf "\\t#Seconds:\n";

	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ROOT_DELAY,16 0 \\\\\n";

	printf "\\t#Fractions:\n";

	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ROOT_DELAY_FRACTION,16 <= $ROOT_DELAY_MAX_FRACTION \\\\\n";
fi

printf "\\t#Match NTP Maximum Root Dispersion ";
if [ -n "$ROOT_DISPERSION_RANGE_BEGIN" ] || [ -n "$ROOT_DISPERSION_RANGE_END" ]; then
	if [ -n "$ROOT_DISPERSION_RANGE_BEGIN" ] && [ -n "$ROOT_DISPERSION_RANGE_END" ]; then
		printf "(${ROOT_DISPERSION_RANGE_BEGIN}-${ROOT_DISPERSION_RANGE_END}ms)\n";
	elif [ -n "$ROOT_DISPERSION_RANGE_BEGIN" ]; then
		printf "(minimum $ROOT_DISPERSION_RANGE_BEGIN)\n";
	elif [ -n "$ROOT_DISPERSION_RANGE_END" ]; then
		printf "(maximum $ROOT_DISPERSION_RANGE_END)\n";
	fi

	if [ -n "$ROOT_DISPERSION_RANGE_BEGIN" ]; then
		#fractions= (milliseconds * 1000) / 65536
		ROOT_DISPERSION_RANGE_BEGIN_FRACTION=$(($ROOT_DISPERSION_RANGE_BEGIN*65536/1000));
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ROOT_DISPERSION_FRACTION,16 >= $ROOT_DISPERSION_RANGE_BEGIN_FRACTION \\\\\n";
	fi
	if [ -n "$ROOT_DISPERSION_RANGE_END" ]; then
		#fractions= (milliseconds * 1000) / 65536
		ROOT_DISPERSION_RANGE_END_FRACTION=$(($ROOT_DISPERSION_RANGE_END*65536/1000));
		printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ROOT_DISPERSION_FRACTION,16 <= $ROOT_DISPERSION_RANGE_END_FRACTION \\\\\n";
	fi
else
	if [ -z "$NETWORK_TYPE" ]; then
		NETWORK_TYPE="wan";
	fi
	ROOT_DISPERSION_MAX_FRACTION=0;
	case $NETWORK_TYPE in
		bad-wan)
			printf "(maximum 400ms).\n";
			ROOT_DISPERSION_MAX_FRACTION=$((400*65536/1000));
		;;
		wan)
			printf "(maximum 60ms).\n";
			ROOT_DISPERSION_MAX_FRACTION=$((60*65536/1000));
		;;
		man)
			printf "(maximum 15ms).\n";
			ROOT_DISPERSION_MAX_FRACTION=$((15*65536/1000));
		;;
		lan)
			printf "(maximum 5ms).\n";
			ROOT_DISPERSION_MAX_FRACTION=$((5*65536/1000));
		;;
	esac

	printf "\\t#Seconds:\n";

	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ROOT_DISPERSION,16 0 \\\\\n";

	printf "\\t#Fractions:\n";

	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_ROOT_DISPERSION_FRACTION,16 <= $ROOT_DISPERSION_MAX_FRACTION \\\\\n";
fi

if [ -n "$REFERENCE_ID_DECIMAL" ]; then
	printf "\\t#Match NTP Reference ID ($REFERENCE_ID)\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_REFERENCE_ID,32 $REFERENCE_ID_DECIMAL \\\\\n";
fi

if [ $CLOCK_IS_SYNCHRONISED -eq 1 ]; then
	CURRENT_DATE_SECONDS_FROM_EPOCH=$(date +'%s');
	LENIENCY_SECONDS=6;
	if [ -n "$REFERENCE_TIMESTAMP_LENIENCY" ]; then
		LENIENCY_SECONDS=$REFERENCE_TIMESTAMP_LENIENCY;
	fi
	#If not divisible by 2, increment by 1.
	if [ $(($LENIENCY_SECONDS%2)) -ne 0 ]; then
		LENIENCY_SECONDS=$(($LENIENCY_SECONDS+1));
	fi
	#Leniency is both forward and backward from the current distance from the epoch
	LENIENCY_SECONDS=$(($LENIENCY_SECONDS/2));

	CURRENT_DATE_SECONDS_FROM_EPOCH_LOWER_BOUND=$(($CURRENT_DATE_SECONDS_FROM_EPOCH-$LENIENCY_SECONDS));
	DATETIME_LOWER_FRIENDLY=$(date -d "@$CURRENT_DATE_SECONDS_FROM_EPOCH_LOWER_BOUND" +'%c');
	CURRENT_DATE_SECONDS_FROM_EPOCH_UPPER_BOUND=$(($CURRENT_DATE_SECONDS_FROM_EPOCH+$LENIENCY_SECONDS));
	DATETIME_UPPER_FRIENDLY=$(date -d "@$CURRENT_DATE_SECONDS_FROM_EPOCH_UPPER_BOUND" +'%c');

	printf "\\t#Match NTP Reference Timestamp ${DATETIME_LOWER_FRIENDLY} - ${DATETIME_UPPER_FRIENDLY}\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_REFERENCE_TIMESTAMP,32 >= $CURRENT_DATE_SECONDS_FROM_EPOCH_LOWER_BOUND \\\\\n";
	printf "\\t\\t@$OFFSET_MARKER,$BIT_OFFSET_REFERENCE_TIMESTAMP,32 <= $CURRENT_DATE_SECONDS_FROM_EPOCH_UPPER_BOUND \\\\\n";
else
	printf "\\t#NTP Reference Timestamp is unrestricted - clock unsynchronised - consider the security implications.\n";
fi

#printf "\\t#Match NTP Origin Timestamp\n";
#printf "\\t\\t@ih,192,64  \\\\\n";

#printf "\\t#Match NTP Receive Timestamp\n";
#printf "\\t\\t@ih,256,64  \\\\\n";

#printf "\\t#Match NTP Transmit Timestamp\n";
#printf "\\t\\t@ih,320,64  \\\\\n";

exit 0;
