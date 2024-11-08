#!/bin/sh

echo "\t\tether type != 0x0800 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - Ethertype is not 0x0800 (IPV4) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\t@nh,0,4 != 4 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IP version is not 4 - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\t@nh,4,4 < 5 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 header length is too small - invalid packet - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\t@nh,4,4 > 5 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 header length is too large - may contain options - \" \\";
echo "\t\tdrop;";
echo "";

#Differentiated Services Code Point
# CS0 = 0
# CS1 = 8
# CS2 = 16
# CS3 = 24
# CS4 = 32
# CS5 = 40
# CS6 = 48
# CS7 = 56
# AF11 = 10
# AF12 = 12
# AF13 = 14
# AF21 = 18
# AF22 = 20
# AF23 = 22
# AF31 = 26
# AF32 = 28
# AF33 = 30
# AF41 = 34
# AF42 = 36
# AF43 = 38
# EF = 46
# VOICE-ADMIT = 44
#echo "\t\t@nh,8,6 56 \\";
#echo "\t\tlog level warn \\";
#echo "\t\tlog prefix \"DROP - IPV4 DSCP is CS7 - Reserved for future use- \" \\";
#echo "\t\tdrop;";
#echo "";

#ECN
# 00 or 0 Not-ECT
# 01 or 1 ECN Capable Transport
# 10 or 2 ECN Capable Transport
# 11 or 3 Congestion Experienced
#echo "\t\t@nh,14,2 0 \\";
#echo "\t\tlog level warn \\";
#echo "\t\tlog prefix \"DROP - IPV4 DSCP is CS7 - Reserved for future use- \" \\";
#echo "\t\tdrop;";
#echo "";

echo "\t\t@nh,16,16 < 160 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 frame appears to be missing content - \" \\";
echo "\t\tdrop;";
echo "";
#
#	Not worth checking? Netfilter manpages states that packets processed through GRO/GSO exceeding max length will be 0
#
#echo "\t\t@nh,16,16 < 160 \\";
#echo "\t\tlog level warn \\";
#echo "\t\tlog prefix \"DROP - IPV4 total length is- \" \\";
#echo "\t\tdrop;";
#echo "";

echo "\t\t@nh,32,16 = 0 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IP identification is 0 - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\t@nh,48,1 != 0 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 invalid flags - bit 0 must be 0 - \" \\";
echo "\t\tdrop;";
echo "";

#'Dont fragment' bit
#echo "\t\t@nh,49,1 0 \\";
#echo "\t\t#log level warn \\";
#echo "\t\t#log prefix \"DROP - IPV4 Flags - Don't fragment bit set/unset - \" \\";
#echo "\t\t#drop;";

#'More fragments' bit
#echo "\t\t@nh,50,1 0 \\";
#echo "\t\t#log level warn \\";
#echo "\t\t#log prefix \"DROP - IPV4 Flags - More fragments bit set/unset - \" \\";
#echo "\t\t#drop;";

#'Dont fragment' bit
echo "\t\t@nh,49,1 1 \\";
#'More fragments' bit
echo "\t\t@nh,50,1 1 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 Invalid Flags - DF and MF combined - \" \\";
echo "\t\tdrop;";
echo "";

#'Dont fragments' bit set
echo "\t\t@nh,49,1 1 \\";
#'Fragment offset' is not 0
echo "\t\t@nh,51,13 != 0 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 Invalid Fragment - More Fragments is set, and Fragment offset is 0 - \" \\";
echo "\t\tdrop;";
echo "";

#'More fragments' bit set
echo "\t\t@nh,50,1 1 \\";
#'Fragment offset' is 0
echo "\t\t@nh,51,13 0 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 Invalid Fragment - More Fragments is set, and Fragment offset is 0 - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\t@nh,64,8 0 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 invalid TTL - TTL is 0 and the packet has died. - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\t@nh,80,16 0 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 Checksum is 0 - \" \\";
echo "\t\tdrop;";

#Source Address offset = 96, length 32.
#Destination Address offset = 128, length 32.
#Options Offset 160, length ?

exit 0;
