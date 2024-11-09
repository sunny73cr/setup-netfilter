#!/bin/sh

##########################################################
#		HELPER SCRIPTS
##########################################################

#get_user_id(ID="0-65536");
get_user_id () {
	ID="$1";

	if [ -z $ID ]; then
		echo "get_user_id; you must provide a user name">&2;
		exit 2;
	fi
	
	UID="$(sudo cat /etc/passwd | grep -P "^$ID:" | cut -d ":" -f 3)";
	
	echo $UID;
}

#validate_mac_address(MAC="00:00:00:00:00:00-FF:FF:FF:FF:FF:FF");
validate_mac_address () {
	MAC="$1";
	
	if [ -n "$(echo $MAC | grep -P '[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}')" ]; then
		echo "true";
	else
		echo "false";
	fi;
}

#mac_address_is_private(MAC="00:00:00:00:00:00-FF:FF:FF:FF:FF:FF");
mac_address_is_private () {
	MAC="$1";
	
	if [ -z $MAC ]; then
		echo "mac_address_is_private; you must provide a MAC address.">&2;
		exit 2;
	fi
	
	if [ "$(validate_mac_address $MAC)" = "false" ]; then
		echo "mac_address_is_private; the MAC address \"$MAC\" is invalid.">&2;
		exit 2;
	fi
	
	OCTET1=$(echo $MAC | cut -d ':' -f 1);
	
	OCTETMASK=$(( $OCTET1 & 2 ));
	
	if ( $OCTETMASK -ne 0 ); then
		echo "true";
	else
		echo "false";
	fi
}

#mac_address_is_public(MAC="00:00:00:00:00:00-FF:FF:FF:FF:FF:FF");
mac_address_is_public () {
	MAC="$1";
	
	if [ -z $MAC ]; then
		echo "mac_address_is_public; you must provide a MAC address.">&2;
		exit 2;
	fi
	
	if [ "$(validate_mac_address $MAC)" = "false" ]; then
		echo "mac_address_is_public; the MAC address \"$MAC\" is invalid.">&2;
		exit 2;
	fi
	
	OCTET1=$(echo $MAC | cut -d ':' -f 1);
	
	OCTETMASK=$(( $OCTET1 & 2 ));
	
	if ( $OCTETMASK -ne 2 ); then
		echo "true";
	else
		echo "false";
	fi
}

#mac_address_is_multicast(MAC="00:00:00:00:00:00-FF:FF:FF:FF:FF:FF");
mac_address_is_multicast () {
	MAC="$1"
	
	if [ -z $MAC ]; then
		echo "mac_address_is_multicast; you must provide a MAC address.">&2;
		exit 2;
	fi
	
	if [ "$(validate_mac_address $MAC)" = "false" ]; then
		echo "mac_address_is_multicast; the MAC address \"$MAC\" is invalid.">&2;
		exit 2;
	fi
	
	OCTET1=$(echo $1 | cut -d ':' -f 1);
	
	OCTETMASK=$(( $OCTET1 & 1 ));
	
	if ( $OCTETMASK -ne 0 ); then
		echo "true";
	else
		echo "false";
	fi
}

#mac_address_is_unicast(MAC="00:00:00:00:00:00-FF:FF:FF:FF:FF:FF");
mac_address_is_unicast () {
	MAC="$1"
	
	if [ -z $MAC ]; then
		echo "mac_address_is_unicast; must provide a MAC address.">&2;
		exit 2;
	fi
	
	if [ "$(validate_mac_address $MAC)" = "false" ]; then
		echo "mac_address_is_unicast; the MAC address \"$MAC\" is invalid.">&2;
		exit 2;
	fi
	
	OCTET1=$(echo $MAC | cut -d ':' -f 1);
	
	OCTETMASK=$(( $OCTET1 & 1 ));
	
	if ( $OCTETMASK -ne 1 ); then
		echo "true";
	else
		echo "false";
	fi
}

#validate_net_address_ipv4(ADDR="0.0.0.0-255.255.255.255");
validate_net_address_ipv4 () {
	ADDR="$1";
	
	if [ -z $(echo $ADDR | grep -P '[0-9]{1}.[0-9]{1}.[0-9]{1}.[0-9]{1}') ]; then
		echo "false";
	fi
	
	OCTET1=$(echo $ADDR | cut -d '.' -f 1);
	
	if [ $OCTET1 > 255 ]; then
		echo "false";
	fi
	
	OCTET2=$(echo $ADDR | cut -d '.' -f 2);
	
	if [ $OCTET2 > 255 ]; then
		echo "false";
	fi
	
	OCTET3=$(echo $ADDR | cut -d '.' -f 3);
	
	if [ $OCTET3 > 255 ]; then
		echo "false";
	fi
	
	OCTET4=$(echo $ADDR | cut -d '.' -f 4);

	if [ $OCTET4 > 255 ]; then
		echo "false";
	fi
	
	echo "true";
}

#validate_port(PORT="0-65536");
validate_port () {
	PORT="$1";

	if ( $PORT -lt 1 ); then
		echo "false";
	fi
	
	if ( $PORT -gt 65536 ); then
		echo "false";
	fi
	
	echo "true";
}

#validate_interface_by_name("someText");
validate_interface_by_name () {
	INTERFACE_NAME="$1";
	
	if [ -n $(ip -br link show | grep $INTERFACE_NAME) ]; then
		echo "true";
	else
		echo "false";
	fi
}

#validate_interface_by_mac(MAC="00:00:00:00:00:00-FF:FF:FF:FF:FF:FF");
validate_interface_by_mac () {
	MAC="$1";

	if [ "$(validate_mac_address $MAC)" = "false" ]; then
		echo "validate_interface_by_mac; invalid MAC address.">&2;
		exit 2;
	fi

	if [ -n $(ip -br link show | grep $MAC) ]; then
		echo "true";
	else
		echo "false";
	fi
}

#validate_vlan_id(VLAN_ID="1-4096");
validate_vlan_id () {
	VLAN_ID="$1";

	if ( $VLAN_ID -lt 1 ); then
		echo "false";
	elif ( $VLAN_ID -gt 4096 ); then
		echo "false";
	else
		echo "true";
	fi
}

#layer_2_protocol_id_verify(ID="0x88A8, 0x8100, 0x0806, 0x0800, 0x86DD");
layer_2_protocol_id_verify () {
	ID="$1";
	
	if [ -z $ID ]; then
		echo "layer_2_protocol_id_verify; you must provide an id.">&2;
		exit 2;
	fi

	case $ID in
		"0x0800") echo "true"; ;;								# IP (IPv4)
		"0x0805") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# X25
		"0x0806") echo "true"; ;;								# Address Resolution Protocol
		"0x0808") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Frame Relay ARP [RFC1701]
		"0x08FF") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# G8BPQ AX.25 over Ethernet
		"0x22F3") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# TRILL [RFC6325]
		"0x22F4") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# TRILL L2-IS-IS [RFC6325]
		"0x6558") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Transparent Ethernet Bridging [RFC1701]
		"0x6559") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Raw Frame Relay [RFC1701]
		"0x8035") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Reverse ARP [RFC903]
		"0x809B") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Appletalk
		"0x80F3") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Appletalk Address Resolution Protocol
		"0x8137") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Novell IPX
		"0x8191") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# NetBEUI
		"0x86DD") echo "true"; ;;								# IP version 6
		"0x880B") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Point-to-Point Protocol
		"0x8847") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# MPLS [RFC5332]
		"0x8848") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# MPLS with upstream-assigned label [RFC5332]
		"0x884C") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# MultiProtocol over ATM
		"0x8863") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# PPP over Ethernet discovery stage
		"0x8864") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# PPP over Ethernet session stage
		"0x8884") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Frame-based ATM Transport over Ethernet
		"0x888E") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# EAP over LAN [802.1x]
		"0x88C7") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# EAPOL Pre-Authentication [802.11i]
		"0x88CC") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Link Layer Discovery Protocol [802.1ab]
		"0x88E5") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Media Access Control Security [802.1ae]
		"0x88E7") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Provider Backbone Bridging [802.1ah]
		"0x88F5") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Multiple VLAN Registration Protocol [802.1q]
		"0x88F7") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Precision Time Protocol
		"0x8906") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Fibre Channel over Ethernet
		"0x8914") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# FCoE Initialization Protocol
		"0x8915") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# RDMA over Converged Ethernet
		"0xA0ED") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# LoWPAN encapsulation
		"0x8100") echo "true"; ;;								# VLAN tagged frame [802.1q]
		"0x88A8") echo "true"; ;;								# QinQ Service VLAN tag identifier [802.1q]
		*)
			echo "ethernet_header; unrecognised EtherType.">&2;
			exit 2;
		;;
	esac
}

#layer_2_protocol_id_to_name(ID="0x88A8, 0x8100, 0x0806, 0x0800, 0x86DD");
layer_2_protocol_id_to_name () {
	ID="$1";
	
	if [ -z $ID ]; then
		echo "layer_2_protocol_id_to_name; you must provide an id.">&2;
		exit 2;
	fi
	
	case $ID in
		"0x0800") echo "IPV4"; ;;								# IP (IPv4)
		"0x0805") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# X25
		"0x0806") echo "ARP"; ;;								# Address Resolution Protocol
		"0x0808") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Frame Relay ARP [RFC1701]
		"0x08FF") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# G8BPQ AX.25 over Ethernet
		"0x22F3") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# TRILL [RFC6325]
		"0x22F4") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# TRILL L2-IS-IS [RFC6325]
		"0x6558") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Transparent Ethernet Bridging [RFC1701]
		"0x6559") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Raw Frame Relay [RFC1701]
		"0x8035") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Reverse ARP [RFC903]
		"0x809B") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Appletalk
		"0x80F3") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Appletalk Address Resolution Protocol
		"0x8137") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Novell IPX
		"0x8191") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# NetBEUI
		"0x86DD") echo "IPV6"; ;;								# IP version 6
		"0x880B") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Point-to-Point Protocol
		"0x8847") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# MPLS [RFC5332]
		"0x8848") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# MPLS with upstream-assigned label [RFC5332]
		"0x884C") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# MultiProtocol over ATM
		"0x8863") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# PPP over Ethernet discovery stage
		"0x8864") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# PPP over Ethernet session stage
		"0x8884") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Frame-based ATM Transport over Ethernet
		"0x888E") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# EAP over LAN [802.1x]
		"0x88C7") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# EAPOL Pre-Authentication [802.11i]
		"0x88CC") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Link Layer Discovery Protocol [802.1ab]
		"0x88E5") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Media Access Control Security [802.1ae]
		"0x88E7") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Provider Backbone Bridging [802.1ah]
		"0x88F5") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Multiple VLAN Registration Protocol [802.1q]
		"0x88F7") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Precision Time Protocol
		"0x8906") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# Fibre Channel over Ethernet
		"0x8914") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# FCoE Initialization Protocol
		"0x8915") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# RDMA over Converged Ethernet
		"0xA0ED") echo "layer_2_protocol_id_to_name; unsupported protocol">&2; exit 2; ;;	# LoWPAN encapsulation
		"0x8100") echo "VLAN-C"; ;;								# VLAN tagged frame [802.1q]
		"0x88A8") echo "VLAN-S"; ;;								# QinQ Service VLAN tag identifier [802.1q]
		*) #Unknown
			echo "Unknown protocol ID">&2;
			exit 2;
		;;
	esac
}

#layer_4_protocol_id_verify(ID="1, 6, 17");
layer_4_protocol_id_verify () {
	ID="$1";
	
	if [ -z $ID ]; then
		echo "layer_4_protocol_id_verify; you must provide an id.">&2;
		exit 2;
	fi

	case $ID in
		"1") echo "true"; ;; #ICMP
		"6") echo "true"; ;; #TCP
		"17") echo "true"; ;; #UDP
		*) echo "false"; ;; #Unknown
	esac
}

#layer_4_protocol_id_to_name(ID="1, 6, 17");
layer_4_protocol_id_to_name () {
	ID="$1";
	
	if [ -z $ID ]; then
		echo "layer_4_protocol_id_to_name; you must provide an id.">&2;
		exit 2;
	fi

	case $ID in
		"1") echo "icmp"; ;; #ICMP
		"6") echo "tcp"; ;; #TCP
		"17") echo "udp"; ;; #UDP
		*)
			echo "Unrecognised Layer 2 protocol number.">&2;
			exit 2;
		;;
	esac
}

#validate_verdict (VERDICT="$1");
validate_verdict () {
	VERDICT="$1";
	
	if [ -z $VERDICT ]; then
		echo "validate_verdict; you must supply a verdict.">&2;
		exit 2;
	fi
	
	case $VERDICT in
		"accept") echo "true"; ;;
		"drop") echo "true"; ;;
		"continue") echo "true"; ;;
		"return") echo "true"; ;;
		"jump") echo "true"; ;;
		"goto") echo "true"; ;;
		"queue") echo "true"; ;;
		*)
			echo "validate_verdict; unrecognised verdict.">&2;
			exit 2;
		;;
	esac
}

##########################################################
#		NETWORKING CONSTANTS
##########################################################

MAC_UNSPECIFIED="00:00:00:00:00:00";
MAC_BROADCAST="FF:FF:FF:FF:FF:FF";

IPV4_NETWORK_LOOPBACK="127.0.0.0/8";
IPV4_NETWORK_EMPTY_NETS="0.0.0.0/8";
IPV4_NETWORK_EMPTY_ADDRESS="0.0.0.0/32";
IPV4_NETWORK_EMPTY_NETS_EXCEPT_EMPTY_ADDRESS="0.0.0.1-0.255.255.255";
IPV4_NETWORK_BROADCAST="255.255.255.255/32";
IPV4_NETWORK_LINK_LOCAL="169.254.0.0/16";
IPV4_NETWORK_PRIVATE_10="10.0.0.0/8";
IPV4_NETWORK_PRIVATE_172_16="172.16.0.0/12";
IPV4_NETWORK_PRIVATE_192_168="192.168.0.0/16";
IPV4_NETWORK_SHARED_SPACE="100.64.0.0/10";
IPV4_NETWORK_IETF_PROTOCOL_ASSIGNMENTS="192.0.0.0/24";
IPV4_NETWORK_IPV4_SERVICE_CONTINUITY="192.0.0.0/29";
IPV4_NETWORK_DUMMY_ADDRESS="192.0.0.8/32";
IPV4_NETWORK_PORT_CONTROL_PROTOCOL_ANYCAST="192.0.0.9/32";
IPV4_NETWORK_RELAY_NAT_TRAVERSAL_ANYCAST="192.0.0.10/32";
IPV4_NETWORK_NAT_64_DISCOVERY="192.0.0.170/32";
IPV4_NETWORK_DNS_64_DISCOVERY="192.0.0.171/32";
IPV4_NETWORK_TEST_NET_1="192.0.2.0/24";
IPV4_NETWORK_TEST_NET_2="198.51.100.0/24";
IPV4_NETWORK_TEST_NET_3="203.0.113.0/24";
IPV4_NETWORK_AS112_V4="192.31.196.0/24";
IPV4_NETWORK_AS112_V4_DIRECT_DELEGATION="192.175.48.0/24";
IPV4_NETWORK_AMT="192.52.193.0/24";
IPV4_NETWORK_6TO4_RELAY_ANYCAST="192.88.99.0/24";
IPV4_NETWORK_BENCHMARKING="198.18.0.0/15";
IPV4_NETWORK_MULTICAST="240.0.0.0/4";

IPV6_NETWORK_LOOPBACK="::1/128";
IPV6_NETWORK_UNSPECIFIED="::/128";
IPV6_NETWORK_IP4_MAPPED="::ffff:0:0/96";
IPV6_NETWORK_IP4_IP6_TRANSLATE="64:ff9b::/96";
IPV6_NETWORK_IP4_IP6_TRANSLATE_LOCAL="64:ff9b:1::/48";
IPV6_NETWORK_DISCARD_ONLY="100::/64";
IPV6_NETWORK_IETF_PROTOCOL_ASSIGNMENTS="2001::/23";
IPV6_NETWORK_TEREDO="2001::/32";
IPV6_NETWORK_PORT_CONTROL_PROTOCOL_ANYCAST="2001:1::1/128";
IPV6_NETWORK_NAT_TRAVERSAL="2001:1::2/128";
IPV6_NETWORK_BENCHMARKING="2001:2::/48";
IPV6_NETWORK_AMT="2001:3::/32";
IPV6_NETWORK_AS112_V6="2001:4:112::/48";
IPV6_NETWORK_AS112_V6_DIRECT_DELEGATION="2620:4f:8000::/48";
IPV6_NETWORK_ORCHID="2001:10::/28";
IPV6_NETWORK_ORCHID_V2="2001:20::/28";
IPV6_NETWORK_DOCUMENTATION="2001:db8::/32";
IPV6_NETWORK_6TO4="2002::/16";
IPV6_NETWORK_UNIQUE_LOCAL="fc00::/7";
IPV6_NETWORK_LINK_LOCAL="fe80::/10";

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

SERVICE_UID_DHCP=$(get_user_id "dhcpcd");
SERVICE_UID_NTP=$(get_user_id "systemd-timesync");
SERVICE_UID_DNS=$(get_user_id "systemd-resolve");
SERVICE_UID_SDNS=$(get_user_id "systemd-resolve");
SERVICE_UID_APT=$(get_user_id "_apt");

##########################################################
#		SERVICE NETWORK ENDPOINTS
##########################################################

PORT_ZERO="0";
PORT_SYSTEM="1-1023";
PORT_USER="1024-49151";
PORT_EPHEMERAL="49152-65535";
PORT_MAX="65536";

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

##########################################################
#		CONFGIURATION FILE DATA & HELPERS
##########################################################

NETFILTER_CONFIG_CONTENT="";

add_line () {
	NETFILTER_CONFIG_CONTENT="$NETFILTER_CONFIG_CONTENT$1\n";
}
	
save () {
	echo $NETFILTER_CONFIG_CONTENT > /etc/nftables.conf;
}

apply () {
	sudo /etc/nftables.conf;
}

##########################################################
#		CONFGIURATION FILE DATA & HELPERS
##########################################################

#layer3_restrictions_ipv4 ();
layer3_restrictions_ipv4 () {
	add_line "\t\tether type != 0x0800 \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog prefix \"DROP - Ethertype is not 0x0800 (IPV4)- \" \\\\";
	add_line "\t\tdrop;";
	add_line "";
	
	add_line "\t\t@nh,0,4 != 4 \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog prefix \"DROP - IP version is not 4- \" \\\\";
	add_line "\t\tdrop;";
	add_line "";
	
	add_line "\t\t@nh,4,4 < 5 \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 header length is too small - invalid packet- \" \\\\";
	add_line "\t\tdrop;";
	add_line "";
	add_line "\t\t@ih,4,4 > 5 \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 header length is too large - may contain options- \" \\\\";
	add_line "\t\tdrop;";
	add_line "";
	
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
	#add_line "\t\t@nh,8,6 56 \\\\";
	#add_line "\t\tlog level warn \\\\";
	#add_line "\t\tlog prefix \"DROP - IPV4 DSCP is CS7 - Reserved for future use- \" \\\\";
	#add_line "\t\tdrop;";
	#add_line "";
	
	#ECN
	# 00 or 0 Not-ECT
	# 01 or 1 ECN Capable Transport
	# 10 or 2 ECN Capable Transport
	# 11 or 3 Congestion Experienced
	#add_line "\t\t@nh,14,2 0 \\\\";
	#add_line "\t\tlog level warn \\\\";
	#add_line "\t\tlog prefix \"DROP - IPV4 DSCP is CS7 - Reserved for future use- \" \\\\";
	#add_line "\t\tdrop;";
	#add_line "";
	
	add_line "\t\t@nh,16,16 < 160 \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 frame appears to be missing content- \" \\\\";
	add_line "\t\tdrop;";
	#
	#	Not worth checking? Netfilter manpages states that packets processed through GRO/GSO exceeding max length will be 0
	#
	#add_line "\t\t@nh,16,16 < 160 \\\\";
	#add_line "\t\tlog level warn \\\\";
	#add_line "\t\tlog prefix \"DROP - IPV4 total length is- \" \\\\";
	#add_line "\t\tdrop;";
	#add_line "";
	
	add_line "\t\t@nh,32,16 = 0 \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog prefix \"DROP - IP identification is 0 - \" \\\\";
	add_line "\t\tdrop;";
	add_line "";

	add_line "\t\t@nh,48,1 != 0 \\\\";
	add_line "\t\t#log level warn \\\\";
	add_line "\t\t#log prefix \"DROP - IPV4 invalid flags - bit 0 must be 0 - \" \\\\";
	add_line "\t\t#drop;";
	
	#'Dont fragment' bit
	#add_line "\t\t@nh,49,1 0 \\\\";
	#add_line "\t\t#log level warn \\\\";
	#add_line "\t\t#log prefix \"DROP - IPV4 Flags - Don't fragment bit set/unset - \" \\\\";
	#add_line "\t\t#drop;";
	
	#'More fragments' bit
	#add_line "\t\t@nh,50,1 0 \\\\";
	#add_line "\t\t#log level warn \\\\";
	#add_line "\t\t#log prefix \"DROP - IPV4 Flags - More fragments bit set/unset - \" \\\\";
	#add_line "\t\t#drop;";
	
	#'Dont fragment' bit
	add_line "\t\t@nh,49,1 1 \\\\";
	#'More fragments' bit
	add_line "\t\t@nh,50,1 1 \\\\";
	add_line "\t\t#log level warn \\\\";
	add_line "\t\t#log prefix \"DROP - IPV4 Invalid Flags - DF and MF combined - \" \\\\";
	add_line "\t\t#drop;";

	#'Dont fragments' bit set
	add_line "\t\t@nh,49,1 1 \\\\";
	#'Fragment offset' is not 0
	add_line "\t\t@nh,51,13 != 0 \\\\";
	add_line "\t\t#log level warn \\\\";
	add_line "\t\t#log prefix \"DROP - IPV4 Invalid Fragment - More Fragments is set, and Fragment offset is 0 - \" \\\\";
	add_line "\t\t#drop;";
	add_line "";
	
	#'More fragments' bit set
	add_line "\t\t@nh,50,1 1 \\\\";
	#'Fragment offset' is 0
	add_line "\t\t@nh,51,13 0 \\\\";
	add_line "\t\t#log level warn \\\\";
	add_line "\t\t#log prefix \"DROP - IPV4 Invalid Fragment - More Fragments is set, and Fragment offset is 0 - \" \\\\";
	add_line "\t\t#drop;";
	add_line "";

	add_line "\t\t@nh,64,8 0 \\\\";
	add_line "\t\t#log level warn \\\\";
	add_line "\t\t#log prefix \"DROP - IPV4 invalid TTL - TTL is 0 and the packet has died.- \" \\\\";
	add_line "\t\t#drop;";
	add_line "";
	
	add_line "\t\t@nh,80,16 0 \\\\";
	add_line "\t\t#log level warn \\\\";
	add_line "\t\t#log prefix \"DROP - IPV4 Checksum is 0 - \" \\\\";
	add_line "\t\t#drop;";
	
	#Source Address offset = 96, length 32.
	#Destination Address offset = 128, length 32.
	#Options Offset 160, length ?
}

