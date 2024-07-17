#!/bin/sh

DEPENDENCY_SCRIPT_PATH_HELP_SETUP_NETFILTER="./help.sh";

if [ ! -x "$DEPENDENCY_SCRIPT_PATH_HELP_SETUP_NETFILTER" ]; then
	echo "$0; dependency script path \"$DEPENDENCY_SCRIPT_PATH_HELP_SETUP_NETFILTER\" is missing or is not executable.">&2;
	exit 3;
fi

#DEPENDENCIES:
#
#	echo
#	grep (-P Perl Regex)
#	cut
#	cat
#	ip
#	awk
#	printf
#	rm
#	touch
#	chmod (when applying the configuration file.)
#	sudo (when applying the configuration file.)
#	nft (when applying the configuration file.)
#

##########################################################
#		CONFGIURATION FILE DATA & HELPERS
##########################################################

IS_TEST_RUN="false";

#Find where we are
WORKING_DIR=$(pwd);

if [ -f $WORKING_DIR/nftables.conf.tmp ]; then
	#Clear the old workspace file
	rm $WORKING_DIR/nftables.conf.tmp;
	touch $WORKING_DIR/nftables.conf.tmp;
fi

save_lines () {
	while IFS= read -r line; do
		printf '%s\n' "$line" >> $WORKING_DIR/nftables.conf.tmp;
	done
}

apply () {
	sudo cat $WORKING_DIR/nftables.conf.tmp > /etc/nftables.conf;
	sudo chmod +x /etc/nftables.conf;
	sudo /etc/nftables.conf;
}

##########################################################

usage () {
	echo "">&2;
	echo "Usage: $0 <arguments>">&2;
	echo "\tArguments:">&2;
	echo "\t\t--help [scripts|configuration]">&2;
	echo "\t\tNote: Simply \"--help\" displays all help.">&2;
	echo "">&2;
	echo "\t\t--test-run">&2;
	echo "\t\tNote: --test-run generates the config file, but does not apply changes to NetFilter.">&2;
	echo "">&2;
	exit 2;
}

while true; do
	case "$1" in
		#display help
		--help)
			if [ "$2" = "" ]; then
				$DEPENDENCY_SCRIPT_PATH_HELP_SETUP_NETFILTER;
			else
				case "$2" in
					scripts) $($DEPENDENCY_SCRIPT_PATH_HELP_SETUP_NETFILTER scripts); ;;
					configuration) $($DEPENDENCY_SCRIPT_PATH_HELP_SETUP_NETFILTER configuration); ;;
				esac
			fi
			exit 2;
		;;
		--test-run)
			IS_TEST_RUN="true";
			shift;
		;;
		#no more arguments
		"") break; ;;
		#unrecognised argument
		*)
			echo "Unrecognised command: $1 $2";
			usage;
		;;
	esac
done

##########################################################
#		INTERFACE CONFIGURATION
##########################################################

#THIS_PC
LAN_TYPE="";
LAN_DESC="LAN";
LAN_DEV="eth0";
LAN_MAC="02:00:00:00:00:02";
LAN_VLAN_ID="";
LAN_IP="10.0.0.2";
LAN_NETWORK_CIDR="10.0.0.0/8";
LAN_MULTICAST_ADDRESS="10.255.255.255";

##########################################################
#		NETWORK CONFIGURATION
##########################################################

#Gateway
LAN_GWY_MAC="02:00:00:00:00:01";
LAN_GWY_IP4="10.0.0.1";

##########################################################
#		SERVICE PROCESS UIDS
##########################################################

SERVICE_UID_DHCP=$(./SCRIPT_HELPERS/get_user_id_by_name.sh --name "dhcpcd");
SERVICE_UID_NTP=$(./SCRIPT_HELPERS/get_user_id_by_name.sh --name "systemd-timesync");
SERVICE_UID_DNS=$(./SCRIPT_HELPERS/get_user_id_by_name.sh --name "systemd-resolve");
SERVICE_UID_SDNS=$(./SCRIPT_HELPERS/get_user_id_by_name.sh --name "systemd-resolve");
SERVICE_UID_APT=$(./SCRIPT_HELPERS/get_user_id_by_name.sh --name "_apt");

##########################################################
#		SERVICE NETWORK ENDPOINTS
##########################################################

PORT_ZERO="0";
PORT_SYSTEM="1-1023";
PORT_USER="1024-49151";
PORT_EPHEMERAL="49152-65535";

MACHINES_DHCP_SERVERS="$LAN_GWY_MAC;$LAN_GWY_IP4";
PORT_DHCP_CLIENT="67";
PORT_DHCP_SERVER="68";

MACHINES_NTP_SERVERS="$LAN_GWY_MAC;$LAN_GWY_IP4";
PORT_NTP_CLIENT="123";
PORT_NTP_SERVER="123";

MACHINES_DNS_SERVERS="$LAN_GWY_MAC;$LAN_GWY_IP4";
PORT_DNS_SERVER="53";

MACHINES_SDNS_SERVERS="$LAN_GWY_MAC;$LAN_GWY_IP4";
PORT_SDNS_SERVER="53";

MACHINES_APT_SERVERS="0.0.0.0";
PORT_APT_SERVER_HTTP="80";
PORT_APT_SERVER_HTTPS="443";

#################################################################################################################################################################
#		CONFIG FILE BEGIN																#
#################################################################################################################################################################
echo '#!/usr/sbin/nft -f' | save_lines;
echo "#Run this script through NFT (Netfilter) as a config file." | save_lines;
echo "#You can run ./setup_netfilter.sh with the --apply command to do so." | save_lines;
echo "" | save_lines;
echo "flush ruleset" | save_lines;
echo "#Clear the old ruleset." | save_lines;
echo "" | save_lines;

#################################################################################################################################################################
#		Netdev Loopback Ingress																#
#################################################################################################################################################################
add_line "table netdev tbl_lo_inet_ing_filter {";
add_line "\tchain chn_lo_inet_ing_filter {";
add_line "\t\ttype filter \\\\";
add_line "\t\thook ingress \\\\";
add_line "\t\tdevice lo \\\\";
add_line "\t\tpriority 0; \\\\";
add_line "\t\tpolicy accept; \\\\";
add_line "\t\tcomment \"Inbound Loopback Filter\";";
add_line "";
add_line "\t}";
add_line "}";

