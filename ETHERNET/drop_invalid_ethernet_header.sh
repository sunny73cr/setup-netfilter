#!/bin/sh

#TODO: extend ethernet header validation.

echo "\t\t#Check the Destination MAC Address is not 0";
echo "\t\tether saddr 0 \\";

echo "\t\t#Check the Source MAC Address is not 0";
echo "\t\tether daddr 0 \\";

exit 0;