layer4_restrictions_icmpv4 () {
	#ICMP (RFC792)
	#IP Header size 160 bits
	#ICMP Header size 64 bits
	add_line "\t\tip protocol 1\\\\";
	add_line "\t\tip length < 224 \\\\";
	add_line "\t\tlog level emerg \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 ICMP packet is too small - invalid packet- \" \\\\";
	add_line "\t\tdrop;";
	
	add_line "";

	add_line "\t\tip protocol 1\\\\";
	add_line "\t\ticmp type 8 \\\\";
	add_line "\t\ticmp code != 0 \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 ICMP Echo Request invalid code- \" \\\\";
	add_line "\t\tdrop;";
	
	add_line "";

	add_line "\t\tip protocol 1\\\\";
	add_line "\t\ticmp type 0 \\\\";
	add_line "\t\ticmp code != 0 \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 ICMP Echo Reply invalid code- \" \\\\";
	add_line "\t\tdrop;";
	
	add_line "";
	
	add_line "\t\tip protocol 1\\\\";
	add_line "\t\ticmp type 11 \\\\";
	add_line "\t\ticmp code != { 0, 1 } \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 ICMP Time exceeded invalid code- \" \\\\";
	add_line "\t\tdrop;";
}

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
#match_tcp_flags_cwr_unset();
match_tcp_flags_cwr_unset () {
	add_line "\t\t#TCP CWR unset";
	add_line "\t\t@th,104,1 0 \\\\";
}

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
#match_tcp_flags_cwr_set();
match_tcp_flags_cwr_set () {
	add_line "\t\t#TCP CWR set";
	add_line "\t\t@th,104,1 1 \\\\";
}

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
#tcp_flags_ece_unset();
match_tcp_flags_ece_unset () {
	add_line "\t\t#TCP ECE unset";
	add_line "\t\t@th,105,1 0 \\\\";
}

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
#match_tcp_flags_ece_set();
match_tcp_flags_ece_set () {
	add_line "\t\t#TCP ECE set";
	add_line "\t\t@th,105,1 1 \\\\";
}

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
#match_tcp_flags_urg_unset();
match_tcp_flags_urg_unset () {
	add_line "\t\t#TCP URG unset";
	add_line "\t\t@th,106,1 0 \\\\";
}

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
#match_tcp_flags_urg_set();
match_tcp_flags_urg_set () {
	add_line "\t\t#TCP URG set";
	add_line "\t\t@th,106,1 1 \\\\";
}

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
#match_tcp_flags_ack_unset();
match_tcp_flags_ack_unset () {
	add_line "\t\t#TCP ACK unset";
	add_line "\t\t@th,107,1 0 \\\\";
}

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
#match_tcp_flags_ack_set();
match_tcp_flags_ack_set () {
	add_line "\t\t#TCP ACK set";
	add_line "\t\t@th,107,1 1 \\\\";
}

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
#match_tcp_flags_psh_unset();
match_tcp_flags_psh_unset () {
	add_line "\t\t#TCP PSH unset";
	add_line "\t\t@th,108,1 0 \\\\";
}

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
#match_tcp_flags_psh_set();
match_tcp_flags_psh_set () {
	add_line "\t\t#TCP PSH unset";
	add_line "\t\t@th,108,1 1 \\\\";
}

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
#match_tcp_flags_rst_unset();
match_tcp_flags_rst_unset () {
	add_line "\t\t#TCP RST unset";
	add_line "\t\t@th,109,1 0 \\\\";
}

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
#match_tcp_flags_rst_set();
match_tcp_flags_rst_set () {
	add_line "\t\t#TCP RST set";
	add_line "\t\t@th,109,1 1 \\\\";
}

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
#match_tcp_flags_syn_unset();
match_tcp_flags_syn_unset () {
	add_line "\t\t#TCP SYN unset";
	add_line "\t\t@th,110,1 0 \\\\";
}

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
#match_tcp_flags_syn_set();
match_tcp_flags_syn_set () {
	add_line "\t\t#TCP SYN unset";
	add_line "\t\t@th,110,1 1 \\\\";
}

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
#match_tcp_flags_fin_unset();
match_tcp_flags_fin_unset () {
	add_line "\t\t#TCP FIN unset";
	add_line "\t\t@th,111,1 0 \\\\";
}

#RFC9293 Section 3.1 TCP Flags begin 104 bits offset from TCP header start"
#match_tcp_flags_fin_set();
match_tcp_flags_fin_set () {
	add_line "\t\t#TCP FIN unset";
	add_line "\t\t@th,111,1 1 \\\\";
}

layer4_restrictions_tcp () {
	#RFC9293 Section 3.1 TCP header minimum size is 160 bits (excluding TCP options) 
	#RFC791 Section 3.1 IP Header minimum size 160 bits (excluding IP options)
	add_line "\t\tip protocol 6 \\\\";
	add_line "\t\tip length < 320 \\\\";
	add_line "\t\tlog level emerg \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 TCP packet is too small - invalid packet - \" \\\\";
	add_line "\t\tdrop;";
	
	add_line "";
	
	add_line "\t\tip protocol 6 \\\\";
	add_line "\t\ttcp sport 0 \\\\";
	add_line "\t\tlog level emerg \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 TCP Source Port 0 - invalid packet - \" \\\\";
	add_line "\t\tdrop;";
	
	add_line "";
	
	add_line "\t\tip protocol 6 \\\\";
	add_line "\t\ttcp dport 0 \\\\";
	add_line "\t\tlog level emerg \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 TCP Destination Port 0 - invalid packet - \" \\\\";
	add_line "\t\tdrop;";
	
	add_line "";
	
	add_line "\t\tip protocol 6 \\\\";
	add_line "\t\ttcp sequence 0 \\\\";
	add_line "\t\tlog level emerg \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 TCP Sequence Number 0 - invalid packet - \" \\\\";
	add_line "\t\tdrop;";
	
	add_line "";
	
	add_line "\t\tip protocol 6 \\\\";
	match_tcp_flags_ack_set
	add_line "\t\ttcp ackseq = 0 \\\\";
	add_line "\t\tlog level emerg \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 TCP ACK flag set but ACK number is 0 - invalid packet - \" \\\\";
	add_line "\t\tdrop;";

	add_line "";
	
	add_line "\t\tip protocol 6 \\\\";
	add_line "\t\ttcp doff < 5 \\\\";
	add_line "\t\tlog level emerg \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 TCP header is too small - invalid packet - \" \\\\";
	add_line "\t\tdrop;";
	
	add_line "";
	
	add_line "\t\tip protocol 6 \\\\";
	add_line "\t\t#TCP Reserved bits";
	add_line "\t\t@th,100,4 != 0 \\\\";
	add_line "\t\tlog level emerg \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 TCP reserved bits not 0 - invalid packet - \" \\\\";
	add_line "\t\tdrop;";
	
	add_line "";

	add_line "\t\tip protocol 6 \\\\";
	add_line "\t\t#ALL flags set";
	match_tcp_flags_cwr_set
	match_tcp_flags_ece_set
	match_tcp_flags_urg_set
	match_tcp_flags_ack_set
	match_tcp_flags_psh_set
	match_tcp_flags_rst_set
	match_tcp_flags_syn_set
	match_tcp_flags_fin_set
	add_line "\t\tlog level emerg \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 TCP All flags set - invalid packet - \" \\\\";
	add_line "\t\tdrop;";
	
	add_line "";
	
	add_line "\t\tip protocol 6 \\\\";
	add_line "\t\t#No flags set";
	match_tcp_flags_cwr_unset
	match_tcp_flags_ece_unset
	match_tcp_flags_urg_unset
	match_tcp_flags_ack_unset
	match_tcp_flags_psh_unset
	match_tcp_flags_rst_unset
	match_tcp_flags_syn_unset
	match_tcp_flags_fin_unset
	add_line "\t\tlog level emerg \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 TCP no flags set - invalid packet - \" \\\\";
	add_line "\t\tdrop;";
	
	add_line "";
	
	add_line "\t\tip protocol 6 \\\\";
	match_tcp_flags_rst_set
	add_line "\t\t@th,104,8 > 4 \\\\";
	add_line "\t\tlog level emerg \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 TCP RST not the only flag set - invalid packet - \" \\\\";
	add_line "\t\tdrop;";
	
	add_line "";
	
	add_line "\t\tip protocol 6 \\\\";
	match_tcp_flags_fin_set
	add_line "\t\t@th,104,8 > 1 \\\\";
	add_line "\t\tlog level emerg \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 TCP FIN not the only flag set - invalid packet - \" \\\\";
	add_line "\t\tdrop;";
	
	add_line "";
	
	add_line "\t\tip protocol 6 \\\\";
	add_line "\t\tct state new \\\\";
	match_tcp_flags_syn_unset
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 TCP SYN unset for new connection - invalid packet - \" \\\\";
	add_line "\t\tdrop;";

	add_line "";
	
	add_line "\t\tip protocol 6 \\\\";
	add_line "\t\tct state established \\\\";
	match_tcp_flags_ack_unset
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 TCP ACK unset for existing connection - invalid packet - \" \\\\";
	add_line "\t\tdrop;";
	
	add_line "";
	
	add_line "\t\tip protocol 6 \\\\";
	match_tcp_flags_urg_set
	add_line "\t\t#URG pointer is null";
	add_line "\t\ttcp urgptr 0 \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 TCP URG flag set but URG pointer is null - invalid packet - \" \\\\";
	add_line "\t\tdrop;";
	
	add_line "";
	
	add_line "\t\tip protocol 6 \\\\";
	add_line "\t\ttcp window 0 \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 TCP Window size empty  - invalid packet- \" \\\\";
	add_line "\t\tdrop;";
	
	add_line "";
	
	add_line "\t\tip protocol 6 \\\\";
	add_line "\t\ttcp checksum 0 \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 TCP Checksum empty  - invalid packet- \" \\\\";
	add_line "\t\tdrop;";
	
	add_line "";
	
	add_line "\t\tip protocol 6 \\\\";
	add_line "\t\tct state established \\\\";
	match_tcp_flags_ack_set
	match_tcp_flags_ece_set
	add_line "\t\tlog level audit \\\\";
	add_line "\t\tlog prefix \"IPV4 TCP ACK,ECE- \" \\\\";
	add_line "\t\tcontinue;";
	
	add_line "";
	
	add_line "\t\tip protocol 6 \\\\";
	add_line "\t\tct state established \\\\";
	match_tcp_flags_ack_set
	match_tcp_flags_cwr_set
	add_line "\t\tlog level audit \\\\";
	add_line "\t\tlog prefix \"IPV4 TCP ACK,CWR- \" \\\\";
	add_line "\t\tcontinue;"
}

layer4_restrictions_udp () {
	#UDP (RFC768)
	#Header size 64 bits
	add_line "\t\tip protocol 17\\\\";
	add_line "\t\tip length < 224 \\\\";
	add_line "\t\tlog level emerg \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 UDP packet is too small - invalid packet- \" \\\\";
	add_line "\t\tdrop;";

	add_line "";
	
	add_line "\t\tip protocol 17\\\\";
	add_line "\t\tudp sport 0 \\\\";
	add_line "\t\tlog level emerg \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 UDP Source port 0 - invalid packet- \" \\\\";
	add_line "\t\tdrop;";

	add_line "";
	
	add_line "\t\tip protocol 17\\\\";
	add_line "\t\tudp dport 0 \\\\";
	add_line "\t\tlog level emerg \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 UDP Destination port 0 - invalid packet- \" \\\\";
	add_line "\t\tdrop;";
	
	add_line "";
	
	add_line "\t\tip protocol 17\\\\";
	add_line "\t\tudp length < 8 \\\\";
	add_line "\t\tlog level emerg \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 UDP packet is too small - invalid packet- \" \\\\";
	add_line "\t\tdrop;";
	
	add_line "";
	
	add_line "\t\tip protocol 17\\\\";
	add_line "\t\tudp checksum 0 \\\\";
	add_line "\t\tlog level emerg \\\\";
	add_line "\t\tlog prefix \"DROP - IPV4 UDP Checksum 0 - invalid packet- \" \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_mac_address_multicast (SOURCE_OR_DESTINATION="$1")
block_bogon_mac_address_multicast () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogon_mac_address_ unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tether $ADDR_TYPE & 01:00:00:00:00:00 != 00:00:00:00:00:00 \\\\";
	add_line "\t\tlog prefix \"Block Bogon MAC $SOURCE_OR_DESTINATION Address - Multicast MAC (Most significant octet LSB is 1) - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_mac_address_private (SOURCE_OR_DESTINATION="$1")
block_bogon_mac_address_private () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogon_mac_address_ unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tether $ADDR_TYPE & 02:00:00:00:00:00 != 00:00:00:00:00:00 \\\\";
	add_line "\t\tlog prefix \"Block Bogon MAC $SOURCE_OR_DESTINATION Address - Private MAC (Most significant octet 2nd LSB is 1) - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_mac_address_unspecified (SOURCE_OR_DESTINATION="$1")
block_bogon_mac_address_unspecified () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogon_mac_address_ unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tether $ADDR_TYPE 00:00:00:00:00:00 \\\\";
	add_line "\t\tlog prefix \"Block Bogon MAC $SOURCE_OR_DESTINATION Address - Unspecified MAC 00:00:00:00:00:00 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_mac_address_broadcast (SOURCE_OR_DESTINATION="$1")
block_bogon_mac_address_broadcast () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogon_mac_address_ unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tether $ADDR_TYPE FF:FF:FF:FF:FF:FF \\\\";
	add_line "\t\tlog prefix \"Block Bogon MAC $SOURCE_OR_DESTINATION Address - Broadcast MAC FF:FF:FF:FF:FF:FF - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_mac_address_multicast_ipv4 (SOURCE_OR_DESTINATION="$1")
block_bogon_mac_address_multicast_ipv4 () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogon_mac_address_ unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tether $ADDR_TYPE >= 01:00:5E:00:00:00 \\\\";
	add_line "\t\tether $ADDR_TYPE <= 01:00:5E:7F:FF:FF \\\\";
	add_line "\t\tlog prefix \"Block Bogon MAC $SOURCE_OR_DESTINATION Address - IPV4 Multicast MAC 01:00:5E:00:00:00 - 01:00:5E:7F:FF:FF - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_mac_address_multicast_ipv6 (SOURCE_OR_DESTINATION="$1")
block_bogon_mac_address_multicast_ipv6 () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogon_mac_address_ unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tether $ADDR_TYPE >= 33:33:00:00:00:00 \\\\";
	add_line "\t\tether $ADDR_TYPE <= 33:33:FF:FF:FF:FF \\\\";
	add_line "\t\tlog prefix \"Block Bogon MAC $SOURCE_OR_DESTINATION Address - IPV6 Multicast MAC 33:33:00:00:00:00 - 33:33:FF:FF:FF:FF - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_network_loopback (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_network_loopback () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_LOOPBACK \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - Loopback network 127.0.0.0 - 127.255.255.255 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_network_empty (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_network_empty () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_EMPTY \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - Empty network 0.0.0.0 - 0.255.255.255 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_address_empty (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_address_empty () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_EMPTY \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - Empty address 0.0.0.0 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_network_empty_except_empty_address (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_network_empty_except_empty_address () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_EMPTY_NETS_EXCEPT_EMPTY_ADDRESS \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - Empty address 0.0.0.1 - 0.255.255.255 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_network_link_local (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_network_link_local () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_LINK_LOCAL \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - Link local 169.254.0.0 - 169.254.255.255 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_network_private_10 (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_network_private_10 () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_PRIVATE_10 \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - Private network 10.0.0.0 - 10.255.255.255 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_network_private_172_16 (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_network_private_172_16 () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_PRIVATE_172_16 \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - Private network 172.16.0.0 - 172.31.255.255 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_network_private_192_168 (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_network_private_192_168 () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IP4_NETWORK_PRIVATE_192_168 \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - Private network 192.168.0.0 - 192.168.255.255- \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_network_shared_100_64 (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_network_shared_100_64 () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_SHARED_SPACE \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - Shared network 100.64.0.0 - 100.127.255.255 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_network_multicast (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_network_multicast () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_MULTICAST \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - Multicast network 224.0.0.0 - 255.255.255.255 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_address_broadcast (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_address_broadcast () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_BROADCAST \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - Broadcast 255.255.255.255 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_address_service_continuity (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_address_service_continuity () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_IPV4_SERVICE_CONTINUITY \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - IPV4 Service Continuity 192.0.0.0 - 192.0.0.7 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_address_dummy (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_address_dummy () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_DUMMY_ADDRESS \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - Dummy Address 192.0.0.8 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_address_port_control_protocol_anycast (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_address_port_control_protocol_anycast () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_PORT_CONTROL_PROTOCOL_ANYCAST \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - Port Control Protocol Anycast 192.0.0.9 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_relay_nat_traversal_anycast (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_relay_nat_traversal_anycast () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_RELAY_NAT_TRAVERSAL_ANYCAST \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - NAT Traversal Using Relays 192.0.0.10 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_address_nat_64_discovery (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_address_nat_64_discovery () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_NAT_64_DISCOVERY \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - NAT 64 discovery 192.0.0.170 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_address_dns_64_discovery (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_address_dns_64_discovery () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_DNS_64_DISCOVERY \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - DNS 64 Discovery 192.0.0.171 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_network_ietf_protocol_assignments (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_network_ietf_protocol_assignments () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_IETF_PROTOCOL_ASSIGNMENTS \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - IETF Protocol Assignments 192.0.0.0 - 192.0.0.255 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_network_test_1 (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_network_test_1 () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_TEST_NET_1 \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - Test Network 1 192.0.2.0 - 192.0.2.255 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_network_test_2 (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_network_test_2 () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_TEST_NET_2 \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - Test Network 2 198.51.100.0 - 198.51.100.255 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_network_test_3 (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_network_test_3 () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac

	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_TEST_NET_3 \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - Test Network 3 203.0.113.0 - 203.0.113.255 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_network_as112v4 (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_network_as112v4 () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_AS112_V4 \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - AS112 V4 192.31.196.0 - 192.31.196.255 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_network_as112v4_direct_delegation (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_network_as112v4_direct_delegation () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_AS112_V4_DIRECT_DELEGATION \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - AS112 V4 Direct Delegation 192.175.148.0 - 192.175.148.255 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_network_amt (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_network_amt () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_AMT \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - AMT 192.52.193.0 - 192.52.193.255 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_network_6to4_relay_anycast (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_network_6to4_relay_anycast () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_6TO4_RELAY_ANYCAST \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - 6 to 4 Relay Anycast 192.88.99.0 - 192.88.99.255 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#block_bogon_ipv4_network_benchmarking (SOURCE_OR_DESTINATION="$1")
block_bogon_ipv4_network_benchmarking () {
	SOURCE_OR_DESTINATION="$1";
	ADDR_TYPE="";
	
	case $SOURCE_OR_DESTINATION in
		"SOURCE") ADDR_TYPE="saddr"; ;;
		"DESTINATION") ADDR_TYPE="daddr"; ;;
		*)
			echo "block_bogons_ip4 unrecognised direction; block source or destination? (\"SOURCE\" or \"DESTINATION\")">&2;
			exit 2;
		;;
	esac
	
	add_line "\t\tip $ADDR_TYPE $IPV4_NETWORK_BENCHMARKING \\\\";
	add_line "\t\tlog prefix \"Block Bogon IPV4 $SOURCE_OR_DESTINATION Address - Benchmark networks 198.18.0.0 - 198.19.255.255 - \" \\\\";
	add_line "\t\tlog level warn \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	add_line "\t\tdrop;";
}

#signature_interface (DIR=in|out, INTERFACE_NAME=interface_name);
signature_interface () {
	DIR="$1";
	INTERFACE_NAME="$2";
	
	OPERATION_DESCRIPTION_STRING="layer_1_signature for $DIR $INTERFACE_NAME";
	
	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OPERATION_DESCRIPTION_STRING; unrecognised direction.">&2;
			exit 2;
		;;
	esac

	if [ -z $INTERFACE_NAME ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ $DIR = "IN" ]; then
		add_line "\t\tmeta iifname $INTERFACE_NAME \\\\";
	elif [ $DIR = "OUT" ]; then
		add_line "\t\tmeta oifname $INTERFACE_NAME \\\\";
	fi
}

#signature_mac (ETHER_TYPE_ID="$6", VLAN_ID_DOT1Q="$5", SRC_MAC="$3", DST_MAC="$4");
signature_mac () {
	ETHER_TYPE_ID="$1";
	VLAN_ID_DOT1Q="$2";
	SRC_MAC="$3";
	DST_MAC="$4";
	
	if [ -z $ETHER_TYPE_ID ]; then
		echo "$OPERATION_DESCRIPTION_STRING; ether type id must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_ether_type $ETHER_TYPE_ID)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; ether type id is not valid.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OPERATION_DESCRIPTION_STRING; VLAN ID is invalid.">&2;
			exit 2;
		fi
	
		OPERATION_DESCRIPTION_STRING="layer_2_signature $ETHER_TYPE_ID from $SRC_MAC to $DST_MAC";
	else
		OPERATION_DESCRIPTION_STRING="layer_2_signature $ETHER_TYPE_ID (VLAN $VLAN_ID_DOT1Q) from $SRC_MAC to $DST_MAC";
	fi
	
	if [ -z $SRC_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SRC_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $DST_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $DST_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination MAC is not valid.">&2;
		exit 2;
	fi

	if [ -n $VLAN_ID_DOT1Q ]; then	
		add_line "\t\tether type 0x8100 \\\\";
		add_line "\t\tvlan type $ETHER_TYPE \\\\";
		add_line "\t\tvlan id $VLAN_ID_DOT1Q \\\\";
	else
		add_line "\t\tether type $ETHER_TYPE \\\\";
	fi
	
	add_line "\t\tether saddr $SRC_MAC \\\\";
	add_line "\t\tether daddr $DST_MAC \\\\";
}

#signature_ipv4 (SRC_IP="$1", DST_IP="$2");
signature_ipv4 () {
	SRC_IP="$1";
	DST_IP="$2";
	
	OPERATION_DESCRIPTION_STRING="layer_3_signature from $SRC_IP to $DST_IP";

	if [ -z $SRC_NET ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SRC_NET)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $DST_NET ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $DST_NET)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination address is not valid.">&2;
		exit 2;
	fi

	add_line "\t\tip version 4 \\\\";
	add_line "\t\tip saddr $SRC_IP \\\\";
	add_line "\t\tip daddr $DST_IP \\\\";
}

#signature_protocol (LAYER_4_PROTOCOL_ID="$1", SRC_PORT="$2", DST_PORT="$3");
signature_protocol () {
	LAYER_4_PROTOCOL_ID="$1";
	SRC_PORT="$2";
	DST_PORT="$3";
	
	OPERATION_DESCRIPTION_STRING="log_bad_layer_4_signature from $SRC_MAC:$SRC_IP[$SRC_PORT] to $DST_MAC:$DST_IP[$DST_PORT]";
	
	if [ -z $LAYER_4_PROTOCOL_ID ]; then
		echo "$OPERATION_DESCRIPTION_STRING; layer 4 protocol id must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_layer_4_id $LAYER_4_PROTOCOL_ID)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; layer 4 protocol id is not valid.">&2;
		exit 2;
	fi
	
	LAYER_4_PROTOCOL_NAME=$(layer_4_protocol_id_to_name $LAYER_4_PROTOCOL_ID);
	
	if [ -z $SRC_PORT ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source port must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_port $SRC_PORT)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source port is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $DST_PORT ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination port must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_port $DST_PORT)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination port is not valid.">&2;
		exit 2;
	fi
	
	add_line "\t\tip protocol $LAYER_4_PROTOCOL_ID \\\\";
	add_line "\t\t$LAYER_4_PROTOCOL_NAME sport $SRC_PORT \\\\";
	add_line "\t\t$LAYER_4_PROTOCOL_NAME dport $DST_PORT \\\\";
}

#try_match_arp_probe (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3"|"", SOURCE_MAC="$4"|"", PROBED_ADDRESS="$5");
try_match_arp_probe () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	SOURCE_MAC="$4";
	PROBED_ADDRESS="$5";
	
	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "arp_probe for $PROBED_ADDRESS; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "arp_probe for $PROBED_ADDRESS; interface must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "arp_probe for $PROBED_ADDRESS; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi

	if [ -n $SOURCE_MAC ]; then
		if [ "$(validate_mac_address $SOURCE_MAC)" = "false" ]; then
			echo "arp_probe for $PROBED_ADDRESS; source MAC is not valid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $PROBED_ADDRESS ]; then
		echo "arp_probe for $PROBED_ADDRESS; destination address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $PROBED_ADDRESS)" = "false" ]; then
		echo "arp_probe for $PROBED_ADDRESS; destination address is not valid.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "arp_probe for $PROBED_ADDRESS; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi

	if [ $DIR = "IN" ]; then
		add_line "\t\tmeta iifname $INTERFACE_NAME \\\\";
	elif [ $DIR = "OUT" ]; then
		add_line "\t\tmeta oifname $INTERFACE_NAME \\\\";
	fi

	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0806" $VLAN_ID_DOT1Q $SOURCE_MAC $MAC_BROADCAST
	
	add_line "\t\tarp htype 1 \\\\";
	add_line "\t\tarp hlen 6 \\\\";
	
	add_line "\t\tarp ptype 0x0800 \\\\";
	add_line "\t\tarp plen 4 \\\\";
	
	add_line "\t\tarp operation 1 \\\\";
	
	if [ -z $SRC_MAC ]; then
		add_line "\t\t#arp saddr ether unknown";
	else
		add_line "\t\tarp saddr ether $SOURCE_MAC \\\\";
	fi
	
	add_line "\t\tarp daddr ether $MAC_UNSPECIFIED \\\\";
	
	add_line "\t\tarp saddr ip $IPV4_NETWORK_EMPTY_ADDRESS \\\\";
	add_line "\t\tarp daddr ip $PROBED_ADDRESS \\\\";
	
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog prefix \"$INTERFACE_NAME ARP $DIR IPV4 Probe - Who has this $PROBED_ADDRESS address - \" \\\\";
	add_line "\t\taccept;";
}