#################################################################################################################################################################
#		Netdev LAN Ingress																#
#################################################################################################################################################################
add_line "table netdev tbl_lan_netdev_ing {";
add_line "\tchain chn_lan_netdev_ing_filter {";
add_line "\t\ttype filter \\\\";
add_line "\t\thook ingress \\\\";
add_line "\t\tdevice $LAN_DEV \\\\";
add_line "\t\tpriority 5; \\\\";
add_line "\t\tpolicy drop; \\\\";
add_line "\t\tcomment \"Inbound Layer 2 Filter\";";
add_line "";

if [ "$ALLOW_MPLS_ECHO_REQUEST" = "false" ] && [ "$ALLOW_MPLS_ECHO_REPLY" = "false" ]; then
	#Allow loopback
fi
./BOGONS/IPV4/block_bogon_ipv4_network_loopback.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_network_empty_except_empty_address.sh --address-type "" | save_line;
#This address and network is covered by the above line. We are allowing it as a source to support DHCP discover/request/decline/release.
#./BOGONS/IPV4/block_bogon_ipv4_address_unspecified.sh --address-type "" | save_line;
#./BOGONS/IPV4/block_bogon_ipv4_network_unspecified.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_network_link_local.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_network_private_10.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_network_private_172_16.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_network_private_192_168.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_network_shared_100_64.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_network_multicast.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_address_broadcast.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_address_service_continuity.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_address_dummy.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_address_port_control_protocol_anycast.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_relay_nat_traversal_anycast.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_address_nat_64_discovery.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_address_dns_64_discovery.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_network_ietf_protocol_assignments.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_network_test_1.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_network_test_2.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_network_test_3.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_network_as112v4.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_network_as112v4_direct_delegation.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_network_amt.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_network_6to4_relay_anycast.sh --address-type "" | save_line;
./BOGONS/IPV4/block_bogon_ipv4_network_benchmarking.sh --address-type "" | save_line;

#	Block unspecified addresses, as there is no way to reply to them.
	block_bogon_mac_address_unspecified "SOURCE"
	
#	Block all unambiguous MAC address assignments.
#	(#2:##:##:##:##:##, #6:##:##:##:##:##, #A:##:##:##:##:##, #E:##:##:##:##:##)
	block_bogon_mac_address_private "SOURCE"

#	Multicast addresses are used as destinations.
	block_bogon_mac_address_multicast_ipv4 "SOURCE"

#	Multicast addresses are used as destinations.
	block_bogon_mac_address_multicast_ipv6 "SOURCE"

#	Broadcast should be used as destinations.
	block_bogon_mac_address_broadcast "SOURCE"

#	Block unspecified destination addresses, this is an invalid packet.
	block_bogon_mac_address_unspecified "DESTINATION"
	
#	Block all unambiguous MAC address assignments.
#	(#2:##:##:##:##:##, #6:##:##:##:##:##, #A:##:##:##:##:##, #E:##:##:##:##:##)
	block_bogon_mac_address_private "DESTINATION"
	
#	Block the MAC address range used alongside 'multicast IPV4' (240.0.0.0/4)
#	(I don't have a use for multicast DNS.)
	block_bogon_mac_address_multicast_ipv4 "DESTINATION"
	
#	Block the MAC address range used alongside 'multicast IPV6' (FF0X::)
#	(I don't wish to use IPv6 for now.)
	block_bogon_mac_address_multicast_ipv6 "DESTINATION"

#	Block the 'Broadcast' MAC destination.
	block_bogon_mac_address_broadcast "DESTINATION"
#
#	The broadcast MAC destination is required for:
#	ARP Probe
#	Gratuitous ARP Probe
#	DHCP Discover
#	DHCP Request
#	DHCP Decline
#
#	This was a choice made out of concern for network security.
#	ARP is prone to 'poisoning' attacks (or rather, impersonation)
#	DHCP has a poorly defined specification, and I'd like to avoid it if possible.
#
#	This means I'm required to configure each interface manually.

#If this interface has a VLAN attached, accept packets are wrapped in a VLAN tag.
if [ -n $LAN_VLAN_ID ]; then
	#add_line "\t\tether type 0x8100 vlan type 0x0806 accept";
	#add_line "";

	add_line "\t\tether type 0x8100 vlan type 0x0800 accept";
	#add_line "";

	# Block IPV6 for now.
	#add_line "\t\tether type 0x8100 vlan type 0x86DD accept";
#Otherwise, accept unwrapped packets.
else
	#add_line "\t\tether type 0x0806 accept";
	#add_line "";
	
	add_line "\t\tether type 0x0800 accept";
	#add_line "";
	
	# Block IPV6 for now.
	#add_line "\t\tether type 0x86DD accept";
fi
add_line "";

add_line "\t\tlog prefix \"BLOCK INBOUND TO LAN DEV - \" \\\\";
add_line "\t\tlog level warn \\\\";
add_line "\t\tlog flags skuid flags ether \\\\";
add_line "\t\tdrop;";
add_line "";
add_line "\t}";
add_line "}";
#################################################################################################################################################################
#		ARP Ingress																	#
#################################################################################################################################################################
add_line "table arp tbl_lan_arp_inp {";
add_line "\tchain chn_lan_arp_inp_filter {";
add_line "\t\ttype filter \\\\";
add_line "\t\thook input \\\\";
add_line "\t\tpriority 20; \\\\";
add_line "\t\tpolicy drop; \\\\";
add_line "\t\tcomment \"Inbound ARP Filter\";";
add_line "";

#try_match_arp_probe (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3"|"", SOURCE_MAC="$4"|"", PROBED_ADDRESS="$5");
#
#	Block inbound ARP probes, as I do not wish to use DHCP for now.
#
# Allow ARP probes inbound to the interface, such that I can dispute other network clients' claims to my address.
#
#try_match_arp_probe "in" $LAN_DEV $LAN_VLAN_ID "" $LAN_IP
#add_line "";

