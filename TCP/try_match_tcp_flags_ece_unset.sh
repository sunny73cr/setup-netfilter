#!/bin/sh

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
echo "\t\t#TCP ECE unset";
echo "\t\t@th,105,1 0 \\";