#try_match_arp_reply (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SRC_MAC="$4", SRC_NET="$5", DST_MAC="$6", DST_NET="$7");
try_match_arp_reply () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	SRC_MAC="$4";
	SRC_NET="$5";
	DST_MAC="$6";
	DST_NET="$7";
	
	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "arp_reply from $SRC_NET to $DST_NET; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "arp_reply from $SRC_NET to $DST_NET; interface must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "arp_reply from $SRC_NET to $DST_NET; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "arp_reply from $SRC_MAC:$SRC_NET to $DST_MAC:$DST_NET; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SRC_MAC ]; then
		if [ -z $DST_MAC ]; then
			echo "arp_reply from $SRC_MAC to $DST_MAC; either source or destination MAC must be provided.">&2;
			exit 2;
		fi
	fi
	
	if [ -n $SRC_MAC ]; then
		if [ "$(validate_mac_address $SRC_MAC)" = "false" ]; then
			echo "arp_reply from $SRC_MAC and $SRC_NET to $DST_MAC and $DST_NET; source MAC is not valid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SRC_NET ]; then
		echo "arp_reply from $SRC_MAC:$SRC_NET to $DST_MAC:$DST_NET; source NET must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SRC_NET)" = "false" ]; then
		echo "arp_reply from $SRC_MAC:$SRC_NET to $DST_MAC:$DST_NET; source NET is not valid.">&2;
		exit 2;
	fi
	
	if [ -n $DST_MAC ]; then
		if [ "$(validate_mac_address $DST_MAC)" = "false" ]; then
			echo "arp_reply from $SRC_MAC:$SRC_NET to $DST_MAC:$DST_NET; destination MAC is not valid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $DST_NET ]; then
		echo "arp_reply from $SRC_MAC:$SRC_NET to $DST_MAC:$DST_NET; destination NET must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $DST_NET)" = "false" ]; then
		echo "arp_reply from $SRC_MAC:$SRC_NET to $DST_MAC:$DST_NET; destination NET is not valid.">&2;
		exit 2;
	fi

	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0806" $VLAN_ID_DOT1Q $SRC_MAC $DST_MAC
	
	add_line "\t\tarp htype 1 \\\\";
	add_line "\t\tarp hlen 6 \\\\";
	
	add_line "\t\tarp ptype 0x0800 \\\\";
	add_line "\t\tarp plen 4 \\\\";
	
	add_line "\t\tarp operation 2 \\\\";

	if [ -z $SRC_MAC ]; then
		add_line "\t\t#arp saddr ether unknown";
	else
		add_line "\t\tarp saddr ether $SRC_MAC \\\\";
	fi
	
	if [ -z $DST_MAC ]; then
		add_line "\t\t#arp daddr ether unknown";
	else
		add_line "\t\tarp daddr ether $DST_MAC \\\\";
	fi
	
	add_line "\t\tarp saddr ip $SRC_NET \\\\";
	add_line "\t\tarp daddr ip $DST_NET \\\\";
	
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog prefix \"$INTERFACE_NAME ARP $DIR IPV4 Reply - Tell $DST_MAC:$DST_NET I am at $SRC_MAC:$SRC_NET address - \" \\\\";
	add_line "\t\taccept;";
}

#try_match_arp_reply_gratuitous (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SRC_MAC="$4", DST_NET="$5");
try_match_arp_reply_gratuitous () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	SRC_MAC="$4";
	DST_NET="$5";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "arp_reply_gratuitous from $SRC_MAC for $DST_NET; unrecognised direction.">&2;
			exit 2;
		;;
	esac

	if [ -z $INTERFACE_NAME ]; then
		echo "arp_reply_gratuitous from $SRC_MAC for $DST_NET; interface must be provided.">&2;
		exit 2;
	fi	

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "arp_reply_gratuitous from $SRC_MAC for $DST_NET; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "arp_reply_gratuitous from $SRC_MAC:$SRC_NET to $DST_MAC:$DST_NET; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SRC_MAC ]; then
		echo "arp_reply_gratuitous from $SRC_MAC for $DST_NET; source MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SRC_MAC)" = "false" ]; then
		echo "arp_reply_gratuitous from $SRC_MAC for $DST_NET; source MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $DST_NET ]; then
		echo "arp_reply_gratuitous from $SRC_MAC to $DST_NET; destination NET must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $DST_NET)" = "false" ]; then
		echo "arp_reply_gratuitous from $SRC_MAC to $DST_NET; destination NET is not valid.">&2;
		exit 2;
	fi
	
	#################################################################################################################
	# Gratuitous ARP broadcast empty DST MAC
	#################################################################################################################
	
	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0806" $VLAN_ID_DOT1Q $SRC_MAC $MAC_BROADCAST

	add_line "\t\tarp htype 1 \\\\";
	add_line "\t\tarp hlen 6 \\\\";
	
	add_line "\t\tarp ptype 0x0800 \\\\";
	add_line "\t\tarp plen 4 \\\\";
	
	add_line "\t\tarp operation 1 \\\\";
	
	add_line "\t\tarp saddr ether $SRC_MAC \\\\";
	add_line "\t\tarp daddr ether $MAC_UNSPECIFIED \\\\";

	add_line "\t\tarp saddr ip $DST_NET \\\\";
	add_line "\t\tarp daddr ip $DST_NET \\\\";
	
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog prefix \"$INTERFACE_NAME ARP $DIR IPV4 Gratuitous Reply - Broadcast a claim to $DST_NET Address\" \\\\";
	add_line "\t\taccept;";
	
	add_line "";
	
	#################################################################################################################
	# Gratuitous ARP broadcast duplicate SRC and DST MAC
	#################################################################################################################
	
	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0806" $VLAN_ID_DOT1Q $SRC_MAC $MAC_BROADCAST

	add_line "\t\tarp htype 1 \\\\";
	add_line "\t\tarp hlen 6 \\\\";
	
	add_line "\t\tarp ptype 0x0800 \\\\";
	add_line "\t\tarp plen 4 \\\\";
	
	add_line "\t\tarp operation 2 \\\\";
	
	add_line "\t\tarp saddr ether $SRC_MAC \\\\";
	add_line "\t\tarp daddr ether $SRC_MAC \\\\";

	add_line "\t\tarp saddr ip $DST_NET \\\\";
	add_line "\t\tarp daddr ip $DST_NET \\\\";
	
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog prefix \"$INTERFACE_NAME ARP $DIR IPV4 Gratuitous Reply - Broadcast a claim to $DST_NET Address\" \\\\";
	add_line "\t\taccept;";
}

#try_match_icmpv4_port_unreachable(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
try_match_icmpv4_port_unreachable () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	SOURCE_MAC="$4";
	SOURCE_IP="$5";
	SOURCE_PORT="$6";
	DESTINATION_MAC="$7";
	DESTINATION_IP="$8";
	DESTINATION_PORT="$9";
	SERVICE_UID="${10}";
	
	OPERATION_DESCRIPTION_STRING="try_match_icmpv4_port_unreachable";
	
	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OPERATION_DESCRIPTION_STRING; unrecognised direction.">&2;
			exit 2;
		;;
	esac

	if [ -z $INTERFACE_NAME ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface must be provided.">&2;
		exit 2;
	fi	

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OPERATION_DESCRIPTION_STRING; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SOURCE_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SOURCE_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SOURCE_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SOURCE_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $DESTINATION_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $DESTINATION_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $DESTINATION_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $DESTINATION_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination address is not valid.">&2;
		exit 2;
	fi
	
	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $SOURCE_MAC $DESTINATION_MAC
	
	signature_ipv4 $SOURCE_IP $DESTINATION_IP
	
	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi
	
	add_line "\t\tip protocol 1 \\\\";
	
	add_line "\t\t#ICMP Type 3 - Destination Unreachable";
	add_line "\t\t@ih,0,8 3 \\\\";
	
	add_line "\t\t#ICMP Code 3 - Port Unreachable";
	add_line "\t\t@ih,8,8 3 \\\\";
	
	add_line "\t\t#ICMP Checksum (ensure not empty)";
	add_line "\t\t@ih,16,16 != 0 \\\\";
	
	add_line "\t\t#ICMP unused bits (ensure empty)";
	add_line "\t\t@ih,32,32 0 \\\\";

	#TODO: Check that what follows is really the original IPV4 header, and 64 bits of the UDP datagram (also the header)
	#add_line "\t\t";
}

#try_match_ipv4_tcp_fin (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
try_match_ipv4_tcp_fin () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	SOURCE_MAC="$4";
	SOURCE_IP="$5";
	SOURCE_PORT="$6";
	DESTINATION_MAC="$7";
	DESTINATION_IP="$8";
	DESTINATION_PORT="$9";
	SERVICE_UID="${10}";
	
	OPERATION_DESCRIPTION_STRING="try_match_ipv4_tcp_fin";
	
	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OPERATION_DESCRIPTION_STRING; unrecognised direction.">&2;
			exit 2;
		;;
	esac

	if [ -z $INTERFACE_NAME ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface must be provided.">&2;
		exit 2;
	fi	

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OPERATION_DESCRIPTION_STRING; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SOURCE_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SOURCE_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SOURCE_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SOURCE_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SOURCE_PORT ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source port must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_port $SOURCE_PORT)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source port is invalid.">&2;
		exit 2;
	fi
	
	if [ -z $DESTINATION_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $DESTINATION_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $DESTINATION_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $DESTINATION_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $DESTINATION_PORT ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination port must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_port $DESTINATION_PORT)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination port is invalid.">&2;
		exit 2;
	fi
	
	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $SOURCE_MAC $DESTINATION_MAC
	
	signature_ipv4 $SOURCE_IP $DESTINATION_IP
	
	signature_protocol "6" $SOURCE_PORT $DESTINATION_PORT

	match_tcp_flags_cwr_unset
	match_tcp_flags_ece_unset
	match_tcp_flags_urg_unset
	match_tcp_flags_ack_unset
	match_tcp_flags_psh_unset
	match_tcp_flags_rst_unset
	match_tcp_flags_syn_unset
	match_tcp_flags_fin_set
	
	add_line "\t\tct state established \\\\";
	
	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi
	
	add_line "\t\tlog prefix \"ALLOW - IPV4 TCP FIN - \" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	
	add_line "\t\taccept;";
}

#try_match_ipv4_tcp_reset (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
try_match_ipv4_tcp_reset () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	SOURCE_MAC="$4";
	SOURCE_IP="$5";
	SOURCE_PORT="$6";
	DESTINATION_MAC="$7";
	DESTINATION_IP="$8";
	DESTINATION_PORT="$9";
	SERVICE_UID="${10}";
	
	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "arp_reply_gratuitous from $SRC_MAC for $DST_NET; unrecognised direction.">&2;
			exit 2;
		;;
	esac

	if [ -z $INTERFACE_NAME ]; then
		echo "arp_reply_gratuitous from $SRC_MAC for $DST_NET; interface must be provided.">&2;
		exit 2;
	fi	

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "arp_reply_gratuitous from $SRC_MAC for $DST_NET; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "arp_reply_gratuitous from $SRC_MAC:$SRC_NET to $DST_MAC:$DST_NET; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SOURCE_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SOURCE_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SOURCE_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SOURCE_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SOURCE_PORT ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source port must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_port $SOURCE_PORT)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; source port is invalid.">&2;
		exit 2;
	fi
	
	if [ -z $DESTINATION_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $DESTINATION_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $DESTINATION_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $DESTINATION_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $DESTINATION_PORT ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination port must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_port $DESTINATION_PORT)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; destination port is invalid.">&2;
		exit 2;
	fi
	
	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $SOURCE_MAC $DESTINATION_MAC
	
	signature_ipv4 $SOURCE_IP $DESTINATION_IP
	
	signature_protocol "6" $SOURCE_PORT $DESTINATION_PORT

	match_tcp_flags_cwr_unset
	match_tcp_flags_ece_unset
	match_tcp_flags_urg_unset
	match_tcp_flags_ack_unset
	match_tcp_flags_psh_unset
	match_tcp_flags_rst_set
	match_tcp_flags_syn_unset
	match_tcp_flags_fin_unset
	
	add_line "\t\tct state established \\\\";
	
	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi
	
	add_line "\t\tlog prefix \"ALLOW - IPV4 TCP RESET - \" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
	
	add_line "\t\taccept;";
}

