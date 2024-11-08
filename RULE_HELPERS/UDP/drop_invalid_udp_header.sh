#!/bin/sh

#UDP (RFC768)
#Header size 64 bits
echo "\t\tip protocol 17 \\";
echo "\t\tip length < 224 \\";
echo "\t\tlog level emerg \\";
echo "\t\tlog prefix \"DROP - IPV4 UDP packet is too small - invalid packet- \" \\";
echo "\t\tdrop;";

echo "";

echo "\t\tip protocol 17 \\";
echo "\t\tudp sport 0 \\";
echo "\t\tlog level emerg \\";
echo "\t\tlog prefix \"DROP - IPV4 UDP Source port 0 - invalid packet- \" \\";
echo "\t\tdrop;";

echo "";

echo "\t\tip protocol 17 \\";
echo "\t\tudp dport 0 \\";
echo "\t\tlog level emerg \\";
echo "\t\tlog prefix \"DROP - IPV4 UDP Destination port 0 - invalid packet- \" \\";
echo "\t\tdrop;";

echo "";

echo "\t\tip protocol 17 \\";
echo "\t\tudp length < 8 \\";
echo "\t\tlog level emerg \\";
echo "\t\tlog prefix \"DROP - IPV4 UDP packet is too small - invalid packet- \" \\";
echo "\t\tdrop;";

echo "";

echo "\t\tip protocol 17 \\";
echo "\t\tudp checksum 0 \\";
echo "\t\tlog level emerg \\";
echo "\t\tlog prefix \"DROP - IPV4 UDP Checksum 0 - invalid packet- \" \\";
echo "\t\tdrop;";
