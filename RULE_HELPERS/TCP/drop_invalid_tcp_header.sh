#!/bin/sh

DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_CWR_SET="./TCP/match_tcp_flags_cwr_set.sh";
if [ ! -x $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_CWR_SET ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_CWR_SET\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_CWR_UNSET="./TCP/match_tcp_flags_cwr_unset.sh";
if [ ! -x $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_CWR_UNSET ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_CWR_UNSET\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ECE_SET="./TCP/match_tcp_flags_ece_set.sh";
if [ ! -x $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ECE_SET ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ECE_SET\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ECE_UNSET="./TCP/match_tcp_flags_ece_unset.sh";
if [ ! -x $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ECE_UNSET ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ECE_UNSET\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_URG_SET="./TCP/match_tcp_flags_urg_set.sh";
if [ ! -x $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_URG_SET ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_URG_SET\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_URG_UNSET="./TCP/match_tcp_flags_urg_unset.sh";
if [ ! -x $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_URG_UNSET ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_URG_UNSET\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ACK_SET="./TCP/match_tcp_flags_ack_set.sh";
if [ ! -x $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ACK_SET ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ACK_SET\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ACK_UNSET="./TCP/match_tcp_flags_ack_unset.sh";
if [ ! -x $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ACK_UNSET ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ACK_UNSET\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_PSH_SET="./TCP/match_tcp_flags_psh_set.sh";
if [ ! -x $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_PSH_SET ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_PSH_SET\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_PSH_UNSET="./TCP/match_tcp_flags_psh_unset.sh";
if [ ! -x $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_PSH_UNSET ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_PSH_UNSET\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_RST_SET="./TCP/match_tcp_flags_rst_set.sh";
if [ ! -x $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_RST_SET ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_RST_SET\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_RST_UNSET="./TCP/match_tcp_flags_rst_unset.sh";
if [ ! -x $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_RST_UNSET ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_RST_UNSET\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_SYN_SET="./TCP/match_tcp_flags_syn_set.sh";
if [ ! -x $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_SYN_SET ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_SYN_SET\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_SYN_UNSET="./TCP/match_tcp_flags_syn_unset.sh";
if [ ! -x $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_SYN_UNSET ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_SYN_UNSET\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_FIN_SET="./TCP/match_tcp_flags_fin_set.sh";
if [ ! -x $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_FIN_SET ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_FIN_SET\" is missing or is not executable." 1>&2;
	exit 3;
fi

DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_FIN_UNSET="./TCP/match_tcp_flags_fin_unset.sh";
if [ ! -x $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_FIN_UNSET ]; then
	echo "$0; script dependency failure: \"$DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_FIN_UNSET\" is missing or is not executable." 1>&2;
	exit 3;
fi

echo "\t\tip protocol 6 \\";
echo "\t\ttcp sport 0 \\";
echo "\t\tlog level emerg \\";
echo "\t\tlog prefix \"DROP - IPV4 TCP Source Port 0 - invalid packet - \" \\";
echo "\t\tdrop;";

echo "";

echo "\t\tip protocol 6 \\";
echo "\t\ttcp dport 0 \\";
echo "\t\tlog level emerg \\";
echo "\t\tlog prefix \"DROP - IPV4 TCP Destination Port 0 - invalid packet - \" \\";
echo "\t\tdrop;";

echo "";

echo "\t\tip protocol 6 \\";
echo "\t\ttcp doff < 5 \\";
echo "\t\tlog level emerg \\";
echo "\t\tlog prefix \"DROP - IPV4 TCP header is too small - invalid packet - \" \\";
echo "\t\tdrop;";

echo "";

echo "\t\tip protocol 6 \\";
echo "\t\t#TCP Reserved bits";
echo "\t\t@th,100,4 != 0 \\";
echo "\t\tlog level emerg \\";
echo "\t\tlog prefix \"DROP - IPV4 TCP reserved bits not 0 - invalid packet - \" \\";
echo "\t\tdrop;";

echo "";

echo "\t\tip protocol 6 \\";
echo "\t\t#All flags set";
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_CWR_SET;
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ECE_SET;
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_URG_SET;
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ACK_SET;
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_PSH_SET;
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_RST_SET;
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_SYN_SET;
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_FIN_SET;
echo "\t\tlog level emerg \\";
echo "\t\tlog prefix \"DROP - IPV4 TCP All flags set - invalid packet - \" \\";
echo "\t\tdrop;";

echo "";

echo "\t\tip protocol 6 \\";
echo "\t\t#No flags set";
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_CWR_UNSET;
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ECE_UNSET;
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_URG_UNSET;
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ACK_UNSET;
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_PSH_UNSET;
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_RST_UNSET;
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_SYN_UNSET;
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_FIN_UNSET;
echo "\t\tlog level emerg \\";
echo "\t\tlog prefix \"DROP - IPV4 TCP no flags set - invalid packet - \" \\";
echo "\t\tdrop;";

echo "";

echo "\t\tip protocol 6 \\";
echo "\t\tct state new \\";
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_SYN_UNSET;
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 TCP SYN unset for new connection - invalid packet - \" \\";
echo "\t\tdrop;";

echo "";

echo "\t\tip protocol 6 \\";
echo "\t\tct state established \\";
echo "\t\ttcp sequence 0 \\";
echo "\t\tlog level emerg \\";
echo "\t\tlog prefix \"DROP - IPV4 TCP sequence number 0 for existing connection - invalid packet - \" \\";
echo "\t\tdrop;";

echo "";

echo "\t\tip protocol 6 \\";
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ACK_SET;
echo "\t\ttcp ackseq = 0 \\";
echo "\t\tlog level emerg \\";
echo "\t\tlog prefix \"DROP - IPV4 TCP ACK flag set but ACK number is 0 - invalid packet - \" \\";
echo "\t\tdrop;";

echo "";

echo "\t\tip protocol 6 \\";
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_RST_SET;
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ACK_SET;
echo "\t\tlog level emerg \\";
echo "\t\tlog prefix \"DROP - IPV4 TCP RST combined with ACK - invalid packet - \" \\";
echo "\t\tdrop;";

echo "";

echo "\t\tip protocol 6 \\";
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_RST_SET;
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_URG_SET;
echo "\t\tlog level emerg \\";
echo "\t\tlog prefix \"DROP - IPV4 TCP RST combined with URG - invalid packet - \" \\";
echo "\t\tdrop;";

echo "";

echo "\t\tip protocol 6 \\";
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_RST_SET;
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_FIN_SET;
echo "\t\tlog level emerg \\";
echo "\t\tlog prefix \"DROP - IPV4 TCP RST combined with FIN - invalid packet - \" \\";
echo "\t\tdrop;";

echo "";

echo "\t\tip protocol 6 \\";
echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_URG_SET;
echo "\t\t#URG pointer is null";
echo "\t\ttcp urgptr 0 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 TCP URG flag set but URG pointer is null - invalid packet - \" \\";
echo "\t\tdrop;";

echo "";

echo "\t\tip protocol 6 \\";
echo "\t\ttcp window 0 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 TCP Window size empty  - invalid packet- \" \\";
echo "\t\tdrop;";

echo "";

echo "\t\tip protocol 6 \\";
echo "\t\ttcp checksum 0 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 TCP Checksum empty  - invalid packet- \" \\";
echo "\t\tdrop;";

echo "";

#echo "\t\tip protocol 6 \\";
#echo "\t\tct state established \\";
#echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ACK_SET;
#echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ECE_SET;
#echo "\t\tlog level audit \\";
#echo "\t\tlog prefix \"IPV4 TCP ACK,ECE- \" \\";
#echo "\t\tcontinue;";

#echo "";

#echo "\t\tip protocol 6 \\";
#echo "\t\tct state established \\";
#echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_ACK_SET;
#echo $DEPENDENCY_SCRIPT_PATH_TCP_FLAGS_CWR_SET;
#echo "\t\tlog level audit \\";
#echo "\t\tlog prefix \"IPV4 TCP ACK,CWR- \" \\";
#echo "\t\tcontinue;"

echo "";

#RFC791 Section 3.1 IP Header minimum size 160 bits (excluding IP options)
#RFC9293 Section 3.1 TCP header minimum size is 160 bits (excluding TCP options) 
echo "\t\tip protocol 6 \\";
echo "\t\tip length < 320 \\";
echo "\t\tlog level emerg \\";
echo "\t\tlog prefix \"DROP - IPV4 TCP packet is too small - invalid packet - \" \\";
echo "\t\tdrop;";

exit 0;