#try_match_dhcp_discover (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", REQUESTED_ADDRESS="$5", NETWORK_MULTICAST="$6");
try_match_dhcp_discover () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	CLIENT_MAC="$4";
	REQUESTED_ADDRESS="$5";
	NETWORK_MULTICAST="$6";
	
	OP_DESC_STR="dhcp_discover from $CLIENT_MAC for $REQUESTED_ADDRESS";
	
	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OP_DESC_STR; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OP_DESC_STR; interface must be provided.">&2;
		exit 2;
	fi	

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OP_DESC_STR; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OP_DESC_STR; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi

	if [ -z $CLIENT_MAC ]; then
		echo "$OP_DESC_STR; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $REQUESTED_ADDRESS ]; then
		echo "$OP_DESC_STR; REQUESTED_ADDRESS must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $REQUESTED_ADDRESS)" = "false" ]; then
		echo "$OP_DESC_STR; REQUESTED_ADDRESS is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $NETWORK_MULTICAST ]; then
		echo "$OP_DESC_STR; NETWORK_MULTICAST must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $NETWORK_MULTICAST)" = "false" ]; then
		echo "$OP_DESC_STR; NETWORK_MULTICAST is not valid.">&2;
		exit 2;
	fi

	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $CLIENT_MAC $MAC_BROADCAST
	
	signature_ipv4 $IPV4_NETWORK_EMPTY_ADDRESS $IP4_NETWORK_BROADCAST
	
	signature_protocol "17" $PORT_DHCP_CLIENT $PORT_DHCP_SERVER
	
	add_line "\t\tmeta skuid $DHCP_UID \\\\";
	
	add_line "\t\tudp length < 1500 \\\\";
	
	add_line "\t\t#DHCP OP Code of 1 (BOOTREQUEST)";
	add_line "\t\t@ih,0,8 0x01 \\\\";
	
	add_line "\t\t#HTYPE (Hardware Address Type) (1 Ethernet)";
	add_line "\t\t@ih,8,8 1 \\\\";
	
	add_line "\t\t#HLEN (Hardware Address Length) (6 Segment MAC)";
	add_line "\t\t@ih,16,8 6 \\\\";
	
	add_line "\t\t#HOPS (Client sets to 0, optionally set by relay-agents)";
	add_line "\t\t@ih,24,8 0 \\\\";
	
	add_line "\t\t#XID (Transaction ID, random number chosen by client; to associate client and server requests/responses)";
	add_line "\t\t@ih,32,32 != 0 \\\\";

	add_line "\t\t#SECS (Seconds since the request was made, this is a discover, so no time should have elapsed)";
	add_line "\t\t@ih,64,16 0 \\\\";

	add_line "\t\t#Flags";
	add_line "\t\t#The broadcast bit";
	add_line "\t\t@ih,80,1 1 \\\\";
	
	add_line "\t\t#, followed by 15 zeroes. These must be zeroes as they are reserved for future use.":
	add_line "\t\t#These bits are ignored by servers and relay agents.";
	add_line "\t\t@ih,81,15 0 \\\\";
	
	add_line "\t\t#CIADDR (Client IP Address)";
	add_line "\t\t#Filled in by client in DHCPREQUEST if verifying previously allocated configuration parameters.";
	add_line "\t\t@ih,96,32 0 \\\\";
	
	add_line "\t\t#YIADDR (Your IP address) Your (client) IP address";
	add_line "\t\t@ih,128,32 0 \\\\";
	
	add_line "\t\t#SIADDR (Server IP address) Returned in DHCPOFFER, DHCPACK, DHCPNAK";
	add_line "\t\t@ih,160,32 0 \\\\";

	add_line "\t\t#GIADDR (Relay Agent IP address)";
	add_line "\t\t@ih,192,32 0 \\\\";

	add_line "\t\t#CHADDR (Client Hardware Address)";
	add_line "\t\t#In the case of ethernet, zero. Can be used for things such as Bluetooth.";
	add_line "\t\t#@ih,224,64 0 \\\\";
	
	add_line "\t\t#SNAME (Server name) optional server host name, null terminated string.";
	add_line "\t\t@ih,288,512 0 \\\\";
	
	add_line "\t\t#File (Boot file name), null terminated string.";
	add_line "\t\t#\"generic\" name, or null in DHCPDISCOVER";
	add_line "\t\t#Fully-qualified name in DHCPOFFER";
	add_line "\t\t#@ih,800,1024 0 \\\\";
	
	add_line "\t\t#Options (DHCP Options)";
	add_line "\t\t#DHCP Message Type of 1 (Discover)";

	add_line "\t\tlog prefix \"DHCP Discover Broadcast\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";

	add_line "\t\taccept;";
	
	add_line "";
	
	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $CLIENT_MAC $MAC_BROADCAST
	
	signature_ipv4 $IPV4_NETWORK_EMPTY_ADDRESS $NETWORK_MULTICAST
	
	signature_protocol "17" $PORT_DHCP_CLIENT $PORT_DHCP_SERVER
	
	add_line "\t\tmeta skuid $DHCP_UID \\\\";
	
	add_line "\t\tudp length < 1500 \\\\";

	add_line "\t\t#DHCP OP Code of 1 (BOOTREQUEST)";
	add_line "\t\t@ih,0,8 0x01 \\\\";
	
	add_line "\t\t#HTYPE (Hardware Address Type) (1 Ethernet)";
	add_line "\t\t@ih,8,8 1 \\\\";
	
	add_line "\t\t#HLEN (Hardware Address Length) (6 Segment MAC)";
	add_line "\t\t@ih,16,8 6 \\\\";
	
	add_line "\t\t#HOPS (Client sets to 0, optionally set by relay-agents)";
	add_line "\t\t@ih,24,8 0 \\\\";
	
	add_line "\t\t#XID (Transaction ID, random number chosen by client; to associate client and server requests/responses)";
	add_line "\t\t@ih,32,32 != 0 \\\\";

	add_line "\t\t#SECS (Seconds since the request was made, this is a discover, so no time should have elapsed)";
	add_line "\t\t@ih,64,16 0 \\\\";

	add_line "\t\t#Flags";
	add_line "\t\t#The broadcast bit";
	add_line "\t\t@ih,80,1 1 \\\\";
	
	add_line "\t\t#, followed by 15 zeroes. These must be zeroes as they are reserved for future use.":
	add_line "\t\t#These bits are ignored by servers and relay agents.";
	add_line "\t\t@ih,81,15 0 \\\\";
	
	add_line "\t\t#CIADDR (Client IP Address)";
	add_line "\t\t#Filled in by client in DHCPREQUEST if verifying previously allocated configuration parameters.";
	add_line "\t\t#@ih,96,32 0 \\\\";
	
	add_line "\t\t#YIADDR (Your IP address) Your (client) IP address";
	add_line "\t\t#In the case of DHCPDISCOVER, 0.0.0.0";
	add_line "\t\t@ih,128,32 0 \\\\";
	
	add_line "\t\t#SIADDR (Server IP address) Returned in DHCPOFFER, DHCPACK, DHCPNAK";
	add_line "\t\t@ih,160,32 0 \\\\";

	add_line "\t\t#GIADDR (Relay Agent IP address)";
	add_line "\t\t@ih,192,32 0 \\\\";

	add_line "\t\t#CHADDR (Client Hardware Address)";
	add_line "\t\t#In the case of ethernet, zero. Can be used for things such as Bluetooth.";
	add_line "\t\t#@ih,224,64 0 \\\\";
	
	add_line "\t\t#SNAME (Server name) optional server host name, null terminated string.";
	add_line "\t\t@ih,288,512 0 \\\\";
	
	add_line "\t\t#File (Boot file name), null terminated string.";
	add_line "\t\t#\"generic\" name, or null in DHCPDISCOVER";
	add_line "\t\t#Fully-qualified name in DHCPOFFER";
	add_line "\t\t#@ih,800,1024 0 \\\\";
	
	add_line "\t\t#Options (DHCP Options)";
	add_line "\t\t#DHCP Message Type of 1 (Discover)";

	add_line "\t\tlog prefix \"DHCP Discover Multicast\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";

	add_line "\t\taccept;";
}

#try_match_dhcp_offer (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_ADDR="$5", CLIENT_MAC="$6", CLIENT_NET="$7");
try_match_dhcp_offer () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	SERVER_MAC="$4";
	SERVER_ADDR="$5";
	CLIENT_MAC="$6";
	CLIENT_NET="$7";
	
	OP_DESC_STR="dhcp_offer from $SERVER_MAC:$SERVER_ADDR to $CLIENT_MAC for $CLIENT_ADDR";
	
	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OP_DESC_STR; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OP_DESC_STR; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OP_DESC_STR; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OP_DESC_STR; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi

	if [ -z $SERVER_MAC ]; then
		echo "$OP_DESC_STR; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_ADDR ]; then
		echo "$OP_DESC_STR; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_ADDR)" = "false" ]; then
		echo "$OP_DESC_STR; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OP_DESC_STR; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_ADDR ]; then
		echo "$OP_DESC_STR; client address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $CLIENT_ADDR)" = "false" ]; then
		echo "$OP_DESC_STR; client address is not valid.">&2;
		exit 2;
	fi

	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $SERVER_MAC $CLIENT_MAC
	
	signature_ipv4 $SERVER_ADDR $CLIENT_ADDR
	
	signature_protocol "17" $PORT_DHCP_SERVER $PORT_DHCP_CLIENT
	
	add_line "\t\tmeta skuid $DHCP_UID \\\\";
	
	add_line "\t\tudp length < 1500 \\\\";
	
	add_line "\t\t#DHCP OP Code of 2 (BOOTREPLY)";
	add_line "\t\t@ih,0,8 0x02 \\\\";
	
	add_line "\t\t#HTYPE (Hardware Address Type) (1 Ethernet)";
	add_line "\t\t@ih,8,8 1 \\\\";
	
	add_line "\t\t#HLEN (Hardware Address Length) (6 Segment MAC)";
	add_line "\t\t@ih,16,8 6 \\\\";
	
	add_line "\t\t#HOPS (Client sets to 0, optionally set by relay-agents)";
	add_line "\t\t@ih,24,8 0 \\\\";
	
	add_line "\t\t#XID (Transaction ID, random number chosen by client; to associate client and server requests/responses)";
	add_line "\t\t@ih,32,32 != 0 \\\\";

	add_line "\t\t#SECS (Seconds since the request was made)";
	add_line "\t\t#@ih,64,16 \\\\";

	add_line "\t\t#Flags";
	add_line "\t\t#The broadcast bit";
	add_line "\t\t@ih,80,1 0 \\\\";
	
	add_line "\t\t#, followed by 15 zeroes. These must be zeroes as they are reserved for future use.":
	add_line "\t\t#These bits are ignored by servers and relay agents.";
	add_line "\t\t@ih,81,15 0 \\\\";
	
	add_line "\t\t#CIADDR (Client IP Address)";
	add_line "\t\t#Filled in by client in DHCPREQUEST if verifying previously allocated configuration parameters.";
	add_line "\t\t@ih,96,32 0 \\\\";
	
	add_line "\t\t#YIADDR (Your IP address) Your (client) IP address";
	add_line "\t\t@ih,128,8 $(echo $CLIENT_ADDR | cut -d '.' -f 1) \\\\";
	add_line "\t\t@ih,136,8 $(echo $CLIENT_ADDR | cut -d '.' -f 2) \\\\";
	add_line "\t\t@ih,144,8 $(echo $CLIENT_ADDR | cut -d '.' -f 3) \\\\";
	add_line "\t\t@ih,182,8 $(echo $CLIENT_ADDR | cut -d '.' -f 4) \\\\";
	
	add_line "\t\t#SIADDR (Server IP address) Returned in DHCPOFFER, DHCPACK, DHCPNAK";
	add_line "\t\t@ih,160,8 $(echo $SERVER_ADDR | cut -d '.' -f 1) \\\\";
	add_line "\t\t@ih,168,8 $(echo $SERVER_ADDR | cut -d '.' -f 2) \\\\";
	add_line "\t\t@ih,176,8 $(echo $SERVER_ADDR | cut -d '.' -f 3) \\\\";
	add_line "\t\t@ih,184,8 $(echo $SERVER_ADDR | cut -d '.' -f 4) \\\\";

	add_line "\t\t#GIADDR (Relay Agent IP address)";
	add_line "\t\t@ih,192,32 0 \\\\";

	add_line "\t\t#CHADDR (Client Hardware Address)";
	add_line "\t\t#In the case of ethernet, zero. Can be used for things such as Bluetooth.";
	add_line "\t\t#@ih,224,64 0 \\\\";
	
	add_line "\t\t#SNAME (Server name) optional server host name, null terminated string.";
	add_line "\t\t@ih,288,512 0 \\\\";
	
	add_line "\t\t#File (Boot file name), null terminated string.";
	add_line "\t\t#\"generic\" name, or null in DHCPDISCOVER";
	add_line "\t\t#Fully-qualified name in DHCPOFFER";
	add_line "\t\t#@ih,800,1024 0 \\\\";

	add_line "\t\t#DHCP Message Type of 2 (Offer)";
	
	add_line "\t\tlog prefix \"DHCP Offer\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";

	add_line "\t\taccept;";
}

#try_match_dhcp_request (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", REQUESTED_ADDR="$5", SERVER_ADDR="$6", NET_MULTICAST="$7");
try_match_dhcp_request () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	CLIENT_MAC="$4";
	REQUESTED_ADDR="$5";
	SERVER_ADDR="$6";
	NET_MULTICAST="$7";

	OP_DESC_STR="dhcp_request from $CLIENT_MAC to $SERVER_MAC for $CLIENT_ADDR"
	
	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OP_DESC_STR; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OP_DESC_STR; interface must be provided.">&2;
		exit 2;
	fi	

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OP_DESC_STR; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OP_DESC_STR; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OP_DESC_STR; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $REQUESTED_ADDR ]; then
		echo "$OP_DESC_STR; requested address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $REQUESTED_ADDR)" = "false" ]; then
		echo "$OP_DESC_STR; requested address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_ADDR ]; then
		echo "$OP_DESC_STR; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_ADDR)" = "false" ]; then
		echo "$OP_DESC_STR; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $NET_MULTICAST ]; then
		echo "$OP_DESC_STR; network multicast address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $NET_MULTICAST)" = "false" ]; then
		echo "$OP_DESC_STR; network multicast address is not valid.">&2;
		exit 2;
	fi
	
	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $CLIENT_MAC $MAC_BROADCAST
	
	signature_ipv4 $IPV4_NETWORK_EMPTY_ADDRESS $IP4_NETWORK_BROADCAST
	
	signature_protocol "17" $PORT_DHCP_CLIENT $PORT_DHCP_SERVER
	
	add_line "\t\tmeta skuid $DHCP_UID \\\\";
	
	add_line "\t\tudp length < 1500 \\\\";

	add_line "\t\t#DHCP OP Code of 1 (BOOTREQUEST)";
	add_line "\t\t@ih,0,8 0x01 \\\\";
	
	add_line "\t\t#HTYPE (Hardware Address Type) (1 Ethernet)";
	add_line "\t\t@ih,8,8 1 \\\\";
	
	add_line "\t\t#HLEN (Hardware Address Length) (6 Segment MAC)";
	add_line "\t\t@ih,16,8 6 \\\\";
	
	add_line "\t\t#HOPS (Client sets to 0, optionally set by relay-agents)";
	add_line "\t\t@ih,24,8 0 \\\\";
	
	add_line "\t\t#XID (Transaction ID, random number chosen by client; to associate client and server requests/responses)";
	add_line "\t\t@ih,32,32 != 0 \\\\";

	add_line "\t\t#SECS (Seconds since the request was made)";
	add_line "\t\t#@ih,64,16 0 \\\\";

	add_line "\t\t#Flags";
	add_line "\t\t#The broadcast bit";
	add_line "\t\t@ih,80,1 1 \\\\";
	
	add_line "\t\t#, followed by 15 zeroes. These must be zeroes as they are reserved for future use.":
	add_line "\t\t#These bits are ignored by servers and relay agents.";
	add_line "\t\t@ih,81,15 0 \\\\";
	
	add_line "\t\t#CIADDR (Client IP Address)";
	add_line "\t\t#Filled in by client in DHCPREQUEST if verifying previously allocated configuration parameters.";
	add_line "\t\t@ih,96,8 $(echo $REQUESTED_ADDR | cut -d '.' -f 1) \\\\";
	add_line "\t\t@ih,104,8 $(echo $REQUESTED_ADDR | cut -d '.' -f 2) \\\\";
	add_line "\t\t@ih,112,8 $(echo $REQUESTED_ADDR | cut -d '.' -f 3) \\\\";
	add_line "\t\t@ih,120,8 $(echo $REQUESTED_ADDR | cut -d '.' -f 4) \\\\";
	
	add_line "\t\t#YIADDR (Your IP address) Your (client) IP address";
	add_line "\t\t@ih,128,32 0 \\\\";
	
	add_line "\t\t#SIADDR (Server IP address) Returned in DHCPOFFER, DHCPACK, DHCPNAK";
	add_line "\t\t@ih,160,8 $(echo $SERVER_ADDR | cut -d '.' -f 1) \\\\";
	add_line "\t\t@ih,168,8 $(echo $SERVER_ADDR | cut -d '.' -f 2) \\\\";
	add_line "\t\t@ih,176,8 $(echo $SERVER_ADDR | cut -d '.' -f 3) \\\\";
	add_line "\t\t@ih,184,8 $(echo $SERVER_ADDR | cut -d '.' -f 4) \\\\";

	add_line "\t\t#GIADDR (Relay Agent IP address)";
	add_line "\t\t@ih,192,32 0 \\\\";

	add_line "\t\t#CHADDR (Client Hardware Address)";
	add_line "\t\t#In the case of ethernet, zero. Can be used for things such as Bluetooth.";
	add_line "\t\t#@ih,224,64 0 \\\\";
	
	add_line "\t\t#SNAME (Server name) optional server host name, null terminated string.";
	add_line "\t\t@ih,288,512 0 \\\\";
	
	add_line "\t\t#File (Boot file name), null terminated string.";
	add_line "\t\t#\"generic\" name, or null in DHCPDISCOVER";
	add_line "\t\t#Fully-qualified name in DHCPOFFER";
	add_line "\t\t#@ih,800,1024 0 \\\\";

	add_line "\t\t#DHCP OP Code of 3 (Request)";

	add_line "\t\tlog prefix \"DHCP Request Broadcast\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";

	add_line "\t\taccept;";
	
	add_line "";
	
	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $CLIENT_MAC $MAC_BROADCAST
	
	signature_ipv4 $IPV4_NETWORK_EMPTY_ADDRESS $NETWORK_MULTICAST
	
	signature_protocol "17" $PORT_DHCP_CLIENT $PORT_DHCP_SERVER

	add_line "\t\tmeta skuid $DHCP_UID \\\\";
	
	add_line "\t\tudp length < 1500 \\\\";

	add_line "\t\t#DHCP OP Code of 1 (BOOTREQUEST)";
	add_line "\t\t@ih,0,8 0x01 \\\\";
	
	add_line "\t\t#HTYPE (Hardware Address Type) (1 Ethernet)";
	add_line "\t\t@ih,8,8 1 \\\\";
	
	add_line "\t\t#HLEN (Hardware Address Length) (6 Segment MAC)";
	add_line "\t\t@ih,16,8 6 \\\\";
	
	add_line "\t\t#HOPS (Client sets to 0, optionally set by relay-agents)";
	add_line "\t\t@ih,24,8 0 \\\\";
	
	add_line "\t\t#XID (Transaction ID, random number chosen by client; to associate client and server requests/responses)";
	add_line "\t\t@ih,32,32 != 0 \\\\";

	add_line "\t\t#SECS (Seconds since the request was made)";
	add_line "\t\t#@ih,64,16 0 \\\\";

	add_line "\t\t#Flags";
	add_line "\t\t#The broadcast bit";
	add_line "\t\t@ih,80,1 1 \\\\";
	
	add_line "\t\t#, followed by 15 zeroes. These must be zeroes as they are reserved for future use.":
	add_line "\t\t#These bits are ignored by servers and relay agents.";
	add_line "\t\t@ih,81,15 0 \\\\";
	
	add_line "\t\t#CIADDR (Client IP Address)";
	add_line "\t\t#Filled in by client in DHCPREQUEST if verifying previously allocated configuration parameters.";
	add_line "\t\t@ih,96,8 $(echo $REQUESTED_ADDR | cut -d '.' -f 1) \\\\";
	add_line "\t\t@ih,104,8 $(echo $REQUESTED_ADDR | cut -d '.' -f 2) \\\\";
	add_line "\t\t@ih,112,8 $(echo $REQUESTED_ADDR | cut -d '.' -f 3) \\\\";
	add_line "\t\t@ih,120,8 $(echo $REQUESTED_ADDR | cut -d '.' -f 4) \\\\";
	
	add_line "\t\t#YIADDR (Your IP address) Your (client) IP address";
	add_line "\t\t@ih,128,32 0 \\\\";
	
	add_line "\t\t#SIADDR (Server IP address) Returned in DHCPOFFER, DHCPACK, DHCPNAK";
	add_line "\t\t@ih,160,8 $(echo $SERVER_ADDR | cut -d '.' -f 1) \\\\";
	add_line "\t\t@ih,168,8 $(echo $SERVER_ADDR | cut -d '.' -f 2) \\\\";
	add_line "\t\t@ih,176,8 $(echo $SERVER_ADDR | cut -d '.' -f 3) \\\\";
	add_line "\t\t@ih,184,8 $(echo $SERVER_ADDR | cut -d '.' -f 4) \\\\";

	add_line "\t\t#GIADDR (Relay Agent IP address)";
	add_line "\t\t@ih,192,32 0 \\\\";

	add_line "\t\t#CHADDR (Client Hardware Address)";
	add_line "\t\t#In the case of ethernet, zero. Can be used for things such as Bluetooth.";
	add_line "\t\t#@ih,224,64 0 \\\\";
	
	add_line "\t\t#SNAME (Server name) optional server host name, null terminated string.";
	add_line "\t\t@ih,288,512 0 \\\\";
	
	add_line "\t\t#File (Boot file name), null terminated string.";
	add_line "\t\t#\"generic\" name, or null in DHCPDISCOVER";
	add_line "\t\t#Fully-qualified name in DHCPOFFER";
	add_line "\t\t#@ih,800,1024 0 \\\\";

	add_line "\t\t#DHCP OP Code of 3 (Request)";

	add_line "\t\tlog prefix \"DHCP Request Multicast\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";

	add_line "\t\taccept;";
}

