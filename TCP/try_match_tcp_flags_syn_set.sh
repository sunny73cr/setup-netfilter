#!/bin/sh

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
echo "\t\t#TCP SYN set";
echo "\t\t@th,110,1 1 \\";
