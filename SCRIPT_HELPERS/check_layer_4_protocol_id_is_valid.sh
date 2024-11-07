#!/bin/sh

#Source: https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml

print_usage_then_exit () {
	printf "Usage: $0 <arguments>\n">&2
	printf " --id <number>\n">&2;
	printf "\n">&2
	exit 2;
}

ID="";

if [ "$1" = "" ]; then print_usage_then_exit; fi

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
		*) printf "Unrecognised argumemt $1. ">&2; print_usage_then_exit; ;;
	esac
done

#!/bin/sh

if [ -z "$ENV_SETUP_NFT" ]; then printf "setup-netfilter: set ENV_SETUP_NFT to the root path of the setup-netfilter directory before continuing.\n">&2; exit 4; fi

print_description() {
	printf "A program that checks if a given Layer 4 protocol ID is valid.\n">&2;
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
	printf "Flags used by themselves: \n">&2;
	printf " -e (prints an explanation of the functions' purpose) (exit code 2)\n">&2
	printf " -h (prints an explanation of the functions' available parameters, and their effect) (exit code 2)\n">&2;
	printf " -d (prints the functions' dependencies: newline delimited list) (exit code 2)\n">&2;
	printf " -ehd (prints the above three) (exit code 2)\n">&2;
	printf "\n">&2;
	printf "Parameters:\n">&2;
	printf "\n">&2;
	printf " Required: --id x (where x is 0-255)\n">&2;
	printf "  The ID of the layer 4 protocol.\n">&2;
	printf "\n">&2;
	printf " Optional: --skip-validation\n">&2;
	printf "  Presence of this flag causes the program to skip validating inputs (if you know they are valid).\n">&2;
	printf "\n">&2;
	printf " Optional: --only-validate\n">&2;
	printf "  Presence of this flag causes the program to exit after validating inputs.\n">&2;
	printf "\n">&2;
}

print_usage_then_exit() {
	print_usage;
	exit 2;
}

if [ "$1" = "-h" ]; then print_usage_then_exit; fi

if [ "$1" = "-ehd" ]; then print_description; printf "\n">&2; print_dependencies; printf "\n">&2; print_usage; exit 2; fi

#ARGUMENTS:
ID="";

#FLAGS:
SKIP_VALIDATION=0;
ONLY_VALIDATE=0;