#try_match_dhcp_decline (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", NET_MULTICAST="$5");
try_match_dhcp_decline () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	CLIENT_MAC="$4";
	DECLINED_ADDR="$5";
	NET_MULTICAST="$6";

	OP_DESC_STR="dhcp_decline from $CLIENT_MAC for $CLIENT_ADDR"

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OP_DESC_STR; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OP_DESC_STR; interface must be provided.">&2;
		exit 2;
	fi	

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OP_DESC_STR; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OP_DESC_STR; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OP_DESC_STR; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $DECLINED_ADDR ]; then
		echo "$OP_DESC_STR; declined address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $DECLINED_ADDR)" = "false" ]; then
		echo "$OP_DESC_STR; declined address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $NET_MULTICAST ]; then
		echo "$OP_DESC_STR; network multicast address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $NET_MULTICAST)" = "false" ]; then
		echo "$OP_DESC_STR; network multicast address is not valid.">&2;
		exit 2;
	fi
	
	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $CLIENT_MAC $MAC_BROADCAST
	
	signature_ipv4 $IPV4_NETWORK_EMPTY_ADDRESS $IP4_NETWORK_BROADCAST
	
	signature_protocol "17" $PORT_DHCP_CLIENT $PORT_DHCP_SERVER

	add_line "\t\tmeta skuid $DHCP_UID \\\\";
	
	add_line "\t\tudp length < 1500 \\\\";

	add_line "\t\t#DHCP OP Code of 1 (BOOTREQUEST)";
	add_line "\t\t@ih,0,8 0x01 \\\\";
	
	add_line "\t\t#HTYPE (Hardware Address Type) (1 Ethernet)";
	add_line "\t\t@ih,8,8 1 \\\\";
	
	add_line "\t\t#HLEN (Hardware Address Length) (6 Segment MAC)";
	add_line "\t\t@ih,16,8 6 \\\\";
	
	add_line "\t\t#HOPS (Client sets to 0, optionally set by relay-agents)";
	add_line "\t\t@ih,24,8 0 \\\\";
	
	add_line "\t\t#XID (Transaction ID, random number chosen by client; to associate client and server requests/responses)";
	add_line "\t\t@ih,32,32 != 0 \\\\";

	add_line "\t\t#SECS (Seconds since the request was made)";
	add_line "\t\t#@ih,64,16 0 \\\\";

	add_line "\t\t#Flags";
	add_line "\t\t#The broadcast bit";
	add_line "\t\t@ih,80,1 0 \\\\";
	
	add_line "\t\t#, followed by 15 zeroes. These must be zeroes as they are reserved for future use.":
	add_line "\t\t#These bits are ignored by servers and relay agents.";
	add_line "\t\t@ih,81,15 0 \\\\";
	
	add_line "\t\t#CIADDR (Client IP Address)";
	add_line "\t\t#Filled in by client in DHCPREQUEST if verifying previously allocated configuration parameters.";
	add_line "\t\t@ih,96,8 $(echo $DECLINED_ADDR | cut -d '.' -f 1) \\\\";
	add_line "\t\t@ih,104,8 $(echo $DECLINED_ADDR | cut -d '.' -f 2) \\\\";
	add_line "\t\t@ih,112,8 $(echo $DECLINED_ADDR | cut -d '.' -f 3) \\\\";
	add_line "\t\t@ih,120,8 $(echo $DECLINED_ADDR | cut -d '.' -f 4) \\\\";
	
	add_line "\t\t#YIADDR (Your IP address) Your (client) IP address";
	add_line "\t\t@ih,128,32 0 \\\\";
	
	add_line "\t\t#SIADDR (Server IP address) Returned in DHCPOFFER, DHCPACK, DHCPNAK";
	add_line "\t\t@ih,160,32 0 \\\\";

	add_line "\t\t#GIADDR (Relay Agent IP address)";
	add_line "\t\t@ih,192,32 0 \\\\";

	add_line "\t\t#CHADDR (Client Hardware Address)";
	add_line "\t\t#In the case of ethernet, zero. Can be used for things such as Bluetooth.";
	add_line "\t\t#@ih,224,64 0 \\\\";
	
	add_line "\t\t#SNAME (Server name) optional server host name, null terminated string.";
	add_line "\t\t@ih,288,512 0 \\\\";
	
	add_line "\t\t#File (Boot file name), null terminated string.";
	add_line "\t\t#\"generic\" name, or null in DHCPDISCOVER";
	add_line "\t\t#Fully-qualified name in DHCPOFFER";
	add_line "\t\t#@ih,800,1024 0 \\\\";

	add_line "\t\t#DHCP Message Type of 4 (Decline)";

	add_line "\t\tlog prefix \"DHCP Decline Broadcast\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";

	add_line "\t\taccept;";
	
	add_line "";
	
	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $CLIENT_MAC $MAC_BROADCAST
	
	signature_ipv4 $IPV4_NETWORK_EMPTY_ADDRESS $NETWORK_MULTICAST
	
	signature_protocol "17" $PORT_DHCP_CLIENT $PORT_DHCP_SERVER	

	add_line "\t\tmeta skuid $DHCP_UID \\\\";
	
	add_line "\t\tudp length < 1500 \\\\";
	
	add_line "\t\t#DHCP OP Code of 1 (BOOTREQUEST)";
	add_line "\t\t@ih,0,8 0x01 \\\\";
	
	add_line "\t\t#HTYPE (Hardware Address Type) (1 Ethernet)";
	add_line "\t\t@ih,8,8 1 \\\\";
	
	add_line "\t\t#HLEN (Hardware Address Length) (6 Segment MAC)";
	add_line "\t\t@ih,16,8 6 \\\\";
	
	add_line "\t\t#HOPS (Client sets to 0, optionally set by relay-agents)";
	add_line "\t\t@ih,24,8 0 \\\\";
	
	add_line "\t\t#XID (Transaction ID, random number chosen by client; to associate client and server requests/responses)";
	add_line "\t\t@ih,32,32 != 0 \\\\";

	add_line "\t\t#SECS (Seconds since the request was made)";
	add_line "\t\t#@ih,64,16 0 \\\\";

	add_line "\t\t#Flags";
	add_line "\t\t#The broadcast bit";
	add_line "\t\t@ih,80,1 1 \\\\";
	
	add_line "\t\t#, followed by 15 zeroes. These must be zeroes as they are reserved for future use.":
	add_line "\t\t#These bits are ignored by servers and relay agents.";
	add_line "\t\t@ih,81,15 0 \\\\";
	
	add_line "\t\t#CIADDR (Client IP Address)";
	add_line "\t\t#Filled in by client in DHCPREQUEST if verifying previously allocated configuration parameters.";
	add_line "\t\t@ih,96,8 $(echo $DECLINED_ADDR | cut -d '.' -f 1) \\\\";
	add_line "\t\t@ih,104,8 $(echo $DECLINED_ADDR | cut -d '.' -f 2) \\\\";
	add_line "\t\t@ih,112,8 $(echo $DECLINED_ADDR | cut -d '.' -f 3) \\\\";
	add_line "\t\t@ih,120,8 $(echo $DECLINED_ADDR | cut -d '.' -f 4) \\\\";
	
	add_line "\t\t#YIADDR (Your IP address) Your (client) IP address";
	add_line "\t\t@ih,128,32 0 \\\\";
	
	add_line "\t\t#SIADDR (Server IP address) Returned in DHCPOFFER, DHCPACK, DHCPNAK";
	add_line "\t\t@ih,160,32 0 \\\\";

	add_line "\t\t#GIADDR (Relay Agent IP address)";
	add_line "\t\t@ih,192,32 0 \\\\";

	add_line "\t\t#CHADDR (Client Hardware Address)";
	add_line "\t\t#In the case of ethernet, zero. Can be used for things such as Bluetooth.";
	add_line "\t\t#@ih,224,64 0 \\\\";
	
	add_line "\t\t#SNAME (Server name) optional server host name, null terminated string.";
	add_line "\t\t@ih,288,512 0 \\\\";
	
	add_line "\t\t#File (Boot file name), null terminated string.";
	add_line "\t\t#\"generic\" name, or null in DHCPDISCOVER";
	add_line "\t\t#Fully-qualified name in DHCPOFFER";
	add_line "\t\t#@ih,800,1024 0 \\\\";
	
	add_line "\t\t#DHCP Message Type of 4 (Decline)";
	
	add_line "\t\tlog prefix \"DHCP Decline Multicast\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";

	add_line "\t\taccept;";
}

#try_match_dhcp_ack (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", REQUESTED_IP="$7");
try_match_dhcp_ack () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	SERVER_MAC="$4";
	SERVER_IP="$5";
	CLIENT_MAC="$6";
	REQUESTED_IP="$7";

	OP_DESC_STR="dhcp_ack (permitted) from $SERVER_MAC:$SERVER_IP to $CLIENT_MAC for $REQUESTED_IP";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OP_DESC_STR; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OP_DESC_STR; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OP_DESC_STR; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OP_DESC_STR; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi

	if [ -z $SERVER_MAC ]; then
		echo "$OP_DESC_STR; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OP_DESC_STR; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OP_DESC_STR; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OP_DESC_STR; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $REQUESTED_IP ]; then
		echo "$OP_DESC_STR; requested address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $REQUESTED_IP)" = "false" ]; then
		echo "$OP_DESC_STR; requested address is not valid.">&2;
		exit 2;
	fi
	
	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $SERVER_MAC $CLIENT_MAC
	
	signature_ipv4 $SERVER_IP $REQUESTED_IP
	
	signature_protocol "17" $PORT_DHCP_SERVER $PORT_DHCP_CLIENT

	add_line "\t\tmeta skuid $DHCP_UID \\\\";
	
	add_line "\t\tudp length < 1500 \\\\";
	
	add_line "\t\tDHCP OP Code of 2 (BOOTREPLY)";
	add_line "\t\t@ih,0,8 0x02 \\\\";
	
	add_line "\t\t#HTYPE (Hardware Address Type) (1 Ethernet)";
	add_line "\t\t@ih,8,8 1 \\\\";
	
	add_line "\t\t#HLEN (Hardware Address Length) (6 Segment MAC)";
	add_line "\t\t@ih,16,8 6 \\\\";
	
	add_line "\t\t#HOPS (Client sets to 0, optionally set by relay-agents)";
	add_line "\t\t@ih,24,8 0 \\\\";
	
	add_line "\t\t#XID (Transaction ID, random number chosen by client; to associate client and server requests/responses)";
	add_line "\t\t@ih,32,32 != 0 \\\\";

	add_line "\t\t#SECS (Seconds since the request was made)";
	add_line "\t\t#@ih,64,16 \\\\";

	add_line "\t\t#Flags";
	add_line "\t\t#The broadcast bit";
	add_line "\t\t@ih,80,1 0 \\\\";
	
	add_line "\t\t#, followed by 15 zeroes. These must be zeroes as they are reserved for future use.":
	add_line "\t\t#These bits are ignored by servers and relay agents.";
	add_line "\t\t@ih,81,15 0 \\\\";
	
	add_line "\t\t#CIADDR (Client IP Address)";
	add_line "\t\t#Filled in by client in DHCPREQUEST if verifying previously allocated configuration parameters.";
	add_line "\t\t@ih,96,32 0 \\\\";
	
	add_line "\t\t#YIADDR (Your IP address) Your (client) IP address";
	add_line "\t\t@ih,128,8 $(echo $REQUESTED_IP | cut -d '.' -f 1) \\\\";
	add_line "\t\t@ih,136,8 $(echo $REQUESTED_IP | cut -d '.' -f 2) \\\\";
	add_line "\t\t@ih,144,8 $(echo $REQUESTED_IP | cut -d '.' -f 3) \\\\";
	add_line "\t\t@ih,152,8 $(echo $REQUESTED_IP | cut -d '.' -f 4) \\\\";
	
	add_line "\t\t#SIADDR (Server IP address) Returned in DHCPOFFER, DHCPACK, DHCPNAK";
	add_line "\t\t@ih,160,8 $(echo $SERVER_IP | cut -d '.' -f 1) \\\\";
	add_line "\t\t@ih,168,8 $(echo $SERVER_IP | cut -d '.' -f 2) \\\\";
	add_line "\t\t@ih,176,8 $(echo $SERVER_IP | cut -d '.' -f 3) \\\\";
	add_line "\t\t@ih,184,8 $(echo $SERVER_IP | cut -d '.' -f 4) \\\\";

	add_line "\t\t#GIADDR (Relay Agent IP address)";
	add_line "\t\t@ih,192,32 0 \\\\";

	add_line "\t\t#CHADDR (Client Hardware Address)";
	add_line "\t\t#In the case of ethernet, zero. Can be used for things such as Bluetooth.";
	add_line "\t\t#@ih,224,64 0 \\\\";
	
	add_line "\t\t#SNAME (Server name) optional server host name, null terminated string.";
	add_line "\t\t@ih,288,512 0 \\\\";
	
	add_line "\t\t#File (Boot file name), null terminated string.";
	add_line "\t\t#\"generic\" name, or null in DHCPDISCOVER";
	add_line "\t\t#Fully-qualified name in DHCPOFFER";
	add_line "\t\t#@ih,800,1024 0 \\\\";
	
	add_line "\t\t#DHCP Message Type of 5 (Acknowledge)";
	
	add_line "\t\tlog prefix \"DHCP Acknowledge\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";

	add_line "\t\taccept;";
}

#try_match_dhcp_nak (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", REQUESTED_IP="$7");
try_match_dhcp_nak () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	SERVER_MAC="$4";
	SERVER_IP="$5";
	CLIENT_MAC="$6";
	REQUESTED_IP="$7";

	OP_DESC_STR="dhcp_nak (not permitted) from $SERVER_MAC:$SERVER_IP to $CLIENT_MAC for $REQUESTED_IP";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OP_DESC_STR; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OP_DESC_STR; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OP_DESC_STR; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OP_DESC_STR; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi

	if [ -z $SERVER_MAC ]; then
		echo "$OP_DESC_STR; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OP_DESC_STR; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OP_DESC_STR; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OP_DESC_STR; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $REQUESTED_IP ]; then
		echo "$OP_DESC_STR; requested address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $REQUESTED_IP)" = "false" ]; then
		echo "$OP_DESC_STR; requested address is not valid.">&2;
		exit 2;
	fi
	
	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $SERVER_MAC $CLIENT_MAC
	
	signature_ipv4 $SERVER_IP $CLIENT_IP
	
	signature_protocol "17" $PORT_DHCP_SERVER $PORT_DHCP_CLIENT

	add_line "\t\tmeta skuid $DHCP_UID \\\\";
	
	add_line "\t\tudp length < 1500 \\\\";

	add_line "\t\tDHCP OP Code of 2 (BOOTREPLY)";
	add_line "\t\t@ih,0,8 0x02 \\\\";
	
	add_line "\t\t#HTYPE (Hardware Address Type) (1 Ethernet)";
	add_line "\t\t@ih,8,8 1 \\\\";
	
	add_line "\t\t#HLEN (Hardware Address Length) (6 Segment MAC)";
	add_line "\t\t@ih,16,8 6 \\\\";
	
	add_line "\t\t#HOPS (Client sets to 0, optionally set by relay-agents)";
	add_line "\t\t@ih,24,8 0 \\\\";
	
	add_line "\t\t#XID (Transaction ID, random number chosen by client; to associate client and server requests/responses)";
	add_line "\t\t@ih,32,32 != 0 \\\\";

	add_line "\t\t#SECS (Seconds since the request was made)";
	add_line "\t\t#@ih,64,16 \\\\";

	add_line "\t\t#Flags";
	add_line "\t\t#The broadcast bit";
	add_line "\t\t@ih,80,1 0 \\\\";
	
	add_line "\t\t#, followed by 15 zeroes. These must be zeroes as they are reserved for future use.":
	add_line "\t\t#These bits are ignored by servers and relay agents.";
	add_line "\t\t@ih,81,15 0 \\\\";
	
	add_line "\t\t#CIADDR (Client IP Address)";
	add_line "\t\t#Filled in by client in DHCPREQUEST if verifying previously allocated configuration parameters.";
	add_line "\t\t@ih,96,32 0 \\\\";
	
	add_line "\t\t#YIADDR (Your IP address) Your (client) IP address";
	add_line "\t\t@ih,128,32 0 \\\\";
	
	add_line "\t\t#SIADDR (Server IP address) Returned in DHCPOFFER, DHCPACK, DHCPNAK";
	add_line "\t\t@ih,160,32 0 \\\\";

	add_line "\t\t#GIADDR (Relay Agent IP address)";
	add_line "\t\t@ih,192,32 0 \\\\";

	add_line "\t\t#CHADDR (Client Hardware Address)";
	add_line "\t\t#In the case of ethernet, zero. Can be used for things such as Bluetooth.";
	add_line "\t\t#@ih,224,64 0 \\\\";
	
	add_line "\t\t#SNAME (Server name) optional server host name, null terminated string.";
	add_line "\t\t@ih,288,512 0 \\\\";
	
	add_line "\t\t#File (Boot file name), null terminated string.";
	add_line "\t\t#\"generic\" name, or null in DHCPDISCOVER";
	add_line "\t\t#Fully-qualified name in DHCPOFFER";
	add_line "\t\t#@ih,800,1024 0 \\\\";
	
	add_line "\t\t#DHCP Message Type of 6 (Negative Acknowledge)";
	
	add_line "\t\tlog prefix \"DHCP Negative Acknowledge (NAK)\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";	

	add_line "\t\taccept;";
}

#try_match_dhcp_release (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7");
try_match_dhcp_release () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	CLIENT_MAC="$4";
	CLIENT_IP="$5";
	SERVER_MAC="$6";
	SERVER_IP="$7";
	
	OP_DESC_STR="dhcp_release (remove allocation) from $CLIENT_MAC:$CLIENT_IP to $SERVER_MAC:$SERVER_IP";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OP_DESC_STR; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OP_DESC_STR; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OP_DESC_STR; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OP_DESC_STR; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OP_DESC_STR; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_IP ]; then
		echo "$OP_DESC_STR; client address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $CLIENT_IP)" = "false" ]; then
		echo "$OP_DESC_STR; client address is not valid.">&2;
		exit 2;
	fi

	if [ -z $SERVER_MAC ]; then
		echo "$OP_DESC_STR; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OP_DESC_STR; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OP_DESC_STR; server address is not valid.">&2;
		exit 2;
	fi
	
	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $SERVER_MAC $CLIENT_MAC
	
	signature_ipv4 $CLIENT_IP $SERVER_IP
	
	signature_protocol "17" $PORT_DHCP_CLIENT $PORT_DHCP_SERVER
	
	add_line "\t\tmeta skuid $DHCP_UID \\\\";
	
	add_line "\t\tudp length < 1500 \\\\";

	add_line "\t\t#DHCP OP Code of 1 (BOOTREQUEST)";
	add_line "\t\t@ih,0,8 0x01 \\\\";
	
	add_line "\t\t#HTYPE (Hardware Address Type) (1 Ethernet)";
	add_line "\t\t@ih,8,8 1 \\\\";
	
	add_line "\t\t#HLEN (Hardware Address Length) (6 Segment MAC)";
	add_line "\t\t@ih,16,8 6 \\\\";
	
	add_line "\t\t#HOPS (Client sets to 0, optionally set by relay-agents)";
	add_line "\t\t@ih,24,8 0 \\\\";
	
	add_line "\t\t#XID (Transaction ID, random number chosen by client; to associate client and server requests/responses)";
	add_line "\t\t@ih,32,32 != 0 \\\\";

	add_line "\t\t#SECS (Seconds since the request was made)";
	add_line "\t\t#@ih,64,16 0 \\\\";

	add_line "\t\t#Flags";
	add_line "\t\t#The broadcast bit";
	add_line "\t\t@ih,80,1 0 \\\\";
	
	add_line "\t\t#, followed by 15 zeroes. These must be zeroes as they are reserved for future use.":
	add_line "\t\t#These bits are ignored by servers and relay agents.";
	add_line "\t\t@ih,81,15 0 \\\\";
	
	add_line "\t\t#CIADDR (Client IP Address)";
	add_line "\t\t#Filled in by client in DHCPREQUEST if verifying previously allocated configuration parameters.";
	add_line "\t\t@ih,96,32 0 \\\\";
	
	add_line "\t\t#YIADDR (Your IP address) Your (client) IP address";
	add_line "\t\t@ih,128,32 0 \\\\";
	
	add_line "\t\t#SIADDR (Server IP address) Returned in DHCPOFFER, DHCPACK, DHCPNAK";
	add_line "\t\t@ih,160,32 0 \\\\";

	add_line "\t\t#GIADDR (Relay Agent IP address)";
	add_line "\t\t@ih,192,32 0 \\\\";

	add_line "\t\t#CHADDR (Client Hardware Address)";
	add_line "\t\t#In the case of ethernet, zero. Can be used for things such as Bluetooth.";
	add_line "\t\t#@ih,224,64 0 \\\\";
	
	add_line "\t\t#SNAME (Server name) optional server host name, null terminated string.";
	add_line "\t\t@ih,288,512 0 \\\\";
	
	add_line "\t\t#File (Boot file name), null terminated string.";
	add_line "\t\t#\"generic\" name, or null in DHCPDISCOVER";
	add_line "\t\t#Fully-qualified name in DHCPOFFER";
	add_line "\t\t#@ih,800,1024 0 \\\\";
	
	add_line "\t\t#DHCP Message Type of 7 (Release)";

	add_line "\t\tlog prefix \"DHCP Release\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";

	add_line "\t\taccept;";
}