#try_match_arp_reply (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SRC_MAC="$4", SRC_NET="$5", DST_MAC="$6", DST_NET="$7");
#
#	Block inbound ARP replies, as I do not wish to use DHCP for now.
#
# Allow ARP replies inbound to the interface, such that my probe before claiming an address can be answered.
#
#try_match_arp_reply "in" $LAN_DEV $LAN_VLAN_ID "" "10.0.0.0/8" $LAN_MAC $LAN_IP
#add_line "";

add_line "\t\tlog prefix \"BLOCK LAN ARP INBOUND - \" \\\\";
add_line "\t\tlog level warn \\\\";
add_line "\t\tlog flags skuid flags ether \\\\";
add_line "\t\tdrop;";
add_line "";
add_line "\t}";
add_line "}";
#################################################################################################################################################################
#		ARP Egress																	#
#################################################################################################################################################################
add_line "table arp tbl_lan_arp_out {";
add_line "\tchain chn_lan_arp_out_filter {";
add_line "\t\ttype filter \\\\";
add_line "\t\thook output \\\\";
add_line "\t\tpriority 120; \\\\";
add_line "\t\tpolicy drop; \\\\";
add_line "\t\tcomment \"Outbound ARP Filter\";";
add_line "";

#try_match_arp_probe (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3"|"", SOURCE_MAC="$4"|"", PROBED_ADDRESS="$5");
#
#	Block outbound ARP probes, as I do not wish to use DHCP for now.
#
# Allow ARP probes outbound to the network, such that I can discover if another network client owns the address I want to claim.
#
#arp_probe "out" $LAN_DEV $LAN_VLAN_ID $LAN_MAC "10.0.0.0/8"
#add_line "";

#try_match_arp_reply (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SRC_MAC="$4", SRC_NET="$5", DST_MAC="$6", DST_NET="$7");
#
#	Block outbound ARP replies, as I do not wish to use DHCP for now.
#
# Allow ARP replies outbound to the network, such that I can claim an address in the case that I see a probe. 
#
#arp_reply "out" $LAN_DEV "" $LAN_MAC $LAN_IP "" "10.0.0.0/8"
#add_line "";

add_line "\t\tlog prefix \"BLOCK LAN ARP OUTBOUND - \" \\\\";
add_line "\t\tlog level warn \\\\";
add_line "\t\tlog flags skuid flags ether \\\\";
add_line "\t\tdrop;";
add_line "";
add_line "\t}";
add_line "}";

#################################################################################################################################################################
#		IPV4 LAN Pre-routing filter															#
#################################################################################################################################################################
add_line "table ip tbl_lan_ip4_prerouting_filter {";
add_line "\tchain chn_lan_ip4_prerouting_filter {";
add_line "\t\ttype filter \\\\";
add_line "\t\thook prerouting \\\\";
add_line "\t\tpriority 40; \\\\";
add_line "\t\tpolicy drop; \\\\";
add_line "\t\tcomment \"Inbound Pre-routing IPV4 filter\";";
add_line "";
add_line "\t\tct state invalid \\\\";
add_line "\t\tlog prefix \"IPV4 PRE-ROUTING - CT state invalid - \" \\\\";
add_line "\t\tlog level warn \\\\";
add_line "\t\tlog flags skuid flags ether \\\\";
add_line "\t\tdrop;";
add_line "";
##########################################################################################################################
# Accept loopback traffic early. Include a sanity check for lo iface traffic with non-lo-acceptable source/destination IP.
##########################################################################################################################
add_line "\t\tmeta iifname lo \\\\";
add_line "\t\tip saddr != $IPV4_NETWORK_LOOPBACK \\\\";
add_line "\t\tip daddr != $IPV4_NETWORK_LOOPBACK \\\\";
add_line "\t\tlog level emerg \\\\";
add_line "\t\tlog prefix \"NON-LOOPBACK ADDRESS OCURRED WITHIN LOOPBACK INTERFACE. TRACE SOURCE IMMEDIATELY. - \"";
add_line "\t\tlog flags all";
add_line "\t\drop;";
add_line "";
add_line "\t\tmeta iifname lo \\\\";
add_line "\t\tip saddr $IPV4_NETWORK_LOOPBACK";
add_line "\t\tip daddr $IPV4_NETWORK_LOOPBACK";
add_line "\t\taccept;";
add_line "";
##########################################################################################################################
# Include some sanity checks for packet size, header content, etc.
##########################################################################################################################
drop_invalid_ipv4_header
add_line "";
########################################################################################################################################
# IP Protocol 1 / ICMP traffic is accepted early, and later filtered in the INPUT (to machine) and FORWARD (to another network) chains
########################################################################################################################################
add_line "\t\tip protocol 1 accept; \\\\";
add_line "";
########################################################################################################################################
# IP Protocol 6 / TCP traffic is accepted early, and later filtered in the INPUT (to machine) and FORWARD (to another network) chains
########################################################################################################################################
add_line "\t\tip protocol 6 accept; \\\\";
add_line "";
########################################################################################################################################
# IP Protocol 17 / UDP traffic is accepted early, and later filtered in the INPUT (to machine) and FORWARD (to another network) chains
########################################################################################################################################
add_line "\t\tip protocol 17 accept;\\\\";
add_line "";
########################################################################################################################################
# All other protocols are dropped early.
########################################################################################################################################
add_line "\t\tlog prefix \"BLOCK IPV4 INBOUND - \" \\\\";
add_line "\t\tlog level warn \\\\";
add_line "\t\tlog flags skuid flags ether \\\\";
add_line "\t\tdrop;";
add_line "\t}";
add_line "}";

#################################################################################################################################################################
#		IPV4 LAN Pre-routing nat															#
#################################################################################################################################################################
add_line "table ip tbl_lan_ip4_prerouting_nat {";
add_line "\tchain chn_lan_ip4_prerouting_nat {";
add_line "\t\ttype nat \\\\";
add_line "\t\thook prerouting \\\\";
add_line "\t\tpriority 45; \\\\";
add_line "\t\tpolicy accept; \\\\";
add_line "\t\tcomment \"Inbound Pre-routing IPV4 nat\";";
add_line "";
#################################################################################################################################################
# This table is dedicated to 'destinaton NAT', where the destination address changes.
# This occurs where this machine is a 'reverse proxy' in front of services hosted by this machine, or a machine in the network it is routing for.
# This is commonly called 'port forwarding'. This is less common within the internal (or 'LAN') side of the network.
#################################################################################################################################################
add_line "";
add_line "\t}";
add_line "}";

