#!/bin/sh

#ICMP (RFC792)
#IP Header size 160 bits
#ICMP Header size 64 bits
echo "\t\tip protocol 1 \\";
echo "\t\tip length < 224 \\";
echo "\t\tlog level emerg \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP packet is too small - invalid packet - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 8 \\";
echo "\t\ticmp code != 0 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Echo Request invalid code - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 0 \\";
echo "\t\ticmp code != 0 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Echo Reply invalid code - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 1 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 1 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 2 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 2 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 3 \\";
echo "\t\ticmp code != { 0, 1, 2, 3, 4, 5 } \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Destination Unreachable invalid code - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 4 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Source Quence (deprecated protocol) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 5 \\";
echo "\t\ticmp code != { 0, 1, 2, 3 }";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Redirect invalid code - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 6 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 6 (deprecated protocol) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 7 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 7 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 9 \\";
echo "\t\ticmp code 0 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Router Advertisement invalid code - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 10 \\";
echo "\t\ticmp code 0 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Router Solicitation invalid code - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 11 \\";
echo "\t\ticmp code != { 0, 1 } \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Time Exceeded invalid code - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 12 \\";
echo "\t\ticmp code != 0 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Parameter Problem invalid code - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 13 \\";
echo "\t\ticmp code != 0 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Timestamp Request invalid code - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 14 \\";
echo "\t\ticmp code != 0 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Timestamp Reply invalid code - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 15 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Information Request (deprecated protocol) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 16 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Information Reply (deprecated protocol) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 17 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Address Mask Request (deprecated protocol) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 18 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Address Mask Reply (deprecated protocol) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 19 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 19 (reserved for security) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 20 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 20 (reserved for robustness experiment) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 21 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 21 (reserved for robustness experiment) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 22 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 22 (reserved for robustness experiment) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 23 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 23 (reserved for robustness experiment) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 24 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 24 (reserved for robustness experiment) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 25 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 25 (reserved for robustness experiment) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 26 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 26 (reserved for robustness experiment) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 27 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 27 (reserved for robustness experiment) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 28 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 28 (reserved for robustness experiment) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 29 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 29 (reserved for robustness experiment) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 30 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Traceoute (deprecated protocol) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 31 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 31 (deprecated) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 32 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 32 (deprecated) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 33 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 33 (deprecated) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 34 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 34 (deprecated) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 35 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 35 (deprecated) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 36 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 36 (deprecated) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 37 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 37 (deprecated) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 38 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 38 (deprecated) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 39 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 39 (deprecated) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 40 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 40 (deprecated) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 41 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 41 (deprecated) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 42 \\";
echo "\t\ticmp code != 0";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Extended Echo Request (invalid code) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 43 \\";
echo "\t\ticmp code != { 0, 1, 2, 3, 4 } \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Extended Echo Reply (invalid code) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 44 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 44 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 45 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 45 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 46 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 46 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 47 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 47 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 48 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 48 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 49 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 49 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 50 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 50 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 51 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 51 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 52 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 52 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 53 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 53 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 54 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 54 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 55 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 55 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 56 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 56 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 57 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 57 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 58 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 58 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 59 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 59 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 60 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 60 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 61 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 61 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 62 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 62 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 63 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 63 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 64 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 64 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 65 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 65 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 66 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 66 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 67 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 67 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 68 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 68 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 69 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 69 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 70 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 70 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 71 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 71 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 72 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 72 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 73 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 73 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 74 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 74 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 75 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 75 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 76 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 76 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 77 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 77 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 78 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 78 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 79 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 79 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 80 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 80 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 81 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 81 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 82 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 82 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 83 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 83 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 84 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 84 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 85 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 85 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 86 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 86 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 87 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 87 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 88 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 88 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 89 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 89 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 90 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 90 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 91 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 91 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 92 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 92 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 93 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 93 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 94 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 94 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 95 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 95 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 96 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 96 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 97 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 97 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 98 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 98 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 99 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 99 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 100 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 100 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 101 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 101 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 102 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 102 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 103 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 103 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 104 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 104 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 105 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 105 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 106 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 106 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 107 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 107 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 108 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 108 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 109 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 109 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 110 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 110 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 111 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 111 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 112 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 112 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 113 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 113 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 114 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 114 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 115 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 115 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 116 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 116 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 117 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 117 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 118 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 118 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 119 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 119 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 120 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 120 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 121 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 121 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 122 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 122 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 123 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 123 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 124 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 124 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 125 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 125 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 126 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 126 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 127 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 127 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 128 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 128 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 129 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 129 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 130 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 130 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 131 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 131 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 132 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 132 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 133 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 133 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 134 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 134 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 135 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 135 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 136 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 136 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 137 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 137 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 138 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 138 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 139 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 139 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 140 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 140 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 141 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 141 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 142 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 142 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 143 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 143 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 144 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 144 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 145 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 145 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 146 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 146 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 147 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 147 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 148 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 148 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 149 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 149 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 150 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 150 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 151 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 151 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 152 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 152 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 153 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 153 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 154 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 154 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 155 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 155 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 156 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 156 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 157 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 157 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 158 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 158 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 159 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 159 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 160 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 160 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 161 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 161 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 162 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 162 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 163 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 163 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 164 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 164 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 165 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 165 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 166 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 166 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 167 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 167 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 168 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 168 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 169 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 169 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 170 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 170 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 171 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 171 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 172 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 172 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 173 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 173 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 174 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 174 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 175 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 175 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 176 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 176 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 177 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 177 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 178 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 178 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 179 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 179 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 180 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 180 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 181 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 181 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 182 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 182 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 183 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 183 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 184 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 184 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 185 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 185 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 186 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 186 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 187 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 187 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 188 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 188 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 189 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 189 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 190 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 190 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 191 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 191 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 192 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 192 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 193 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 193 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 194 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 194 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 195 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 195 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 196 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 196 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 197 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 197 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 198 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 198 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 199 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 199 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 200 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 200 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 201 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 201 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 202 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 202 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 203 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 203 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 204 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 204 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 205 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 205 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 206 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 206 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 207 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 207 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 208 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 208 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 209 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 209 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 210 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 210 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 211 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 211 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 212 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 212 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 213 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 213 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 214 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 214 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 215 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 215 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 216 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 216 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 217 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 217 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 218 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 218 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 219 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 219 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 220 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 220 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 221 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 221 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 222 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 222 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 223 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 223 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 224 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 224 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 225 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 225 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 226 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 226 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 227 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 227 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 228 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 228 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 229 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 229 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 230 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 230 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 231 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 231 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 232 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 232 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 233 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 233 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 234 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 234 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 235 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 235 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 236 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 236 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 237 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 237 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 238 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 238 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 239 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 239 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 240 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 240 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 241 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 241 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 242 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 242 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 243 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 243 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 244 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 244 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 245 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 245 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 246 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 246 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 247 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 247 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 248 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 248 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 249 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 249 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 250 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 250 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 251 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 251 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 252 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 252 (reserved type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 253 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 253 (experimental type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 254 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 254 (experimental type) - \" \\";
echo "\t\tdrop;";
echo "";

echo "\t\tip protocol 1 \\";
echo "\t\ticmp type 255 \\";
echo "\t\tlog level warn \\";
echo "\t\tlog prefix \"DROP - IPV4 ICMP Type 255 (reserved type) - \" \\";
echo "\t\tdrop;";

exit 0;
