#!/bin/sh

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
echo "\t\t#TCP FIN unset";
echo "\t\t@th,111,1 0 \\";