#################################################################################################################################################################
#		IPV4 LAN Input (to this machine)
#################################################################################################################################################################
add_line "table ip tbl_ip4_input_filter {";
add_line "";
################################################################################
#		Redirect traffic to per-interface (device) chains
################################################################################
add_line "\tchain chn_all_ip4_input_filter {";
add_line "\t\ttype filter \\\\";
add_line "\t\thook input \\\\";
add_line "\t\tpriority 40; \\\\";
add_line "\t\tpolicy drop; \\\\";
add_line "\t\tcomment \"IPV4 Input Filter\"";
add_line "";
add_line "\t\tct state invalid \\\\";
add_line "\t\tlog prefix \"LAN IPV4 INPUT - CT state invalid - \" \\\\";
add_line "\t\tlog level warn \\\\";
add_line "\t\tlog flags skuid flags ether \\\\";
add_line "\t\tdrop;";
add_line "";
add_line "\t\tmeta iifname $LAN_DEV jump chn_lan_ip4_input_filter;";
add_line "";
add_line "\t}";
add_line "";
################################################################################
#		Redirect traffic to per-protocol chains
################################################################################
add_line "\tchain chn_lan_ip4_input_filter {";
add_line "\t\ttype filter \\\\";
add_line "\t\thook input \\\\";
add_line "\t\tpriority 60; \\\\";
add_line "\t\tpolicy drop; \\\\";
add_line "\t\tcomment \"LAN IPV4 Input filter\";";
add_line "";
add_line "\t\tip protocol 1 jump chn_lan_ip4_input_filter_icmpv4";
add_line "";
add_line "\t\tip protocol 6 jump chn_lan_ip4_input_filter_tcp";
add_line "";
add_line "\t\tip protocol 17 jump chn_lan_ip4_input_filter_udp";
add_line "";
add_line "\t\tlog prefix \"BLOCK LAN IPV4 INBOUND - \" \\\\";
add_line "\t\tlog level warn \\\\";
add_line "\t\tlog flags skuid flags ether \\\\";
add_line "\t\tdrop;";
add_line "";
add_line "\t}";
add_line "";
###################################################################################
#		IPV4 TCP Traffic:
#
#
#
#
###################################################################################
add_line "\t chain chn_lan_ip4_input_filter_tcp {";
add_line "\t\ttype filter \\\\";
add_line "\t\thook input \\\\";
add_line "\t\tpriority 40; \\\\";
add_line "\t\tpolicy drop; \\\\";
add_line "\t\tcomment \"Input IPV4 TCP filter\";";
###################################################################
# Include some sanity checks for packet size, header content, etc.
###################################################################
layer4_restrictions_tcp
######################################################################################
#	HTTP for APT responses, session close, and session reset.
######################################################################################
#	Accept HTTP TCP responses into the "APT" service for package update content.
#	try_match_http_tcp_response(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
	try_match_http_tcp_response "IN" $LAN_DEV $LAN_VLAN_ID $LAN_GWY_MAC "PUBLIC IP" $LAN_MAC $LAN_IP $SERVICE_UID_APT
	add_line "\t\taccept;";
#	TODO: Pass the packet to a userspace C program via NFQUEUE to inspect packet contents and ensure it is a valid HTTP reply
#	add_line "\t\tqueue to $QUEUE_NUMBER_HTTP_RESPONSE";

#	try_match_ipv4_tcp_fin (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
#	Allow TCP FIN requests for closing TCP HTTP sessions.
	try_match_ipv4_tcp_fin "IN" $LAN_DEV $LAN_VLAN_ID $LAN_GWY_MAC "PUBLIC IP" "80" $LAN_MAC $LAN_IP $PORT_EPHEMERAL $SERVICE_UID_APT
	add_line "\t\taccept;";

# 	try_match_ipv4_tcp_reset (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
#	Allow TCP Reset responses for failed TCP HTTP requests.
	try_match_ipv4_tcp_reset "IN" $LAN_DEV $LAN_VLAN_ID $LAN_GWY_MAC "PUBLIC IP" "80" $LAN_MAC $LAN_IP $PORT_EPHEMERAL $SERVICE_UID_APT
	add_line "\t\taccept;";

######################################################################################
#	HTTPS for APT responses, session close, and session reset.
######################################################################################
#	Accept HTTPS TCP responses into the "APT" service for package update content.
#	try_match_https_tcp_response(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
	try_match_https_tcp_response "IN" $LAN_DEV $LAN_VLAN_ID $LAN_GWY_MAC "PUBLIC IP" $LAN_MAC $LAN_IP $SERVICE_UID_APT
	add_line "\t\taccept;";
#	Due to encryption, it is not possible to check integrity of HTTPS packet contents without a network-wide HTTP proxy.
#	Users should not be forced to utilise the HTTPS proxy.

#	try_match_ipv4_tcp_fin (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
#	Allow TCP FIN requests for closing TCP HTTPS sessions.
	try_match_ipv4_tcp_fin "IN" $LAN_DEV $LAN_VLAN_ID $LAN_GWY_MAC "PUBLIC IP" "443" $LAN_MAC $LAN_IP $PORT_EPHEMERAL $SERVICE_UID_APT
	add_line "\t\taccept;";

# 	try_match_ipv4_tcp_reset (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
#	Allow TCP Reset responses for failed TCP HTTPS requests.
	try_match_ipv4_tcp_reset "IN" $LAN_DEV $LAN_VLAN_ID $LAN_GWY_MAC "PUBLIC IP" "443" $LAN_MAC $LAN_IP $PORT_EPHEMERAL $SERVICE_UID_APT
	add_line "\t\taccept;";

######################################################################################
#	DNS Over TLS for systemd-resolved responses, session close, and session reset.
######################################################################################
#	Accept DNS over TLS responses into the "systemd-resolved" service for name lookup responses.
#	try_match_sdns_tcp_response (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
	try_match_sdns_tcp_response "IN" $LAN_DEV $LAN_VLAN_ID $LAN_GWY_MAC $LAN_GWY_IP $LAN_MAC $LAN_IP $SERVICE_UID_SDNS
	add_line "\t\taccept;";