while true; do
	case $1 in
		#Approach to parsing arguments:
		#If the length of 'all arguments' is less than 2 (shift reduces this number),
		#since this is an argument parameter and requires a value; the program cannot continue.
		#Else, if the argument was provided, and its 'value' is empty; the program cannot continue.
		#Else, assign the argument, and shift 2 (both the argument indicator and its value / move next)

		--id)
			if [ $# -lt 2 ]; then
				printf "\nNot enough arguments (value for $1 is missing.) ">&2;
				print_usage_then_exit;
			elif [ -z "$2" ]; then
				printf "\nNot enough arguments (value for $1 is empty.) ">&2;
				print_usage_then_exit;
			else
				ID=$2;
				shift 2;
			fi
		;;

		#Approach to parsing flags:
		#If the flag was provided, toggle on its value; then move next
		#Or shift 1 / remove the flag from the list

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

if [ $SKIP_VALIDATION -eq 0 ]; then
	if [ -z "$ID" ]; then
		printf "\nMissing --id. ">&2;
		print_usage_then_exit;
	fi

	if [ -z "$(echo $ID | grep '[0-9]\{1,3\}')" ]; then
		printf "\nInvalid --id. ">&2;
		print_usage_then_exit;
	fi
fi

if [ $ONLY_VALIDATE -eq 1 ]; then exit 0; fi

case "$ID" in
	0) exit 1; ;; #HOPOPT / IPV6 Hop By Hop Option
	1) exit 0; ;; #ICMP
	2) exit 0; ;; #IGMP / Internet Group Management Protocol
	3) exit 1; ;; #GGP / Gateway to Gateway
	4) exit 1; ;; #IPV4 Encapsulation
	5) exit 1; ;; #ST / Stream
	6) exit 0; ;; #TCP
	7) exit 1; ;; #CBT
	8) exit 1; ;; #EGP / Exterior Gateway Protocol
	9) exit 1; ;; #IGP / Internet Gateway Protocol / Cisco IGRP
	10) exit 1; ;; #BBN RCC Monitoring
	11) exit 1; ;; #NVP / Network Voice Protocol
	12) exit 1; ;; #PUP
	13) exit 1; ;; #ARGUS
	14) exit 1; ;; #EMCON
	15) exit 1; ;; #XNET / Cross Network Debugger
	16) exit 1; ;; #CHAOS
	17) exit 0; ;; #UDP
	18) exit 1; ;; #MUX / Multiplexing
	19) exit 1; ;; #DCN-MEAS / DNC Measurment Subsystems
	20) exit 1; ;; #HMP / Host Monitoring Protocol
	21) exit 1; ;; #PRM / Packet Radio Measurement
	22) exit 1; ;; #XNS-IDP / Xerox NS IDP
	23) exit 1; ;; #TRUNK-1
	24) exit 1; ;; #TRUNK-2
	25) exit 1; ;; #LEAF-1
	26) exit 1; ;; #LEAF-2
	27) exit 1; ;; #RDP / Reliable Data Protocol
	28) exit 1; ;; #IRTP / Internet Reliable Transaction
	29) exit 1; ;; #ISO-TP4 / ISO Transport Protocol Class 4
	30) exit 1; ;; #NETBLT / Bulk Data Transfer Protocol
	31) exit 1; ;; #MFE-NSP / MFE Network Services Protocol
	32) exit 1; ;; #MERIT-INP / MERIT Internodal Protocol
	33) exit 1; ;; #DCCP / Datagram Congestion Control Protocol
	34) exit 1; ;; #3PC / Third Part Connect Protocol
	35) exit 1; ;; #IDPR / Inter-Domain Policy Routing Protocol
	36) exit 1; ;; #XTP
	37) exit 1; ;; #DDP / Datagram Delivery Protocol
	38) exit 1; ;; #IDPR-CMTP / IDPR Control Message Transport Protocol
	39) exit 1; ;; #TP++ / TP++ Transport Protocol
	40) exit 1; ;; #IL / IL Transport Protocol
	41) exit 1; ;; #IPV6 Encapsulation
	42) exit 1; ;; #SRDP / Source Demand Routing Protocol
	43) exit 1; ;; #IPV6-Route / Routing Header for IPV6
	44) exit 1; ;; #IPV6-Frag / Fragment Header for IPV6
	45) exit 1; ;; #IDRP / Inter-Domain Routing Protocol
	46) exit 1; ;; #RSVP / Reservation Protocol
	47) exit 1; ;; #GRE / Generic Routing Encapsulation
	48) exit 1; ;; #DSR / Dynamic Source Routing Protocol
	49) exit 1; ;; #BNA
	50) exit 1; ;; #ESP / Encapsulation Security Protocol
	51) exit 1; ;; #AH / Authentication Header
	52) exit 1; ;; #I-NLSP / Integrated Net Layer Security TUBA
	53) exit 1; ;; #SWIPE
	54) exit 1; ;; #NARP / NMBA Address Resolution Protocol
	55) exit 1; ;; #Min-IPV4 / Minimal IPV4 Encapsulation Protocol
	56) exit 1; ;; #TLSP / Transport Layer Security Protocol using Kryptonet key management
	57) exit 1; ;; #SKIP
	58) exit 1; ;; #IPV6-ICMP / ICMP for IPV6
	59) exit 1; ;; #IPV6-NoNxt / No Next Header for IPV6
	60) exit 1; ;; #IPV6-Opts / Destination Options for IPV6
	61) exit 1; ;; #any host internal protocol
	62) exit 1; ;; #CFTP
	63) exit 1; ;; #any local network
	64) exit 1; ;; #SAT-EXPAK / SATNET and Backroom EXPAK
	65) exit 1; ;; #KRYPTOLAN
	66) exit 1; ;; #RVD / MIT Remote Virtual Disk Protocol
	67) exit 1; ;; #IPPC / Internet Pluribus Packet Core
	68) exit 1; ;; #any distributed file system
	69) exit 1; ;; #SAT-MON / SATNET Monitoring
	70) exit 1; ;; #VISA Protocol
	71) exit 1; ;; #IPCV / Internet Packet Core Utility
	72) exit 1; ;; #CPNX / Computer Protocol Network Executive
	73) exit 1; ;; #CPHB / Computer Protocol Heartbeat
	74) exit 1; ;; #WSP / Wang Span Network
	75) exit 1; ;; #PVP / Packet Video Protocol
	76) exit 1; ;; #BR-SAT-MON / Backroom SATNET Monitoring
	77) exit 1; ;; #SUN-ND / SUN ND Protocol - Temporary
	78) exit 1; ;; #WB-MON / Wideband Monitoring
	79) exit 1; ;; #WB-EXPAK / WIDEBAND EXPAK
	80) exit 1; ;; #ISO-IP / ISO Internet Protocol
	81) exit 1; ;; #VMTP
	82) exit 1; ;; #Secure-VMTP
	83) exit 1; ;; #VINES
	84) exit 1; ;; #IPTM / Internet Protocol Traffic Manager
	85) exit 1; ;; #NSFNET-IGP
	86) exit 1; ;; #DGP / Dissimilar Gateway Protocol
	87) exit 1; ;; #TCF
	88) exit 1; ;; #EIGRP
	89) exit 1; ;; #OSPFIGP
	90) exit 1; ;; #Sprite RPC Protocol
	91) exit 1; ;; #LARP / Locus Address Resolution Protocol
	92) exit 1; ;; #MTP / Multicast Transport Protocol
	93) exit 1; ;; #AX.25 Frames
	94) exit 1; ;; #IPIP / IP-within-IP Encapsulation Protocol
	95) exit 1; ;; #MICP / Mobile Internetworkking Control Protocol
	96) exit 1; ;; #SCC-SP / Semaphore Communications Secure Protocol
	97) exit 1; ;; #ETHERIP / Ethernet within IP encapsulation protocol
	98) exit 1; ;; #ENCAP / Encapsulation Header
	99) exit 1; ;; #any private encryption scheme
	100) exit 1; ;; #GMTP
	101) exit 1; ;; #IFMP / Ipsilon Flow Management Protocol
	102) exit 1; ;; #PNNI / PNNI over IP
	103) exit 1; ;; #PIM / Protocol Independent Multicast
	104) exit 1; ;; #ARIS
	105) exit 1; ;; #SCPS
	106) exit 1; ;; #QNX
	107) exit 1; ;; #A/N or Active Networks
	108) exit 1; ;; #IPComp / IP Payload Compression Protocol
	109) exit 1; ;; #SNP / Sierra Networks Protocol
	110) exit 1; ;; #Compaq-Peer / Compaq Peer Protocol
	111) exit 1; ;; #IPX-in-IP
	112) exit 1; ;; #VRRP / Virtual Router Redundancy Protocol
	113) exit 1; ;; #PGM / PGM Reliable Transport Protocol
	114) exit 1; ;; #any 0-hop protocol
	115) exit 1; ;; #L2TP / Layer 2 Tunelling Protocol
	116) exit 1; ;; #DDX / D-II Data Exchange
	117) exit 1; ;; #IATP / Interactive Agent Trasfer Protocol
	118) exit 1; ;; #STP / Schedule Transfer Protocol
	119) exit 1; ;; #SRP / SepctraLink Radio Protocol
	120) exit 1; ;; #UTI
	121) exit 1; ;; #SMP / Simple Message Protocol
	122) exit 1; ;; #SM / Simple Multicast Protocol
	123) exit 1; ;; #PTP / Performance Transparency Protocol
	124) exit 1; ;; #ISIS over IPV4
	125) exit 1; ;; #FIRE
	126) exit 1; ;; #CRTP / Combat Radio Transport Protocol
	127) exit 1; ;; #CRUDP / Combat Radio User Datagram
	128) exit 1; ;; #SSCOPMCE
	129) exit 1; ;; #IPLT
	130) exit 1; ;; #SPS / Secure Packet Shield
	131) exit 1; ;; #PIPE / Private IP Encapsulation Within IP
	132) exit 1; ;; #SCTP / Stream Control Transmission Protocol
	133) exit 1; ;; #FC / Fibre Channel
	134) exit 1; ;; #RSVP-E2E-IGNORE
	135) exit 1; ;; #Mobility Header
	136) exit 1; ;; #UDP-Lite
	137) exit 1; ;; #MPLS-in-IP
	138) exit 1; ;; #manet / MANET Protocols
	139) exit 1; ;; #HIP / Host Identity Protocol
	140) exit 1; ;; #Shim6 Protocol
	141) exit 1; ;; #WESP / Wrapped Encapsulation Security Payload
	142) exit 1; ;; #ROHC / Robust Header Compression
	143) exit 1; ;; #Ethernet
	144) exit 1; ;; #AGGFRAG / AGGFRAG encapsulation payload for ESP
	145) exit 1; ;; #NSH / Network Service Header
	146) exit 1; ;; #Unassigned
	147) exit 1; ;; #Unassigned
	148) exit 1; ;; #Unassigned
	149) exit 1; ;; #Unassigned
	150) exit 1; ;; #Unassigned
	151) exit 1; ;; #Unassigned
	152) exit 1; ;; #Unassigned
	153) exit 1; ;; #Unassigned
	154) exit 1; ;; #Unassigned
	155) exit 1; ;; #Unassigned
	156) exit 1; ;; #Unassigned
	157) exit 1; ;; #Unassigned
	158) exit 1; ;; #Unassigned
	159) exit 1; ;; #Unassigned
	160) exit 1; ;; #Unassigned
	161) exit 1; ;; #Unassigned
	162) exit 1; ;; #Unassigned
	163) exit 1; ;; #Unassigned
	164) exit 1; ;; #Unassigned
	165) exit 1; ;; #Unassigned
	166) exit 1; ;; #Unassigned
	167) exit 1; ;; #Unassigned
	168) exit 1; ;; #Unassigned
	169) exit 1; ;; #Unassigned
	170) exit 1; ;; #Unassigned
	171) exit 1; ;; #Unassigned
	172) exit 1; ;; #Unassigned
	173) exit 1; ;; #Unassigned
	174) exit 1; ;; #Unassigned
	175) exit 1; ;; #Unassigned
	176) exit 1; ;; #Unassigned
	177) exit 1; ;; #Unassigned
	178) exit 1; ;; #Unassigned
	179) exit 1; ;; #Unassigned
	180) exit 1; ;; #Unassigned
	181) exit 1; ;; #Unassigned
	182) exit 1; ;; #Unassigned
	183) exit 1; ;; #Unassigned
	184) exit 1; ;; #Unassigned
	185) exit 1; ;; #Unassigned
	186) exit 1; ;; #Unassigned
	187) exit 1; ;; #Unassigned
	188) exit 1; ;; #Unassigned
	199) exit 1; ;; #Unassigned
	200) exit 1; ;; #Unassigned
	201) exit 1; ;; #Unassigned
	202) exit 1; ;; #Unassigned
	203) exit 1; ;; #Unassigned
	204) exit 1; ;; #Unassigned
	205) exit 1; ;; #Unassigned
	206) exit 1; ;; #Unassigned
	207) exit 1; ;; #Unassigned
	208) exit 1; ;; #Unassigned
	209) exit 1; ;; #Unassigned
	210) exit 1; ;; #Unassigned
	211) exit 1; ;; #Unassigned
	212) exit 1; ;; #Unassigned
	213) exit 1; ;; #Unassigned
	214) exit 1; ;; #Unassigned
	215) exit 1; ;; #Unassigned
	216) exit 1; ;; #Unassigned
	217) exit 1; ;; #Unassigned
	218) exit 1; ;; #Unassigned
	219) exit 1; ;; #Unassigned
	220) exit 1; ;; #Unassigned
	221) exit 1; ;; #Unassigned
	222) exit 1; ;; #Unassigned
	223) exit 1; ;; #Unassigned
	224) exit 1; ;; #Unassigned
	225) exit 1; ;; #Unassigned
	226) exit 1; ;; #Unassigned
	227) exit 1; ;; #Unassigned
	228) exit 1; ;; #Unassigned
	229) exit 1; ;; #Unassigned
	230) exit 1; ;; #Unassigned
	231) exit 1; ;; #Unassigned
	232) exit 1; ;; #Unassigned
	233) exit 1; ;; #Unassigned
	234) exit 1; ;; #Unassigned
	235) exit 1; ;; #Unassigned
	236) exit 1; ;; #Unassigned
	237) exit 1; ;; #Unassigned
	238) exit 1; ;; #Unassigned
	239) exit 1; ;; #Unassigned
	240) exit 1; ;; #Unassigned
	241) exit 1; ;; #Unassigned
	242) exit 1; ;; #Unassigned
	243) exit 1; ;; #Unassigned
	244) exit 1; ;; #Unassigned
	245) exit 1; ;; #Unassigned
	246) exit 1; ;; #Unassigned
	247) exit 1; ;; #Unassigned
	248) exit 1; ;; #Unassigned
	249) exit 1; ;; #Unassigned
	250) exit 1; ;; #Unassigned
	251) exit 1; ;; #Unassigned
	252) exit 1; ;; #Unassigned
	253) exit 1; ;; #Experimentation and testing
	254) exit 1; ;; #Experimentation and testing
	255) exit 1; ;; #Reserved
	*)		 #Unknown
		printf "\nInvalid --id. \n\n">&2;
		printf "Refer to: https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml\n\n">&2;
		printf "It may be that a protocol was added. It is currently unsupported. Please contact the maintainer for support.\n\n">&2
		print_usage_then_exit;
	;;
esac

exit 0;
