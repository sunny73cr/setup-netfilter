#!/bin/sh

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
echo "\t\t#TCP PSH unset";
echo "\t\t@th,108,1 0 \\";