#	Due to encryption, it is not possible to check integrity of DNS over TLS packet contents without a network-wide DNS over TLS 'proxy'.

#	Allow TCP FIN requests for closing TCP DNS over TLS sessions.
#	try_match_ipv4_tcp_fin (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
	try_match_ipv4_tcp_fin "IN" $LAN_DEV $LAN_VLAN_ID $LAN_GWY_MAC $LAN_GWY_IP "853" $LAN_MAC $LAN_IP $PORT_EPHEMERAL $SERVICE_UID_SDNS
	add_line "\t\taccept;";

#	Allow TCP Reset responses for failed TCP DNS over TLS requests.
# 	try_match_ipv4_tcp_reset (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$8");
	try_match_ipv4_tcp_reset "IN" $LAN_DEV $LAN_VLAN_ID $LAN_GWY_MAC $LAN_GWY_IP "853" $LAN_MAC $LAN_IP $PORT_EPHEMERAL $SERVICE_UID_SDNS
	add_line "\t\taccept;";

add_line "\t\tlog prefix \"LAN IPV4 INPUT TCP UNKNOWN SIGNATURE - \" \\\\";
add_line "\t\tlog level warn \\\\";
add_line "\t\tlog flags skuid flags ether \\\\";
add_line "\t\tdrop;";
add_line "\t}";
add_line "";

####################################################################################
#		IPV4 UDP Traffic:
#
#
#
#
####################################################################################
add_line "\t chain chn_lan_ip4_input_filter_udp {";
add_line "\t\ttype filter \\\\";
add_line "\t\thook input \\\\";
add_line "\t\tpriority 40; \\\\";
add_line "\t\tpolicy drop; \\\\";
add_line "\t\tcomment \"Input IPV4 UDP filter\";";
###################################################################
# Include some sanity checks for packet size, header content, etc.
###################################################################
layer4_restrictions_udp
######################################################################################
#	HTTP for APT responses, session close, and session reset.
######################################################################################
#	Accept DNS replies into the "systemd-resolved" service for name lookup responses
#	try_match_dns_udp_reply(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
	try_match_dns_udp_reply "IN" $LAN_DEV $LAN_VLAN_ID $LAN_GWY_MAC $LAN_GWY_IP $LAN_MAC $LAN_IP $SERVICE_UID_DNS
	add_line "\t\taccept;";
#	TODO: Pass the packet to a userspace C program via NFQUEUE to inspect packet contents and ensure it is a valid DNS reply
#	add_line "\t\tqueue to $QUEUE_NUMBER_DNS_REPLY";

#	Accept NTP control channel messages 
#	try_match_ntp_udp_kiss_of_death (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SRC_MAC="$4", SRC_IP="$5", DST_MAC="$6", DST_IP="$7");
#	try_match_ntp_udp_kiss_of_death "IN" $LAN_DEV $LAN_VLAN_ID $LAN_GWY_MAC $LAN_GWY_IP $LAN_MAC $LAN_IP
#	add_line "\t\taccept;";
#	TODO: Pass the packet to a userspace C program via NFQUEUE to inspect packet contents and ensure it is a valid NTP reply
#	add_line "\t\tqueue to $QUEUE_NUMBER_NTP_KISS_OF_DEATH";
	
#	NOTE: NTP responses are split into 'stratum 1' and 'stratum 2 or greater' due to difference in packet content (specifically, the reference clock ID)

#	Accept NTP responses with a stratum of 1.
#	try_match_ntp_udp_stratum_1_response (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
	try_match_ntp_udp_stratum_1_response "IN" $LAN_DEV $LAN_VLAN_ID $LAN_GWY_MAC $LAN_GWY_IP $LAN_MAC $LAN_IP $SERVICE_UID_NTP
	add_line "\t\taccept;";
#	TODO: Pass the packet to a userspace C program via NFQUEUE to inspect packet contents and ensure it is a valid NTP reply
#	add_line "\t\tqueue to $QUEUE_NUMBER_NTP_RESPONSE_STRATUM_1";

#	Accept NTP responses with a stratum of 2 or greater.
#	try_match_ntp_udp_stratum_2_or_greater_response (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", REFERENCE_IP="$9"|"", SERVICE_UID="$10");
	try_match_ntp_udp_stratum_2_or_greater_response "IN" $LAN_DEV $LAN_VLAN_ID $LAN_GWY_MAC $LAN_GWY_IP $LAN_MAC $LAN_IP "" $SERVICE_UID_NTP
	add_line "\t\taccept;";
#	TODO: Pass the packet to a userspace C program via NFQUEUE to inspect packet contents and ensure it is a valid NTP reply
#	add_line "\t\tqueue to $QUEUE_NUMBER_NTP_RESPONSE_STRATUM_2";

#	Accept HTTP responses into the "APT" service for package update content.
#	try_match_http_udp_response(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
	try_match_http_udp_response "IN" $LAN_DEV $LAN_VLAN_ID $LAN_GWY_MAC $LAN_GWY_IP $LAN_MAC $LAN_IP $SERVICE_UID_APT
	add_line "\t\taccept;";
#	TODO: Pass the packet to a userspace C program via NFQUEUE to inspect packet contents and ensure it is a valid HTTP response
#	add_line "\t\tqueue to $QUEUE_NUMBER_HTTP_RESPONSE";

#	Accept HTTPS responses into the "APT" service for package update content.
#	try_match_https_udp_response(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
	try_match_https_udp_response "IN" $LAN_DEV $LAN_VLAN_ID $LAN_GWY_MAC $LAN_GWY_IP $LAN_MAC $LAN_IP $SERVICE_UID_APT
	add_line "\t\taccept;";
#	Due to encryption, it is not possible to check integrity of HTTPS packet contents without a network-wide HTTP proxy.
#	Users should not be forced to utilise the HTTPS proxy, and additionally, some systems do not proxy all HTTPS request.

add_line "\t\tlog prefix \"LAN IPV4 INPUT UDP UNKNOWN SIGNATURE - \" \\\\";
add_line "\t\tlog level warn \\\\";
add_line "\t\tlog flags skuid flags ether \\\\";
add_line "\t\tdrop;";
add_line "\t}";
add_line "";