#try_match_dns_udp_query (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
try_match_dns_udp_query () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	CLIENT_MAC="$4";
	CLIENT_IP="$5";
	SERVER_MAC="$6";
	SERVER_IP="$7";
	SERVICE_UID="$8";
	
	OP_DESC_STR="try_match_dns_udp_query from $CLIENT_MAC:$CLIENT_IP to $SERVER_MAC:$SERVER_IP";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OP_DESC_STR; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OP_DESC_STR; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OP_DESC_STR; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OP_DESC_STR; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OP_DESC_STR; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_IP ]; then
		echo "$OP_DESC_STR; client address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $CLIENT_IP)" = "false" ]; then
		echo "$OP_DESC_STR; client address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_PORT ]; then
		echo "$OP_DESC_STR; client port must be provided.";
	fi
	
	if [ "$(validate_port $CLIENT_PORT)" = "false" ]; then
		echo "$OP_DESC_STR; client port is not valid">&2;
		exit 2;
	fi

	if [ -z $SERVER_MAC ]; then
		echo "$OP_DESC_STR; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OP_DESC_STR; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OP_DESC_STR; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_PORT ]; then
		echo "$OP_DESC_STR; server port must be provided.";
	fi
	
	if [ "$(validate_port $SERVER_PORT)" = "false" ]; then
		echo "$OP_DESC_STR; server port is not valid">&2;
		exit 2;
	fi
	
	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $CLIENT_MAC $SERVER_MAC
	
	signature_ipv4 $CLIENT_IP $SERVER_IP
	
	signature_protocol "17" $PORT_EPHEMERAL $PORT_DNS_SERVER
	
	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi
	
	add_line "\t\t#ID";
	add_line "\t\t@ih,0,16 != 0 \\\\";
	
	add_line "\t\t#Query (0) or Response (1)";
	add_line "\t\t@ih,16,1 0 \\\\";
	
	add_line "\t\t#OPCODE";
	add_line "\t\t@ih,17,4 > -1\\\\";
	add_line "\t\t@ih,17,4 < 3\\\\";
	
	add_line "\t\t#Authoritative Answer";
	add_line "\t\t@ih,21,1 0 \\\\";
	
	add_line "\t\t#Truncation";
	add_line "\t\t#@ih,22,1 - \\\\";
	
	add_line "\t\t#Recursion Desired";
	add_line "\t\t#@ih,23,1 - \\\\";
	
	add_line "\t\t#Recursion Available";
	add_line "\t\t#@ih,24,1 - \\\\";
	
	add_line "\t\t#Reserved bits (0's)";
	add_line "\t\t@ih,25,3 0 \\\\";
	
	add_line "\t\t#Response Code";
	add_line "\t\t@ih,28,4 0 \\\\";
	
	add_line "\t\t#Queried Domain Count";
	add_line "\t\t@ih,32,16 > 0 \\\\";
	
	add_line "\t\t#Answer Count";
	add_line "\t\t@ih,48,16 0 \\\\";
	
	add_line "\t\t#Name Server Count";
	add_line "\t\t@ih,64,16 > -1 \\\\";
	
	add_line "\t\t#Additional Record Count";
	add_line "\t\t@ih,80,16 > -1 \\\\";
	
	add_line "\t\tlog prefix \"IPV4 UDP $DIR $INTERFACE_NAME from $CLIENT_MAC:$CLIENT_IP[$CLIENT_PORT] to $SERVER_MAC:$SERVER_IP[$SERVER_PORT] DNS Request - \" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
}

#try_match_dns_udp_reply(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
try_match_dns_udp_reply () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	SERVER_MAC="$4";
	SERVER_IP="$5";
	CLIENT_MAC="$6";
	CLIENT_IP="$7";
	SERVICE_UID="$8";
	
	OP_DESC_STR="dns_udp_reply from $SERVER_MAC:$SERVER_IP to $CLIENT_MAC:$CLIENT_IP";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OP_DESC_STR; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OP_DESC_STR; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OP_DESC_STR; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OP_DESC_STR; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SERVER_MAC ]; then
		echo "$OP_DESC_STR; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OP_DESC_STR; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OP_DESC_STR; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_PORT ]; then
		echo "$OP_DESC_STR; server port must be provided.";
	fi
	
	if [ "$(validate_port $SERVER_PORT)" = "false" ]; then
		echo "$OP_DESC_STR; server port is not valid">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OP_DESC_STR; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_IP ]; then
		echo "$OP_DESC_STR; client address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $CLIENT_IP)" = "false" ]; then
		echo "$OP_DESC_STR; client address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_PORT ]; then
		echo "$OP_DESC_STR; client port must be provided.";
	fi
	
	if [ "$(validate_port $CLIENT_PORT)" = "false" ]; then
		echo "$OP_DESC_STR; client port is not valid">&2;
		exit 2;
	fi
	
	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $SERVER_MAC $CLIENT_MAC
	
	signature_ipv4 $SERVER_IP $CLIENT_IP
	
	signature_protocol "17" $PORT_DNS_SERVER $PORT_EPHEMERAL	

	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi
	
	add_line "\t\t#ID";
	add_line "\t\t@ih,0,16 != 0 \\\\";
	
	add_line "\t\t#Query (0) or Response (1)";
	add_line "\t\t@ih,16,1 1 \\\\";
	
	add_line "\t\t#OPCODE";
	add_line "\t\t@ih,17,4 > -1\\\\";
	add_line "\t\t@ih,17,4 < 3\\\\";
	
	add_line "\t\t#Authoritative Answer";
	add_line "\t\t#@ih,21,1 - \\\\";
	
	add_line "\t\t#Truncation";
	add_line "\t\t#@ih,22,1 - \\\\";
	
	add_line "\t\t#Recursion Desired";
	add_line "\t\t#@ih,23,1 - \\\\";
	
	add_line "\t\t#Recursion Available";
	add_line "\t\t#@ih,24,1 - \\\\";
	
	add_line "\t\t#Reserved bits (0's)";
	add_line "\t\t@ih,25,3 0 \\\\";
	
	add_line "\t\t#Response Code";
	add_line "\t\t@ih,28,4 > -1 \\\\";
	add_line "\t\t@ih,28,4 < 6 \\\\";
	
	add_line "\t\t#Queried Domain Count";
	add_line "\t\t@ih,32,16 > 0 \\\\";
	
	add_line "\t\t#Answer Count";
	add_line "\t\t@ih,48,16 > -1 \\\\";
	
	add_line "\t\t#Name Server Count";
	add_line "\t\t@ih,64,16 > -1 \\\\";
	
	add_line "\t\t#Additional Record Count";
	add_line "\t\t@ih,80,16 > -1 \\\\";
	
	add_line "\t\tlog prefix \"IPV4 UDP $DIR $INTERFACE_NAME from $SERVER_MAC:$SERVER_IP[$SERVER_PORT] to $CLIENT_MAC:$CLIENT_IP[$CLIENT_PORT] DNS Reply - \" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
}

#try_match_ntp_udp_kiss_of_death (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
try_match_ntp_udp_kiss_of_death () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	SERVER_MAC="$4";
	SERVER_IP="$5";
	CLIENT_MAC="$6";
	CLIENT_IP="$7";
	SERVICE_UID="$8";
	
	OP_DESC_STR="ntp_udp_kiss_of_death (control message) from $SERVER_MAC:$SERVER_IP to $CLIENT_MAC:$CLIENT_IP";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OP_DESC_STR; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OP_DESC_STR; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OP_DESC_STR; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OP_DESC_STR; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SERVER_MAC ]; then
		echo "$OP_DESC_STR; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OP_DESC_STR; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OP_DESC_STR; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OP_DESC_STR; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_IP ]; then
		echo "$OP_DESC_STR; client address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $CLIENT_IP)" = "false" ]; then
		echo "$OP_DESC_STR; client address is not valid.">&2;
		exit 2;
	fi

	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $SERVER_MAC $CLIENT_MAC
	
	signature_ipv4 $SERVER_IP $CLIENT_IP
	
	signature_protocol "17" $PORT_NTP_SERVER $PORT_NTP_CLIENT
	
	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi
	
	add_line "\t\t#Leap Indicator - 0 - no leap, 1 - Todays' last minute has 61secs, 2 - Todays' last minute has 59secs, 3 - Leap unknown! (Clock unsynchronised)";
	add_line "\t\t#@ih,0,2 0 \\\\";
	
	add_line "\t\t#NTP Version 4";
	add_line "\t\t@ih,2,3 4 \\\\";
	
	add_line "\t\t#NTP Mode 0 - reserved, 1 - symmetric active, 2 - symmetric passive, 3 - client, 4 - server, 5 - broadcast, 6 - NTP control channel";
	add_line "\t\t@ih,5,3 6 \\\\";
	
	add_line "\t\t#NTP Stratum 0 (Kiss Of Death packet)";
	add_line "\t\t@ih,8,8 0 \\\\";
	
	add_line "\t\t#NTP Poll (Lower than 5 may be abusive, higher than 10 may be too slow):";
	add_line "\t\t#1: 	 2sec";
	add_line "\t\t#2: 	 4sec";
	add_line "\t\t#3: 	 8sec";
	add_line "\t\t#4: 	 16sec";
	add_line "\t\t#5: 	 32sec";
	add_line "\t\t#6: 	 64sec";
	add_line "\t\t#7: 	 128sec or ~2mins";
	add_line "\t\t#8: 	 256sec or ~4mins";
	add_line "\t\t#9: 	 512sec or ~8.5mins";
	add_line "\t\t#10: 	 1024sec or ~17mins";
	add_line "\t\t#@ih,16,8 > 5 \\\\";
	add_line "\t\t#@ih,16,8 < 11 \\\\";
	
	add_line "\t\t#NTP Precision (Suggested -1 to -16):";
	add_line "\t\t#-1: 	 500.000000ms";
	add_line "\t\t#-2: 	 250.000000ms";
	add_line "\t\t#-3: 	 125.000000ms";
	add_line "\t\t#-4: 	 62.500000ms";
	add_line "\t\t#-5: 	 31.250000ms";
	add_line "\t\t#-6: 	 15.625000ms";
	add_line "\t\t#-7: 	 7.8125000ms";
	add_line "\t\t#-8: 	 3.9062500ms";
	add_line "\t\t#-9: 	 1.9531250ms";
	add_line "\t\t#-10:	 0.9765625ms";
	add_line "\t\t#-11:	 0.4882813ms";
	add_line "\t\t#-12:	 0.2441406ms";
	add_line "\t\t#-13:	 0.1220703ms";
	add_line "\t\t#-14:	 0.0610352ms";
	add_line "\t\t#-15:	 0.0305176ms";
	add_line "\t\t#-16:	 0.0152588ms";
	add_line "\t\t#-17:	 0.0076294ms";
	add_line "\t\t#-18:	 0.0038147ms";
	add_line "\t\t#-19:	 0.0019073ms";
	add_line "\t\t#-20:	 0.0009536ms";
	add_line "\t\t#@ih,24,8 < -8 \\\\";
	add_line "\t\t#@ih,24,8 > -20 \\\\";
	
	add_line "\t\t#NTP Root Delay";
	add_line "\t\t#@ih,32,32 - \\\\";
	
	add_line "\t\t#NTP Root Dispersion";
	add_line "\t\t#@ih,64,32 - \\\\";
	
	add_line "\t\tNTP Reference ID";
	REFERENCE_ID_SET="1145392729,"; #DENY
	REFERENCE_ID_SET="$REFERENCE_ID_SET 1381192786,"; #RSTR
	REFERENCE_ID_SET="$REFERENCE_ID_SET 1380013125,"; #RATE
	#REFERENCE_ID_SET="$REFERENCE_ID_SET 1094931284,"; #ACST
	#REFERENCE_ID_SET="$REFERENCE_ID_SET 1096111176,"; #AUTH
	#REFERENCE_ID_SET="$REFERENCE_ID_SET 1096111183,"; #AUTO
	#REFERENCE_ID_SET="$REFERENCE_ID_SET 1111708500,"; #BCST
	#REFERENCE_ID_SET="$REFERENCE_ID_SET 1129470288,"; #CRYP
	#REFERENCE_ID_SET="$REFERENCE_ID_SET 1146244944,"; #DROP
	#REFERENCE_ID_SET="$REFERENCE_ID_SET 1229867348,"; #INIT
	#REFERENCE_ID_SET="$REFERENCE_ID_SET 1296257876,"; #MCST
	#REFERENCE_ID_SET="$REFERENCE_ID_SET 1313555801,"; #NKEY
	#REFERENCE_ID_SET="$REFERENCE_ID_SET 1380798292,"; #RMOT
	#REFERENCE_ID_SET="$REFERENCE_ID_SET 1398031696"; #STEP
	add_line "\t\t@ih,96,32 { $REFERENCE_ID_SET } \\\\";
	
	#add_line "\t\tNTP Reference ID X code (experimental)";
	#add_line "\t\t#@ih,96,8 88";
	
	add_line "\t\t#NTP Reference Timestamp";
	add_line "\t\t#@ih,128,64  \\\\";
	
	add_line "\t\t#NTP Origin Timestamp";
	add_line "\t\t#@ih,192,64  \\\\";
	
	add_line "\t\t#NTP Receive Timestamp";
	add_line "\t\t#@ih,256,64  \\\\";
	
	add_line "\t\t#NTP Transmit Timestamp";
	add_line "\t\t#@ih,320,64  \\\\";
	
	add_line "\t\tlog prefix \"$DIR $INTERFACE_NAME from $SERVER_MAC:$SERVER_IP to $CLIENT_MAC:$CLIENT_IP - NTP Kiss Of Death (control message)\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
}

#try_match_ntp_udp_stratum_1_request (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
try_match_ntp_udp_stratum_1_request () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	CLIENT_MAC="$4";
	CLIENT_IP="$5";
	SERVER_MAC="$6";
	SERVER_IP="$7";
	SERVICE_UID="$8";

	OP_DESC_STR="ntp_udp_stratum_1 (client request) from $CLIENT_MAC:$CLIENT_IP to $SERVER_MAC:$SERVER_IP";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OP_DESC_STR; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OP_DESC_STR; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OP_DESC_STR; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OP_DESC_STR; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OP_DESC_STR; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_IP ]; then
		echo "$OP_DESC_STR; client address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $CLIENT_IP)" = "false" ]; then
		echo "$OP_DESC_STR; client address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_MAC ]; then
		echo "$OP_DESC_STR; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OP_DESC_STR; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OP_DESC_STR; server address is not valid.">&2;
		exit 2;
	fi

	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $CLIENT_MAC $SERVER_MAC
	
	signature_ipv4 $CLIENT_IP $SERVER_IP
	
	signature_protocol "17" $PORT_EPHEMERAL $PORT_NTP_SERVER	

	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi
	
	add_line "\t\t#Leap Indicator - 0 - no leap, 1 - Todays' last minute has 61secs, 2 - Todays' last minute has 59secs, 3 - Leap unknown! (Clock unsynchronised)";
	add_line "\t\t#@ih,0,2 0 \\\\";
	
	add_line "\t\t#NTP Version 4";
	add_line "\t\t@ih,2,3 4 \\\\";
	
	add_line "\t\t#NTP Mode 0 - reserved, 1 - symmetric active, 2 - symmetric passive, 3 - client, 4 - server, 5 - broadcast, 6 - NTP control channel";
	add_line "\t\t#@ih,5,3 3 \\\\";
	
	add_line "\t\t#NTP Stratum 1";
	add_line "\t\t@ih,8,8 1 \\\\";
	
	add_line "\t\t#NTP Poll (Lower than 5 may be abusive, higher than 10 may be too slow):";
	add_line "\t\t#1: 	 2sec";
	add_line "\t\t#2: 	 4sec";
	add_line "\t\t#3: 	 8sec";
	add_line "\t\t#4: 	 16sec";
	add_line "\t\t#5: 	 32sec";
	add_line "\t\t#6: 	 64sec";
	add_line "\t\t#7: 	 128sec or ~2mins";
	add_line "\t\t#8: 	 256sec or ~4mins";
	add_line "\t\t#9: 	 512sec or ~8.5mins";
	add_line "\t\t#10: 	 1024sec or ~17mins";
	add_line "\t\t@ih,16,8 > 5 \\\\";
	add_line "\t\t@ih,16,8 < 11 \\\\";
	
	add_line "\t\t#NTP Precision (Suggested -1 to -16):";
	add_line "\t\t#-1: 	 500.000000ms";
	add_line "\t\t#-2: 	 250.000000ms";
	add_line "\t\t#-3: 	 125.000000ms";
	add_line "\t\t#-4: 	 62.500000ms";
	add_line "\t\t#-5: 	 31.250000ms";
	add_line "\t\t#-6: 	 15.625000ms";
	add_line "\t\t#-7: 	 7.8125000ms";
	add_line "\t\t#-8: 	 3.9062500ms";
	add_line "\t\t#-9: 	 1.9531250ms";
	add_line "\t\t#-10:	 0.9765625ms";
	add_line "\t\t#-11:	 0.4882813ms";
	add_line "\t\t#-12:	 0.2441406ms";
	add_line "\t\t#-13:	 0.1220703ms";
	add_line "\t\t#-14:	 0.0610352ms";
	add_line "\t\t#-15:	 0.0305176ms";
	add_line "\t\t#-16:	 0.0152588ms";
	add_line "\t\t@ih,24,8 < -1  \\\\";
	add_line "\t\t@ih,24,8 > -16  \\\\";
	
	add_line "\t\t#NTP Root Delay";
	add_line "\t\t#@ih,32,32 - \\\\";
	
	add_line "\t\t#NTP Root Dispersion";
	add_line "\t\t#@ih,64,32 - \\\\";
	
	add_line "\t\t#NTP Reference ID";
	REFERENCE_ID_SET="1196377427,"; 				#GOES - Geosynchronous Orbit Environment Satellite
	REFERENCE_ID_SET="$REFERENCE_ID_SET 4673619,";  		#GPS - Global Positioning System
	REFERENCE_ID_SET="$REFERENCE_ID_SET 5263443,"; 			#PPS - Generic pulse-per-second
	REFERENCE_ID_SET="$REFERENCE_ID_SET 4474445,"; 			#DFM - UTC(DFM)
	if [ $NTP_ENABLE_RARE_CLOCKS = "true" ]; then
		REFERENCE_ID_SET="$REFERENCE_ID_SET 4669772,"; 		#GAL - Galileo Positioning System
		REFERENCE_ID_SET="$REFERENCE_ID_SET 1230129479,"; 	#IRIG - Inter-Range Instrumentation Group
		REFERENCE_ID_SET="$REFERENCE_ID_SET 1465341506,"; 	#WWVB - LF Radio WWVB Ft. Collins, CO 60kHz
		REFERENCE_ID_SET="$REFERENCE_ID_SET 4473670,"; 		#DCF - LF Radio DCF77 Mainflingen, DE 77.5kHz
		REFERENCE_ID_SET="$REFERENCE_ID_SET 4735559,"; 		#HBG - LF Radio HBG Prangins, HB 75kHz
		REFERENCE_ID_SET="$REFERENCE_ID_SET 5067590,"; 		#MSF - LF Radio MSF Anthorn, UK 60kHz
		REFERENCE_ID_SET="$REFERENCE_ID_SET 4868697,"; 		#JJY - LF Radio JJY Fukushima, JP 40kHz
		REFERENCE_ID_SET="$REFERENCE_ID_SET 1280266819,";	#LORC - MF Radio LORAN C Station, 100kHz
		REFERENCE_ID_SET="$REFERENCE_ID_SET 5522502,"; 		#TDF - MF Radio Allouis, FR 162kHz
		REFERENCE_ID_SET="$REFERENCE_ID_SET 4409429,"; 		#CHU - HF Radio CHU Ottawa, Ontario
		REFERENCE_ID_SET="$REFERENCE_ID_SET 5723990,"; 		#WWV - HF Radio WWV Ft. Collins, CO
		REFERENCE_ID_SET="$REFERENCE_ID_SET 1465341512,"; 	#WWVH - HF Radio WWVH Kauai, HI
		REFERENCE_ID_SET="$REFERENCE_ID_SET 1313428308,"; 	#NIST - NIST Telephone modem
		REFERENCE_ID_SET="$REFERENCE_ID_SET 1094931539,"; 	#ACTS - NIST Telephone modem
		REFERENCE_ID_SET="$REFERENCE_ID_SET 1431522895,"; 	#USNO - USNO Telephone modem
		REFERENCE_ID_SET="$REFERENCE_ID_SET 5264450"; 		#PTB - European Telephone modem
	fi
	add_line "\t\t@ih,98,32 { $REFERENCE_ID_SET } \\\\";\
	
	add_line "\t\t#NTP Reference Timestamp";
	add_line "\t\t#@ih,128,64  \\\\";
	
	add_line "\t\t#NTP Origin Timestamp";
	add_line "\t\t#@ih,192,64  \\\\";
	
	add_line "\t\t#NTP Receive Timestamp";
	add_line "\t\t#@ih,256,64  \\\\";
	
	add_line "\t\t#NTP Transmit Timestamp";
	add_line "\t\t#@ih,320,64  \\\\";
	
	add_line "\t\tlog prefix \"$DIR $INTERFACE_NAME from $SERVER_MAC:$SERVER_IP to $CLIENT_MAC:$CLIENT_IP - NTP Server\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
}

