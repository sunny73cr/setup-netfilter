#!/bin/sh

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
echo "\t\t#TCP URG unset";
echo "\t\t@th,106,1 0 \\";