####################################################################################
#		IPV4 ICMP Traffic:
#
#	ICMP 'port-unreachable' response to a UDP session initiation.
#	ICMP 'echo response' to an ICMP Echo Request (ping/is alive and traceroute).
#
####################################################################################
add_line "\t chain chn_lan_ip4_input_filter_icmpv4 {";
add_line "\t\ttype filter \\\\";
add_line "\t\thook input \\\\";
add_line "\t\tpriority 40; \\\\";
add_line "\t\tpolicy drop; \\\\";
add_line "\t\tcomment \"Input IPV4 ICMP filter\";";
######################################################################################
# Include some sanity checks for packet size, header content, etc.
######################################################################################
layer4_restrictions_icmpv4
######################################################################################
#	Allow ICMPv4 Port Unreachable responses for failed UDP requests.
######################################################################################
#	Accept ICMPV4 Port Unreachable replies into the "systemd-resolved" service for failed name lookup responses
#	try_match_icmpv4_port_unreachable(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
	try_match_icmpv4_port_unreachable "IN" $LAN_DEV $LAN_VLAN_ID $LAN_GWY_MAC "PUBLIC IP" "53" $LAN_MAC $LAN_IP $PORT_EPHEMERAL $SERVICE_UID_DNS
	add_line "\t\taccept;";

#	Accept ICMPV4 Port Unreachable replies into the "time" service for failed name lookup responses
#	try_match_icmpv4_port_unreachable(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
	try_match_icmpv4_port_unreachable "IN" $LAN_DEV $LAN_VLAN_ID $LAN_GWY_MAC $LAN_GWY_IP "123" $LAN_MAC $LAN_IP "123" $SERVICE_UID_NTP
	add_line "\t\taccept;";
	
#	Accept ICMPV4 Port Unreachable replies into the "APT" service for failed package requests
#	try_match_icmpv4_port_unreachable(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
	try_match_icmpv4_port_unreachable "IN" $LAN_DEV $LAN_VLAN_ID $LAN_GWY_MAC "PUBLIC IP" "80" $LAN_MAC $LAN_IP $PORT_EPHEMERAL $SERVICE_UID_APT
	add_line "\t\taccept;";

#	Accept ICMPV4 Port Unreachable replies into the "APT" service for failed package requests
#	try_match_icmpv4_port_unreachable(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
	try_match_icmpv4_port_unreachable "IN" $LAN_DEV $LAN_VLAN_ID $LAN_GWY_MAC "PUBLIC IP" "443" $LAN_MAC $LAN_IP $PORT_EPHEMERAL $SERVICE_UID_APT
	add_line "\t\taccept;";

add_line "\t\tlog prefix \"BLOCK LAN IPV4 INPUT ICMP UNKNOWN SIGNATURE - \" \\\\";
add_line "\t\tlog level warn \\\\";
add_line "\t\tlog flags skuid flags ether \\\\";
add_line "\t\tdrop;";
add_line "\t}";

#################################
#	TABLE END		#
#################################
add_line "}";



#################################################################################################################################################################
#		IPV4 LAN Forward filter																#
#################################################################################################################################################################
add_line "table ip tbl_lan_ip4_forwarded_filter {";
add_line "\tchain chn_lan_ip4_forwarded_filter {";
add_line "\t\ttype filter \\\\";
add_line "\t\thook forward \\\\";
add_line "\t\tpriority 150; \\\\";
add_line "\t\tpolicy drop; \\\\";
add_line "\t\tcomment \"Forwarded IPV4 filter\";";
#
#	Nothing forwarded through this machine.
#
add_line "\t\tlog prefix \"LAN IPV4 FORWARD UNKNOWN SIGNATURE - \" \\\\";
add_line "\t\tlog level warn \\\\";
add_line "\t\tlog flags skuid flags ether \\\\";
add_line "\t\tdrop;";
add_line "\t}";
add_line "}";



#################################################################################################################################################################
#		IPV4 LAN Output																	#
#################################################################################################################################################################
add_line "table ip tbl_ip4_output_filter {";
add_line "";
################################################################################
#		Redirect traffic to per-interface (device) chains
################################################################################
add_line "\tchain chn_all_ip4_output_filter {";
add_line "\t\ttype filter \\\\";
add_line "\t\thook output \\\\";
add_line "\t\tpriority 200; \\\\";
add_line "\t\tpolicy drop; \\\\";
add_line "\t\tcomment \"IPV4 Output Filter\"";
add_line "";
add_line "\t\tct state invalid \\\\";
add_line "\t\tlog prefix \"LAN IPV4 OUTPUT - CT state invalid - \" \\\\";
add_line "\t\tlog level warn \\\\";
add_line "\t\tlog flags skuid flags ether \\\\";
add_line "\t\tdrop;";
add_line "";
add_line "\t\tmeta oifname $LAN_DEV jump chn_lan_ip4_output_filter;";
add_line "";
add_line "\t}";
add_line "";
################################################################################
#		Redirect traffic to per-protocol chains
################################################################################
add_line "\tchain chn_lan_ip4_output_filter {";
add_line "\t\ttype filter \\\\";
add_line "\t\thook output \\\\";
add_line "\t\tpriority 220; \\\\";
add_line "\t\tpolicy drop; \\\\";
add_line "\t\tcomment \"LAN IPV4 Output filter\";";
add_line "";
add_line "\t\tip protocol 1 jump chn_lan_ip4_output_filter_icmpv4";
add_line "";
add_line "\t\tip protocol 6 jump chn_lan_ip4_output_filter_tcp";
add_line "";
add_line "\t\tip protocol 17 jump chn_lan_ip4_output_filter_udp";
add_line "";
add_line "\t\tlog prefix \"BLOCK LAN IPV4 OUTBOUND - \" \\\\";
add_line "\t\tlog level warn \\\\";
add_line "\t\tlog flags skuid flags ether \\\\";
add_line "\t\tdrop;";
add_line "";
add_line "\t}";
add_line "";