#try_match_ntp_udp_stratum_1_response (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
try_match_ntp_udp_stratum_1_response () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	SERVER_MAC="$4";
	SERVER_IP="$5";
	CLIENT_MAC="$6";
	CLIENT_IP="$7";
	SERVICE_UID="$8";

	OP_DESC_STR="ntp_udp_stratum_1_response (server update) from $SERVER_MAC:$SERVER_IP to $CLIENT_MAC:$CLIENT_IP";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OP_DESC_STR; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OP_DESC_STR; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OP_DESC_STR; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OP_DESC_STR; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SERVER_MAC ]; then
		echo "$OP_DESC_STR; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OP_DESC_STR; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OP_DESC_STR; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OP_DESC_STR; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_IP ]; then
		echo "$OP_DESC_STR; client address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $CLIENT_IP)" = "false" ]; then
		echo "$OP_DESC_STR; client address is not valid.">&2;
		exit 2;
	fi

	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $SERVER_MAC $CLIENT_MAC
	
	signature_ipv4 $SERVER_IP $CLIENT_IP
	
	signature_protocol "17" $PORT_NTP_SERVER $PORT_EPHEMERAL	

	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi
	
	add_line "\t\t#Leap Indicator - 0 - no leap, 1 - Todays' last minute has 61secs, 2 - Todays' last minute has 59secs, 3 - Leap unknown! (Clock unsynchronised)";
	add_line "\t\t#@ih,0,2 0 \\\\";
	
	add_line "\t\t#NTP Version 4";
	add_line "\t\t@ih,2,3 4 \\\\";
	
	add_line "\t\t#NTP Mode 0 - reserved, 1 - symmetric active, 2 - symmetric passive, 3 - client, 4 - server, 5 - broadcast, 6 - NTP control channel";
	add_line "\t\t#@ih,5,3 4 \\\\";
	
	add_line "\t\t#NTP Stratum 1";
	add_line "\t\t@ih,8,8 1 \\\\";
	
	add_line "\t\t#NTP Poll (Lower than 5 may be abusive, higher than 10 may be too slow):";
	add_line "\t\t#1: 	 2sec";
	add_line "\t\t#2: 	 4sec";
	add_line "\t\t#3: 	 8sec";
	add_line "\t\t#4: 	 16sec";
	add_line "\t\t#5: 	 32sec";
	add_line "\t\t#6: 	 64sec";
	add_line "\t\t#7: 	 128sec or ~2mins";
	add_line "\t\t#8: 	 256sec or ~4mins";
	add_line "\t\t#9: 	 512sec or ~8.5mins";
	add_line "\t\t#10: 	 1024sec or ~17mins";
	add_line "\t\t@ih,16,8 > 5 \\\\";
	add_line "\t\t@ih,16,8 < 11 \\\\";
	
	add_line "\t\t#NTP Precision (Suggested -1 to -16):";
	add_line "\t\t#-1: 	 500.000000ms";
	add_line "\t\t#-2: 	 250.000000ms";
	add_line "\t\t#-3: 	 125.000000ms";
	add_line "\t\t#-4: 	 62.500000ms";
	add_line "\t\t#-5: 	 31.250000ms";
	add_line "\t\t#-6: 	 15.625000ms";
	add_line "\t\t#-7: 	 7.8125000ms";
	add_line "\t\t#-8: 	 3.9062500ms";
	add_line "\t\t#-9: 	 1.9531250ms";
	add_line "\t\t#-10:	 0.9765625ms";
	add_line "\t\t#-11:	 0.4882813ms";
	add_line "\t\t#-12:	 0.2441406ms";
	add_line "\t\t#-13:	 0.1220703ms";
	add_line "\t\t#-14:	 0.0610352ms";
	add_line "\t\t#-15:	 0.0305176ms";
	add_line "\t\t#-16:	 0.0152588ms";
	add_line "\t\t@ih,24,8 < -1  \\\\";
	add_line "\t\t@ih,24,8 > -16  \\\\";
	
	add_line "\t\t#NTP Root Delay";
	add_line "\t\t#@ih,32,32 - \\\\";
	
	add_line "\t\t#NTP Root Dispersion";
	add_line "\t\t#@ih,64,32 - \\\\";
	
	add_line "\t\t#NTP Reference ID";
	REFERENCE_ID_SET="1196377427,"; 				#GOES - Geosynchronous Orbit Environment Satellite
	REFERENCE_ID_SET="$REFERENCE_ID_SET 4673619,";  		#GPS - Global Positioning System
	REFERENCE_ID_SET="$REFERENCE_ID_SET 5263443,"; 			#PPS - Generic pulse-per-second
	REFERENCE_ID_SET="$REFERENCE_ID_SET 4474445,"; 			#DFM - UTC(DFM)
	if [ $NTP_ENABLE_RARE_CLOCKS = "true" ]; then
		REFERENCE_ID_SET="$REFERENCE_ID_SET 4669772,"; 		#GAL - Galileo Positioning System
		REFERENCE_ID_SET="$REFERENCE_ID_SET 1230129479,"; 	#IRIG - Inter-Range Instrumentation Group
		REFERENCE_ID_SET="$REFERENCE_ID_SET 1465341506,"; 	#WWVB - LF Radio WWVB Ft. Collins, CO 60kHz
		REFERENCE_ID_SET="$REFERENCE_ID_SET 4473670,"; 		#DCF - LF Radio DCF77 Mainflingen, DE 77.5kHz
		REFERENCE_ID_SET="$REFERENCE_ID_SET 4735559,"; 		#HBG - LF Radio HBG Prangins, HB 75kHz
		REFERENCE_ID_SET="$REFERENCE_ID_SET 5067590,"; 		#MSF - LF Radio MSF Anthorn, UK 60kHz
		REFERENCE_ID_SET="$REFERENCE_ID_SET 4868697,"; 		#JJY - LF Radio JJY Fukushima, JP 40kHz
		REFERENCE_ID_SET="$REFERENCE_ID_SET 1280266819,";	#LORC - MF Radio LORAN C Station, 100kHz
		REFERENCE_ID_SET="$REFERENCE_ID_SET 5522502,"; 		#TDF - MF Radio Allouis, FR 162kHz
		REFERENCE_ID_SET="$REFERENCE_ID_SET 4409429,"; 		#CHU - HF Radio CHU Ottawa, Ontario
		REFERENCE_ID_SET="$REFERENCE_ID_SET 5723990,"; 		#WWV - HF Radio WWV Ft. Collins, CO
		REFERENCE_ID_SET="$REFERENCE_ID_SET 1465341512,"; 	#WWVH - HF Radio WWVH Kauai, HI
		REFERENCE_ID_SET="$REFERENCE_ID_SET 1313428308,"; 	#NIST - NIST Telephone modem
		REFERENCE_ID_SET="$REFERENCE_ID_SET 1094931539,"; 	#ACTS - NIST Telephone modem
		REFERENCE_ID_SET="$REFERENCE_ID_SET 1431522895,"; 	#USNO - USNO Telephone modem
		REFERENCE_ID_SET="$REFERENCE_ID_SET 5264450"; 		#PTB - European Telephone modem
	fi
	add_line "\t\t@ih,98,32 { $REFERENCE_ID_SET } \\\\";\
	
	add_line "\t\t#NTP Reference Timestamp";
	add_line "\t\t#@ih,128,64  \\\\";
	
	add_line "\t\t#NTP Origin Timestamp";
	add_line "\t\t#@ih,192,64  \\\\";
	
	add_line "\t\t#NTP Receive Timestamp";
	add_line "\t\t#@ih,256,64  \\\\";
	
	add_line "\t\t#NTP Transmit Timestamp";
	add_line "\t\t#@ih,320,64  \\\\";
	
	add_line "\t\tlog prefix \"$DIR $INTERFACE_NAME from $SERVER_MAC:$SERVER_IP to $CLIENT_MAC:$CLIENT_IP - NTP Server\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
}

#try_match_ntp_udp_stratum_2_or_greater_request (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", REFERENCE_IP="$8"|"", SERVICE_UID="$9");
try_match_ntp_udp_stratum_2_or_greater_request () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	CLIENT_MAC="$4";
	CLIENT_IP="$5";
	SERVER_MAC="$6";
	SERVER_IP="$7";
	REFERENCE_IP="$8";
	SERVICE_UID="$9";
	
	OP_DESC_STR="ntp_udp_stratum_2_or_greater_query (client request) from $CLIENT_MAC:$CLIENT_IP to $SERVER_MAC:$SERVER_IP";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OP_DESC_STR; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OP_DESC_STR; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OP_DESC_STR; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OP_DESC_STR; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SERVER_MAC ]; then
		echo "$OP_DESC_STR; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OP_DESC_STR; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OP_DESC_STR; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OP_DESC_STR; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_IP ]; then
		echo "$OP_DESC_STR; client address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $CLIENT_IP)" = "false" ]; then
		echo "$OP_DESC_STR; client address is not valid.">&2;
		exit 2;
	fi
	
	if [ -n $REFERENCE_IP ]; then
		if [ "$(validate_net_address_ipv4 $REFERENCE_IP)" = "false" ]; then
			echo "$OP_DESC_STR; reference address is not valid.">&2;
			exit 2;
		fi
	fi
	
	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $CLIENT_MAC $SERVER_MAC
	
	signature_ipv4 $CLIENT_IP $SERVER_IP
	
	signature_protocol "17" $PORT_NTP_CLIENT $PORT_NTP_SERVER
	
	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi
	
	add_line "\t\t#Leap Indicator - 0 - no leap, 1 - Todays' last minute has 61secs, 2 - Todays' last minute has 59secs, 3 - Leap unknown! (Clock unsynchronised)";
	add_line "\t\t#@ih,0,2 0 \\\\";
	
	add_line "\t\t#NTP Version 4";
	add_line "\t\t@ih,2,3 4 \\\\";
	
	add_line "\t\t#NTP Mode 0 - reserved, 1 - symmetric active, 2 - symmetric passive, 3 - client, 4 - server, 5 - broadcast, 6 - NTP control channel";
	add_line "\t\t@ih,5,3 3 \\\\"; 
	
	add_line "\t\t#NTP Stratum from 2 to 16";
	add_line "\t\t@ih,8,8 > 1 \\\\";
	add_line "\t\t@ih,8,8 < 17 \\\\";
	
	add_line "\t\t#NTP Poll (Lower than 5 may be abusive, higher than 10 may be too slow):";
	add_line "\t\t#1: 	 2sec";
	add_line "\t\t#2: 	 4sec";
	add_line "\t\t#3: 	 8sec";
	add_line "\t\t#4: 	 16sec";
	add_line "\t\t#5: 	 32sec";
	add_line "\t\t#6: 	 64sec";
	add_line "\t\t#7: 	 128sec or ~2mins";
	add_line "\t\t#8: 	 256sec or ~4mins";
	add_line "\t\t#9: 	 512sec or ~8.5mins";
	add_line "\t\t#10: 	 1024sec or ~17mins";
	add_line "\t\t@ih,16,8 > 5 \\\\";
	add_line "\t\t@ih,16,8 < 11 \\\\";
	
	add_line "\t\t#NTP Precision (Suggested -1 to -16):";
	add_line "\t\t#-1: 	 500.000000ms";
	add_line "\t\t#-2: 	 250.000000ms";
	add_line "\t\t#-3: 	 125.000000ms";
	add_line "\t\t#-4: 	 62.500000ms";
	add_line "\t\t#-5: 	 31.250000ms";
	add_line "\t\t#-6: 	 15.625000ms";
	add_line "\t\t#-7: 	 7.8125000ms";
	add_line "\t\t#-8: 	 3.9062500ms";
	add_line "\t\t#-9: 	 1.9531250ms";
	add_line "\t\t#-10:	 0.9765625ms";
	add_line "\t\t#-11:	 0.4882813ms";
	add_line "\t\t#-12:	 0.2441406ms";
	add_line "\t\t#-13:	 0.1220703ms";
	add_line "\t\t#-14:	 0.0610352ms";
	add_line "\t\t#-15:	 0.0305176ms";
	add_line "\t\t#-16:	 0.0152588ms";
	add_line "\t\t@ih,24,8 < -1  \\\\";
	add_line "\t\t@ih,24,8 > -16  \\\\";
	
	add_line "\t\t#NTP Root Delay";
	add_line "\t\t#@ih,32,32 - \\\\";
	
	add_line "\t\t#NTP Root Dispersion";
	add_line "\t\t#@ih,64,32 - \\\\";
	
	add_line "\t\t#NTP Reference ID";
	if [ -n $REFERENCE_IP ]; then
		add_line "\t\t@ih,96,8 $(echo $REFERENCE_IP | cut -d '.' -f 1) \\\\";
		add_line "\t\t@ih,104,8 $(echo $REFERENCE_IP | cut -d '.' -f 2) \\\\";
		add_line "\t\t@ih,112,8 $(echo $REFERENCE_IP | cut -d '.' -f 3) \\\\";
		add_line "\t\t@ih,120,8 $(echo $REFERENCE_IP | cut -d '.' -f 4) \\\\";
	fi
	
	add_line "\t\tNTP Reference Timestamp";
	add_line "\t\t@ih,128,64  \\\\";
	
	add_line "\t\tNTP Origin Timestamp";
	add_line "\t\t@ih,192,64  \\\\";
	
	add_line "\t\tNTP Receive Timestamp";
	add_line "\t\t@ih,256,64  \\\\";
	
	add_line "\t\tNTP Transmit Timestamp";
	add_line "\t\t@ih,320,64  \\\\";
	
	add_line "\t\tlog prefix \"$DIR $INTERFACE_NAME from $CLIENT_MAC:$CLIENT_IP to $SERVER_MAC:$SERVER_IP - NTP Client request\" \\\\";	

	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
}

#try_match_ntp_udp_stratum_2_or_greater_response (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", REFERENCE_IP="$8"|"", SERVICE_UID="$9");
try_match_ntp_udp_stratum_2_or_greater_response () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	SERVER_MAC="$4";
	SERVER_IP="$5";
	CLIENT_MAC="$6";
	CLIENT_IP="$7";
	REFERENCE_IP="$8";
	SERVICE_UID="$9";
	
	OP_DESC_STR="ntp_udp_stratum_2_or_greater_query (server response) from $CLIENT_MAC:$CLIENT_IP to $SERVER_MAC:$SERVER_IP";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OP_DESC_STR; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OP_DESC_STR; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OP_DESC_STR; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OP_DESC_STR; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SERVER_MAC ]; then
		echo "$OP_DESC_STR; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OP_DESC_STR; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OP_DESC_STR; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OP_DESC_STR; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OP_DESC_STR; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_IP ]; then
		echo "$OP_DESC_STR; client address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $CLIENT_IP)" = "false" ]; then
		echo "$OP_DESC_STR; client address is not valid.">&2;
		exit 2;
	fi
	
	if [ -n $REFERENCE_IP ]; then
		if [ "$(validate_net_address_ipv4 $REFERENCE_IP)" = "false" ]; then
			echo "$OP_DESC_STR; reference address is not valid.">&2;
			exit 2;
		fi
	fi
	
	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $SERVER_MAC $CLIENT_MAC
	
	signature_ipv4 $SERVER_IP $CLIENT_IP
	
	signature_protocol "17" $PORT_NTP_SERVER $PORT_NTP_CLIENT
	
	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi
	
	add_line "\t\t#Leap Indicator - 0 - no leap, 1 - Todays' last minute has 61secs, 2 - Todays' last minute has 59secs, 3 - Leap unknown! (Clock unsynchronised)";
	add_line "\t\t#@ih,0,2 0 \\\\";
	
	add_line "\t\t#NTP Version 4";
	add_line "\t\t@ih,2,3 4 \\\\";
	
	add_line "\t\t#NTP Mode 0 - reserved, 1 - symmetric active, 2 - symmetric passive, 3 - client, 4 - server, 5 - broadcast, 6 - NTP control channel";
	add_line "\t\t@ih,5,3 4 \\\\"; 
	
	add_line "\t\t#NTP Stratum from 2 to 16";
	add_line "\t\t@ih,8,8 > 1 \\\\";
	add_line "\t\t@ih,8,8 < 17 \\\\";
	
	add_line "\t\t#NTP Poll (Lower than 5 may be abusive, higher than 10 may be too slow):";
	add_line "\t\t#1: 	 2sec";
	add_line "\t\t#2: 	 4sec";
	add_line "\t\t#3: 	 8sec";
	add_line "\t\t#4: 	 16sec";
	add_line "\t\t#5: 	 32sec";
	add_line "\t\t#6: 	 64sec";
	add_line "\t\t#7: 	 128sec or ~2mins";
	add_line "\t\t#8: 	 256sec or ~4mins";
	add_line "\t\t#9: 	 512sec or ~8.5mins";
	add_line "\t\t#10: 	 1024sec or ~17mins";
	add_line "\t\t@ih,16,8 > 5 \\\\";
	add_line "\t\t@ih,16,8 < 11 \\\\";
	
	add_line "\t\t#NTP Precision (Suggested -1 to -16):";
	add_line "\t\t#-1: 	 500.000000ms";
	add_line "\t\t#-2: 	 250.000000ms";
	add_line "\t\t#-3: 	 125.000000ms";
	add_line "\t\t#-4: 	 62.500000ms";
	add_line "\t\t#-5: 	 31.250000ms";
	add_line "\t\t#-6: 	 15.625000ms";
	add_line "\t\t#-7: 	 7.8125000ms";
	add_line "\t\t#-8: 	 3.9062500ms";
	add_line "\t\t#-9: 	 1.9531250ms";
	add_line "\t\t#-10:	 0.9765625ms";
	add_line "\t\t#-11:	 0.4882813ms";
	add_line "\t\t#-12:	 0.2441406ms";
	add_line "\t\t#-13:	 0.1220703ms";
	add_line "\t\t#-14:	 0.0610352ms";
	add_line "\t\t#-15:	 0.0305176ms";
	add_line "\t\t#-16:	 0.0152588ms";
	add_line "\t\t@ih,24,8 < -1  \\\\";
	add_line "\t\t@ih,24,8 > -16  \\\\";
	
	add_line "\t\t#NTP Root Delay";
	add_line "\t\t#@ih,32,32 - \\\\";
	
	add_line "\t\t#NTP Root Dispersion";
	add_line "\t\t#@ih,64,32 - \\\\";
	
	add_line "\t\t#NTP Reference ID";
	if [ -n $REFERENCE_IP ]; then
		add_line "\t\t@ih,96,8 $(echo $REFERENCE_IP | cut -d '.' -f 1) \\\\";
		add_line "\t\t@ih,104,8 $(echo $REFERENCE_IP | cut -d '.' -f 2) \\\\";
		add_line "\t\t@ih,112,8 $(echo $REFERENCE_IP | cut -d '.' -f 3) \\\\";
		add_line "\t\t@ih,120,8 $(echo $REFERENCE_IP | cut -d '.' -f 4) \\\\";
	fi
	
	add_line "\t\tNTP Reference Timestamp";
	add_line "\t\t@ih,128,64  \\\\";
	
	add_line "\t\tNTP Origin Timestamp";
	add_line "\t\t@ih,192,64  \\\\";
	
	add_line "\t\tNTP Receive Timestamp";
	add_line "\t\t@ih,256,64  \\\\";
	
	add_line "\t\tNTP Transmit Timestamp";
	add_line "\t\t@ih,320,64  \\\\";
	
	add_line "\t\tlog prefix \"$DIR $INTERFACE_NAME from $SERVER_MAC:$SERVER_IP to $CLIENT_MAC:$CLIENT_IP - NTP Server response\" \\\\";	

	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
}