###################################################################################
#		IPV4 TCP Traffic:
#
#
#
#
###################################################################################
add_line "\t chain chn_lan_ip4_output_filter_tcp {";
add_line "\t\ttype filter \\\\";
add_line "\t\thook output \\\\";
add_line "\t\tpriority 240; \\\\";
add_line "\t\tpolicy drop; \\\\";
add_line "\t\tcomment \"Input IPV4 TCP filter\";";
###################################################################
# Include some sanity checks for packet size, header content, etc.
###################################################################
layer4_restrictions_tcp
######################################################################################
#	DNS over TLS for NTP requests, session close, and session reset.
######################################################################################
#	Accept DNS over TLS queries out to the LAN DNS server
#	try_match_sdns_tcp_query (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
	try_match_sdns_tcp_query "OUT" $LAN_DEV $LAN_VLAN_ID $LAN_MAC $LAN_IP $LAN_GWY_MAC $LAN_GWY_IP $SERVICE_UID_SDNS
	add_line "\t\taccept;";
#	Due to encryption, it is not possible to check integrity of DNS over TLS packet contents without a network-wide DNS over TLS 'proxy'.

#	Accept TCP FIN requests to close DNS sessions
#	try_match_ipv4_tcp_fin (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
	try_match_ipv4_tcp_fin "OUT" $LAN_DEV $LAN_VLAN_ID $LAN_MAC $LAN_IP $PORT_EPHEMERAL $LAN_GWY_MAC $LAN_IP "853" $SERVICE_UID_SDNS
	add_line "\t\taccept;";

#	Accept TCP Reset requests to close DNS sessions
#	try_match_ipv4_tcp_reset (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
	try_match_ipv4_tcp_reset "OUT" $LAN_DEV $LAN_VLAN_ID $LAN_MAC $LAN_IP $PORT_EPHEMERAL $LAN_GWY_MAC $LAN_IP "853" $SERVICE_UID_SDNS
	add_line "\t\taccept;";

######################################################################################
#	HTTP for APT requests, session close, and session reset.
######################################################################################
#	Accept HTTP requests to the APT Repository IP's for package requests
#
#	The LAN Gateway MAC is used, as it is the default route out to the internet.
#
#	try_match_http_tcp_request(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
	try_match_http_tcp_request "OUT" $LAN_DEV $LAN_VLAN_ID $LAN_MAC $LAN_IP $LAN_GWY_MAC "PUBLIC IP" $SERVICE_UID_APT
	add_line "\t\taccept;";
#	TODO: Pass the packet to a userspace C program via NFQUEUE to inspect packet contents and ensure it is a valid HTTP request
#	add_line "\t\tqueue to $QUEUE_NUMBER_HTTP_REQUEST";

#	Accept TCP FIN requests to close those sessions
#	try_match_ipv4_tcp_fin (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
	try_match_ipv4_tcp_fin "OUT" $LAN_DEV $LAN_VLAN_ID $LAN_MAC $LAN_IP $PORT_EPHEMERAL $LAN_GWY_MAC "PUBLIC IP" "80" $SERVICE_UID_APT
	add_line "\t\taccept;";

#	Accept TCP Reset requests to close those sessions
#	try_match_ipv4_tcp_reset (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
	try_match_ipv4_tcp_reset "OUT" $LAN_DEV $LAN_VLAN_ID $LAN_MAC $LAN_IP $PORT_EPHEMERAL $LAN_GWY_MAC "PUBLIC IP" "80" $SERVICE_UID_APT
	add_line "\t\taccept;";

######################################################################################
#	HTTPS for APT requests, session close, and session reset.
######################################################################################
#	try_match_https_tcp_request(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
	try_match_https_tcp_request "OUT" $LAN_DEV $LAN_VLAN_ID $LAN_MAC $LAN_IP $LAN_GWY_MAC "PUBLIC IP" $SERVICE_UID_APT
	add_line "\t\taccept;";
#	Due to encryption, it is not possible to check integrity of HTTPS packet contents without a network-wide HTTP proxy.
#	Users should not be forced to utilise the HTTPS proxy, and additionally, some systems do not proxy all HTTPS request.

#	try_match_ipv4_tcp_fin (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
	try_match_ipv4_tcp_fin "OUT" $LAN_DEV $LAN_VLAN_ID $LAN_MAC $LAN_IP $PORT_EPHEMERAL $LAN_GWY_MAC "PUBLIC IP" "443" $SERVICE_UID_APT
	add_line "\t\taccept;";

#	try_match_ipv4_tcp_reset (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
	try_match_ipv4_tcp_reset "OUT" $LAN_DEV $LAN_VLAN_ID $LAN_MAC $LAN_IP $PORT_EPHEMERAL $LAN_GWY_MAC "PUBLIC IP" "443" $SERVICE_UID_APT
	add_line "\t\taccept;";

add_line "\t\tlog prefix \"LAN IPV4 OUTPUT TCP UNKNOWN SIGNATURE - \" \\\\";
add_line "\t\tlog level warn \\\\";
add_line "\t\tlog flags skuid flags ether \\\\";
add_line "\t\tdrop;";
add_line "\t}";
add_line "";

####################################################################################
#		IPV4 UDP Traffic:
#
#
#
#
####################################################################################
add_line "\t chain chn_lan_ip4_output_filter_udp {";
add_line "\t\ttype filter \\\\";
add_line "\t\thook output \\\\";
add_line "\t\tpriority 240; \\\\";
add_line "\t\tpolicy drop; \\\\";
add_line "\t\tcomment \"Output IPV4 UDP filter\";";
###################################################################
# Include some sanity checks for packet size, header content, etc.
###################################################################
layer4_restrictions_udp
######################################################################################
#	DNS for name resolution
######################################################################################
#	try_match_dns_udp_query (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
	try_match_dns_udp_query "OUT" $LAN_DEV $LAN_VLAN_ID $LAN_MAC $LAN_IP $LAN_GWY_MAC $LAN_GWY_IP $SERVICE_UID_SDNS
	add_line "\t\taccept;";
#	TODO: Pass the packet to a userspace C program via NFQUEUE to inspect packet contents and ensure it is a valid DNS request
#	add_line "\t\tqueue to $QUEUE_NUMBER_DNS_QUERY";

######################################################################################
#	NTP for time synchronisation
######################################################################################
#	try_match_ntp_udp_stratum_1_request (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
	try_match_ntp_udp_stratum_1_request "OUT" $LAN_DEV $LAN_VLAN_ID $LAN_MAC $LAN_IP $LAN_GWY_MAC $LAN_GWY_IP $SERVICE_UID_NTP
	add_line "\t\taccept;";
#	TODO: Pass the packet to a userspace C program via NFQUEUE to inspect packet contents and ensure it is a valid NTP request
#	add_line "\t\tqueue to $QUEUE_NUMBER_NTP_REQUEST_STRATUM_1";

#	try_match_ntp_udp_stratum_2_or_greater_request (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$6", CLIENT_IP="$7", SERVER_MAC="$4", SERVER_IP="$5", REFERENCE_IP="$9"|"", SERVICE_UID="$10");
	try_match_ntp_udp_stratum_2_or_greater_request "OUT" $LAN_DEV $LAN_VLAN_ID $LAN_MAC $LAN_IP $LAN_GWY_MAC $LAN_GWY_IP "" $SERVICE_UID_NTP
	add_line "\t\taccept;";
#	TODO: Pass the packet to a userspace C program via NFQUEUE to inspect packet contents and ensure it is a valid NTP request
#	add_line "\t\tqueue to $QUEUE_NUMBER_NTP_REQUEST_STRATUM_2";

######################################################################################
#	HTTP for APT requests
######################################################################################
#	try_match_http_udp_request(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
	try_match_http_udp_request "OUT" $LAN_DEV $LAN_VLAN_ID $LAN_MAC $LAN_IP $LAN_GWY_MAC "PUBLIC IP" $SERVICE_UID_APT
	add_line "\t\taccept;";
#	TODO: Pass the packet to a userspace C program via NFQUEUE to inspect packet contents and ensure it is a valid HTTP request
#	add_line "\t\tqueue to $QUEUE_NUMBER_HTTP_REQUEST;

######################################################################################
#	HTTPS for APT requests
######################################################################################
#	try_match_https_udp_request(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
	try_match_https_udp_request "OUT" $LAN_DEV $LAN_VLAN_ID $LAN_MAC $LAN_IP $LAN_GWY_MAC "PUBLIC IP" $SERVICE_UID_APT
	add_line "\t\taccept;";
#	Due to encryption, it is not possible to check integrity of HTTPS packet contents without a network-wide HTTP proxy.
#	Users should not be forced to utilise the HTTPS proxy, and additionally, some systems do not proxy all HTTPS request.

add_line "\t\tlog prefix \"LAN IPV4 OUTPUT UDP UNKNOWN SIGNATURE - \" \\\\";
add_line "\t\tlog level warn \\\\";
add_line "\t\tlog flags skuid flags ether \\\\";
add_line "\t\tdrop;";
add_line "\t}";
add_line "";

####################################################################################
#		IPV4 ICMP Traffic:
#
#	ICMP 'port-unreachable' response to a UDP session initiation.
#	ICMP 'echo response' to an ICMP Echo Request (ping/is alive and traceroute).
#
####################################################################################
add_line "\t chain chn_lan_ip4_output_filter_icmpv4 {";
add_line "\t\ttype filter \\\\";
add_line "\t\thook output \\\\";
add_line "\t\tpriority 240; \\\\";
add_line "\t\tpolicy drop; \\\\";
add_line "\t\tcomment \"Output IPV4 ICMP filter\";";
######################################################################################
# Include some sanity checks for packet size, header content, etc.
######################################################################################
layer4_restrictions_icmpv4	
add_line "\t\tlog prefix \"BLOCK LAN IPV4 OUTPUT ICMP UNKNOWN SIGNATURE - \" \\\\";
add_line "\t\tlog level warn \\\\";
add_line "\t\tlog flags skuid flags ether \\\\";
add_line "\t\tdrop;";
add_line "\t}";

#################################
#	TABLE END		#
#################################
add_line "}";

#################################################################################################################################################################
#		IPV4 LAN Post-routing filter															#
#################################################################################################################################################################
add_line "table ip tbl_lan_ip4_postrouting_filter {";
add_line "\tchain chn_lan_ip4_postrouting_filter {";
add_line "\t\ttype filter \\\\";
add_line "\t\thook postrouting \\\\";
add_line "\t\tpriority 220; \\\\";
add_line "\t\tpolicy drop; \\\\";
add_line "\t\tcomment \"Outbound Post-routing IPV4 filter\";";
add_line "";
##########################################################################################################################
# Include some sanity checks for packet size, header content, etc.
##########################################################################################################################
drop_invalid_ipv4_header
add_line "";
add_line "\t\tlog prefix \"LAN IPV4 OUTBOUND UNKNOWN SIGNATURE - \" \\\\";
add_line "\t\tlog level warn \\\\";
add_line "\t\tlog flags skuid flags ether \\\\";
add_line "\t\tdrop;";
add_line "\t}";
add_line "}";

#################################################################################################################################################################
#		IPV4 LAN Post-routing nat															#
#################################################################################################################################################################

add_line "table ip tbl_lan_ip4_postrouting_nat {";
add_line "\tchain chn_lan_ip4_postrouting_nat {";
add_line "\t\ttype nat \\\\";
add_line "\t\thook postrouting \\\\";
add_line "\t\tpriority 225; \\\\";
add_line "\t\tpolicy accept; \\\\";
add_line "\t\tcomment \"Outbound Post-routing IPV4 nat\";";
add_line "";
add_line "\t}";
add_line "}";

#################################################################################################################################################################
#		Netdev LAN Egress																#
#################################################################################################################################################################

add_line "table netdev tbl_lan_netdev_egr {";
add_line "\tchain chn_lan_netdev_egr_filter {";
add_line "\t\ttype filter \\\\";
add_line "\t\thook egress \\\\";
add_line "\t\tdevice $LAN_DEV \\\\";
add_line "\t\tpriority 250; \\\\";
add_line "\t\tpolicy accept; \\\\";
add_line "\t\tcomment \"Outbound Layer 2 Filter\";";
add_line "";
add_line "\t}";
add_line "}";

save;

if [ "$IS_TEST_RUN" = "false" ]; then
	apply;
fi