#try_match_sdns_tcp_query (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
try_match_sdns_tcp_query () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	CLIENT_MAC="$4";
	CLIENT_IP="$5";
	SERVER_MAC="$6";
	SERVER_IP="$7";
	SERVICE_UID="$8";

	OPERATION_DESCRIPTION_STRING="DNS over TLS (client request) from $CLIENT_MAC:$CLIENT_IP to $SERVER_MAC:$SERVER_IP";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OPERATION_DESCRIPTION_STRING; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OPERATION_DESCRIPTION_STRING; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SERVER_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $CLIENT_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address is not valid.">&2;
		exit 2;
	fi
	
	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $CLIENT_MAC $SERVER_MAC
	
	signature_ipv4 $CLIENT_IP $SERVER_IP
	
	signature_protocol "6" $PORT_SDNS_CLIENT $PORT_SDNS_SERVER

	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi

	match_tcp_flags_syn_set
	
	add_line "\t\tct state new \\\\";
	
	add_line "\t\tlog prefix \"SDNS TCP\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
}

#try_match_sdns_tcp_response (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
try_match_sdns_tcp_response () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	CLIENT_MAC="$4";
	CLIENT_IP="$5";
	SERVER_MAC="$6";
	SERVER_IP="$7";
	SERVICE_UID="$8";

	OPERATION_DESCRIPTION_STRING="DNS over TLS (server response) from $CLIENT_MAC:$CLIENT_IP to $SERVER_MAC:$SERVER_IP";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OPERATION_DESCRIPTION_STRING; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OPERATION_DESCRIPTION_STRING; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SERVER_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $CLIENT_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address is not valid.">&2;
		exit 2;
	fi
	
	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $CLIENT_MAC $SERVER_MAC
	
	signature_ipv4 $CLIENT_IP $SERVER_IP
	
	signature_protocol "6" $PORT_SDNS_CLIENT $PORT_SDNS_SERVER

	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi

	match_tcp_flags_ack_set
	
	add_line "\t\tct state established \\\\";
	
	add_line "\t\tlog prefix \"SDNS TCP\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
}

#try_match_http_tcp_request(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
try_match_http_tcp_request () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	SERVER_MAC="$4";
	SERVER_IP="$5";
	CLIENT_MAC="$6";
	CLIENT_IP="$7";
	SERVICE_UID="$8";

	OPERATION_DESCRIPTION_STRING="TCP HTTP (client request) from $CLIENT_MAC:$CLIENT_IP to $SERVER_MAC:$SERVER_IP";
	
	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OPERATION_DESCRIPTION_STRING; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OPERATION_DESCRIPTION_STRING; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SERVER_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $CLIENT_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address is not valid.">&2;
		exit 2;
	fi

	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $CLIENT_MAC $SERVER_MAC
	
	signature_ipv4 $CLIENT_IP $SERVER_IP
	
	signature_protocol "6" $PORT_EPHEMERAL $PORT_HTTP_SERVER

	match_tcp_flags_syn_set
	
	add_line "\t\tct state new \\\\";
	
	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi
	
	add_line "\t\tlog prefix \"TCP HTTP request\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
}

#try_match_http_tcp_response(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
try_match_http_tcp_response () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	SERVER_MAC="$4";
	SERVER_IP="$5";
	CLIENT_MAC="$6";
	CLIENT_IP="$7";
	SERVICE_UID="$8";

	OPERATION_DESCRIPTION_STRING="TCP HTTP (server response) from $CLIENT_MAC:$CLIENT_IP to $SERVER_MAC:$SERVER_IP";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OPERATION_DESCRIPTION_STRING; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OPERATION_DESCRIPTION_STRING; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SERVER_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $CLIENT_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address is not valid.">&2;
		exit 2;
	fi

	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $SERVER_MAC $CLIENT_MAC
	
	signature_ipv4 $SERVER_IP $CLIENT_IP
	
	signature_protocol "6" $PORT_HTTP_SERVER $PORT_EPHEMERAL

	match_tcp_flags_ack_set
	
	add_line "\t\tct state established \\\\";
	
	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi
	
	add_line "\t\tlog prefix \"TCP HTTP response\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
}

#try_match_http_udp_request(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
try_match_http_udp_request () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	CLIENT_MAC="$4";
	CLIENT_IP="$5";
	SERVER_MAC="$6";
	SERVER_IP="$7";
	SERVICE_UID="$8";

	OPERATION_DESCRIPTION_STRING="UDP HTTP (client request) from $CLIENT_MAC:$CLIENT_IP to $SERVER_MAC:$SERVER_IP";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OPERATION_DESCRIPTION_STRING; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OPERATION_DESCRIPTION_STRING; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SERVER_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $CLIENT_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address is not valid.">&2;
		exit 2;
	fi

	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $CLIENT_MAC $SERVER_MAC
	
	signature_ipv4 $CLIENT_IP $SERVER_IP
	
	signature_protocol "17" $PORT_EPHEMERAL $PORT_HTTP_SERVER

	match_tcp_flags_syn_set
	
	add_line "\t\tct state new \\\\";
	
	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi
	
	add_line "\t\tlog prefix \"UDP HTTP request\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
}

#try_match_http_udp_response(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
try_match_http_udp_response () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	SERVER_MAC="$4";
	SERVER_IP="$5";
	CLIENT_MAC="$6";
	CLIENT_IP="$7";
	SERVICE_UID="$8";

	OPERATION_DESCRIPTION_STRING="UDP HTTP (server response) from $SERVER_MAC:$SERVER_IP to $CLIENT_MAC:$CLIENT_IP";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OPERATION_DESCRIPTION_STRING; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OPERATION_DESCRIPTION_STRING; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SERVER_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $CLIENT_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address is not valid.">&2;
		exit 2;
	fi

	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $SERVER_MAC $CLIENT_MAC
	
	signature_ipv4 $SERVER_IP $CLIENT_IP
	
	signature_protocol "17" $PORT_HTTP_SERVER $PORT_EPHEMERAL
	
	match_tcp_flags_ack_set
	
	add_line "\t\tct state established \\\\";
	
	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi
	
	add_line "\t\tlog prefix \"UDP HTTP response\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
}

#try_match_https_tcp_request(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
try_match_https_tcp_request () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	CLIENT_MAC="$4";
	CLIENT_IP="$5";
	SERVER_MAC="$6";
	SERVER_IP="$7";
	SERVICE_UID="$8";

	OPERATION_DESCRIPTION_STRING="TCP HTTPS (client request) from $CLIENT_MAC:$CLIENT_IP to $SERVER_MAC:$SERVER_IP";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OPERATION_DESCRIPTION_STRING; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OPERATION_DESCRIPTION_STRING; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SERVER_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $CLIENT_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address is not valid.">&2;
		exit 2;
	fi

	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $CLIENT_MAC $SERVER_MAC
	
	signature_ipv4 $CLIENT_IP $SERVER_IP
	
	signature_protocol "6" $PORT_EPHEMERAL $PORT_HTTPS_SERVER

	match_tcp_flags_syn_set
	
	add_line "\t\tct state new \\\\";
	
	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi
	
	add_line "\t\tlog prefix \"TCP HTTPS request\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
}

#try_match_https_tcp_response(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
try_match_https_tcp_response () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	SERVER_MAC="$4";
	SERVER_IP="$5";
	CLIENT_MAC="$6";
	CLIENT_IP="$7";
	SERVICE_UID="$8";

	OPERATION_DESCRIPTION_STRING="TCP HTTPS (server response) from $SERVER_MAC:$SERVER_IP to $CLIENT_MAC:$CLIENT_IP";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OPERATION_DESCRIPTION_STRING; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OPERATION_DESCRIPTION_STRING; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SERVER_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $CLIENT_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address is not valid.">&2;
		exit 2;
	fi

	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $SERVER_MAC $CLIENT_MAC
	
	signature_ipv4 $SERVER_IP $CLIENT_IP
	
	signature_protocol "6" $PORT_HTTPS_SERVER $PORT_EPHEMERAL

	match_tcp_flags_ack_set
	
	add_line "\t\tct state established \\\\";
	
	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi
	
	add_line "\t\tlog prefix \"TCP HTTPS response\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
}

#try_match_https_udp_request(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
try_match_https_udp_request () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	CLIENT_MAC="$4";
	CLIENT_IP="$5";
	SERVER_MAC="$6";
	SERVER_IP="$7";
	SERVICE_UID="$8";

	OPERATION_DESCRIPTION_STRING="UDP HTTPS (client request) from $CLIENT_MAC:$CLIENT_IP to $SERVER_MAC:$SERVER_IP";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OPERATION_DESCRIPTION_STRING; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OPERATION_DESCRIPTION_STRING; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SERVER_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $CLIENT_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address is not valid.">&2;
		exit 2;
	fi

	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $CLIENT_MAC $SERVER_MAC
	
	signature_ipv4 $CLIENT_IP $SERVER_IP
	
	signature_protocol "17" $PORT_EPHEMERAL $PORT_HTTPS_SERVER

	match_tcp_flags_syn_set
	
	add_line "\t\tct state new \\\\";
	
	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi
	
	add_line "\t\tlog prefix \"UDP HTTPS request\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
}

#try_match_https_udp_response(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
try_match_https_udp_response () {
	DIR="$1";
	INTERFACE_NAME="$2";
	VLAN_ID_DOT1Q="$3";
	SERVER_MAC="$4";
	SERVER_IP="$5";
	CLIENT_MAC="$6";
	CLIENT_IP="$7";
	SERVICE_UID="$8";

	OPERATION_DESCRIPTION_STRING="UDP HTTPS (server response) from $SERVER_MAC:$SERVER_IP to $CLIENT_MAC:$CLIENT_IP";

	case $DIR in
		"IN") ;;
		"OUT") ;;
		*)
			echo "$OPERATION_DESCRIPTION_STRING; unrecognised direction.">&2;
			exit 2;
		;;
	esac
	
	if [ -z $INTERFACE_NAME ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_interface_by_name $INTERFACE_NAME)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; interface $INTERFACE_NAME does not exist.">&2;
		exit 2;
	fi
	
	if [ -n $VLAN_ID_DOT1Q ]; then
		if [ "$(validate_vlan_id $VLAN_ID_DOT1Q)" = "false" ]; then
			echo "$OPERATION_DESCRIPTION_STRING; VLAN ID is invalid.">&2;
			exit 2;
		fi
	fi
	
	if [ -z $SERVER_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $SERVER_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $SERVER_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $SERVER_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; server address is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_MAC ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC must be provided.">&2;
		exit 2;
	fi

	if [ "$(validate_mac_address $CLIENT_MAC)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client MAC is not valid.">&2;
		exit 2;
	fi
	
	if [ -z $CLIENT_IP ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address must be provided.">&2;
		exit 2;
	fi
	
	if [ "$(validate_net_address_ipv4 $CLIENT_IP)" = "false" ]; then
		echo "$OPERATION_DESCRIPTION_STRING; client address is not valid.">&2;
		exit 2;
	fi

	signature_interface $DIR $INTERFACE_NAME
	
	signature_mac "0x0800" $VLAN_ID_DOT1Q $SERVER_MAC $CLIENT_MAC
	
	signature_ipv4 $SERVER_IP $CLIENT_IP
	
	signature_protocol "17" $PORT_HTTPS_SERVER $PORT_EPHEMERAL
	
	match_tcp_flags_ack_set
	
	add_line "\t\tct state established \\\\";
	
	if [ -n $SERVICE_UID ]; then
		add_line "\t\tmeta skuid $SERVICE_UID \\\\";
	fi
	
	add_line "\t\tlog prefix \"UDP HTTPS response\" \\\\";
	add_line "\t\tlog level notice \\\\";
	add_line "\t\tlog flags skuid flags ether \\\\";
}


#################################################################################################################################################################
#		HELPER FUNCTIONS AVAILABLE															#
#################################################################################################################################################################
#
#	Tools/Helpers (used in other functions)
#
#	get_user_id(ID="0-65536");
#	validate_mac_address(MAC="00:00:00:00:00:00-FF:FF:FF:FF:FF:FF");
#	mac_address_is_private(MAC="00:00:00:00:00:00-FF:FF:FF:FF:FF:FF");
#	mac_address_is_public(MAC="00:00:00:00:00:00-FF:FF:FF:FF:FF:FF");
#	mac_address_is_multicast(MAC="00:00:00:00:00:00-FF:FF:FF:FF:FF:FF");
#	mac_address_is_unicast(MAC="00:00:00:00:00:00-FF:FF:FF:FF:FF:FF");
#	validate_net_address_ipv4(ADDR="0.0.0.0-255.255.255.255");
#	validate_port(PORT="0-65536");
#	validate_interface_by_name(INTERFACE_NAME="someText");
#	validate_interface_by_mac(MAC="00:00:00:00:00:00-FF:FF:FF:FF:FF:FF");
#	validate_vlan_id(VLAN_ID="1-4096");
#	layer_2_protocol_id_verify(ID="0x88A8, 0x8100, 0x0806, 0x0800, 0x86DD");
#	layer_2_protocol_id_to_name(ID="0x88A8, 0x8100, 0x0806, 0x0800, 0x86DD");
#	layer_2_protocol_name_verify(ID="VLAN-S, VLAN-C, ARP, IPV4, IPV6");
#	layer_2_protocol_name_to_id(NAME="VLAN-S, VLAN-C, ARP, IPV4, IPV6");
#	layer_4_protocol_id_verify(ID="1, 6, 17");
#	layer_4_protocol_id_to_name(ID="1, 6, 17");
#	layer_4_protocol_name_verify(NAME="ICMP, TCP, UDP");
#	layer_4_protocol_name_to_id(NAME="ICMP, TCP, UDP");
#
#	Protocol/Header validation
#
#	layer2_restrictions_general();
#	layer3_restrictions_ipv4();
#	layer4_restrictions_icmpv4();
#	match_tcp_flags_cwr_unset();
#	match_tcp_flags_cwr_set();
#	match_tcp_flags_ece_unset();
#	match_tcp_flags_ece_set();
#	match_tcp_flags_urg_unset();
#	match_tcp_flags_urg_set();
#	match_tcp_flags_ack_unset();
#	match_tcp_flags_ack_set();
#	match_tcp_flags_psh_unset();
#	match_tcp_flags_psh_set();
#	match_tcp_flags_rst_unset();
#	match_tcp_flags_rst_set();
#	match_tcp_flags_syn_unset();
#	match_tcp_flags_syn_set();
#	match_tcp_flags_fin_unset();
#	match_tcp_flags_fin_set();
#	layer4_restrictions_tcp();
#	layer4_restrictions_udp();
#
#	MAC Bogons
#
#	block_bogon_mac_address_multicast (SOURCE_OR_DESTINATION="$1")
#	block_bogon_mac_address_private (SOURCE_OR_DESTINATION="$1")
#	block_bogon_mac_address_unspecified (SOURCE_OR_DESTINATION="$1")
#	block_bogon_mac_address_broadcast (SOURCE_OR_DESTINATION="$1")
#	block_bogon_mac_address_multicast_ipv4 (SOURCE_OR_DESTINATION="$1")
#	block_bogon_mac_address_multicast_ipv6 (SOURCE_OR_DESTINATION="$1")
#
#	IPV4 Bogons
#
#	block_bogon_ipv4_network_loopback (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_network_empty (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_address_empty (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_network_empty_except_empty_address (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_network_link_local (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_network_private_10 (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_network_private_172_16 (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_network_shared_100_64 (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_network_multicast (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_address_broadcast (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_address_service_continuity (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_address_dummy (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_address_port_control_protocol_anycast (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_relay_nat_traversal_anycast (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_address_nat_64_discovery (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_address_dns_64_discovery (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_network_ietf_protocol_assignments (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_network_test_1 (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_network_test_2 (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_network_test_3 (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_network_as112v4 (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_network_as112v4_direct_delegation (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_network_amt (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_network_6to4_relay_anycast (SOURCE_OR_DESTINATION="$1")
#	block_bogon_ipv4_network_benchmarking (SOURCE_OR_DESTINATION="$1")
#
#	'Traffic flow' signature only (no packet content validation)
#	Optionally provide a verdict where matching stops, or continue building the filter rule
#	and provide the verdict manually.
#
#	signature_interface (DIR="$1", INTERFACE_NAME="$2");
#	signature_mac (ETHER_TYPE_ID="$6", VLAN_ID_DOT1Q="$5", SRC_MAC="$3", DST_MAC="$4");
#	signature_ipv4 (SRC_IP="$1", DST_IP="$2");
#	signature_protocol (LAYER_4_PROTOCOL_ID="$1", SRC_PORT="$2", DST_PORT="$3");
#
#	ICMP PORT Unreachable (UDP deny) / TCP RST (TCP deny)
#
#	try_match_icmpv4_port_unreachable(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
#	try_match_ipv4_tcp_fin (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
#	try_match_ipv4_tcp_reset (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SOURCE_MAC="$4", SOURCE_IP="$5", SOURCE_PORT="$6", DESTINATION_MAC="$7", DESTINATION_IP="$8", DESTINATION_PORT="$9", SERVICE_UID="$10");
#
#	ARP
#
#	try_match_arp_probe (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3"|"", SOURCE_MAC="$4"|"", PROBED_ADDRESS="$5");
#	try_match_arp_reply (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SRC_MAC="$4", SRC_NET="$5", DST_MAC="$6", DST_NET="$7");
#	try_match_arp_reply_gratuitous (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SRC_MAC="$4", NETADDR="$5");
#
#	DHCP
#
#	try_match_dhcp_discover (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", REQUESTED_ADDRESS="$5", NETWORK_MULTICAST="$6");
#	try_match_dhcp_request (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", REQEUSTED_ADDR="$5", DHCP_SERVER_IP="$6", NET_MULTICAST="$7");
#	try_match_dhcp_decline (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", NET_MULTICAST="$5");
#	try_match_dhcp_release (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7");
#	try_match_dhcp_offer (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_NET="$7");
#	try_match_dhcp_ack (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", REQUESTED_IP="$7");
#	try_match_dhcp_nak (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", REQUESTED_IP="$7");
#
#	DNS
#
#	try_match_dns_udp_reply(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
#	try_match_dns_udp_query (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
#
#	DNS over TLS
#
#	try_match_sdns_tcp_query (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
#	try_match_sdns_tcp_response (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
#
#	NTP
#
#	try_match_ntp_udp_kiss_of_death (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SRC_MAC="$4", SRC_IP="$5", DST_MAC="$6", DST_IP="$7", SERVICE_UID="$8");
#	try_match_ntp_udp_stratum_1_request (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
#	try_match_ntp_udp_stratum_1_response (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
#	try_match_ntp_udp_stratum_2_or_greater_request (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$6", CLIENT_IP="$7", SERVER_MAC="$4", SERVER_IP="$5", REFERENCE_IP="$9"|"", SERVICE_UID="$10");
#	try_match_ntp_udp_stratum_2_or_greater_response (DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", REFERENCE_IP="$9"|"", SERVICE_UID="$10");
#
#	HTTP
#
#	try_match_http_tcp_request(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
#	try_match_http_tcp_response(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
#	try_match_http_udp_request(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
#	try_match_http_udp_response(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
#
#	HTTPS
#
#	try_match_https_tcp_request(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
#	try_match_https_tcp_response(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
#	try_match_https_udp_request(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", CLIENT_MAC="$4", CLIENT_IP="$5", SERVER_MAC="$6", SERVER_IP="$7", SERVICE_UID="$8");
#	try_match_https_udp_response(DIR="$1", INTERFACE_NAME="$2", VLAN_ID_DOT1Q="$3", SERVER_MAC="$4", SERVER_IP="$5", CLIENT_MAC="$6", CLIENT_IP="$7", SERVICE_UID="$8");
#
#################################################################################################################################################################
#		CONFIG FILE BEGIN																#
#################################################################################################################################################################
add_line '#!/usr/sbin/nft -f';
add_line "";
add_line "flush ruleset";
add_line "";

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
layer3_restrictions_ipv4
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
layer3_restrictions_ipv4
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

#apply;
