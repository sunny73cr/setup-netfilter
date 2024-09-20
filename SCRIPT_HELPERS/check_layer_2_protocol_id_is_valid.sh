#!/bin/sh

#Source: https://www.iana.org/assignments/ieee-802-numbers/ieee-802.numbers.xhtml
#Source: https://standards-oui.ieee.org/ethertype/eth.csv
#TODO: Add all ethertypes to the switch case

print_usage_then_exit () {
	echo "Usage: $0 --id <string>">&2;
	exit 2;
}

if [ "$1" = "" ]; then print_usage_and_exit; fi

ID="";

while true; do
	case $1 in
		--id)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ] || [ "$(echo $2 | grep -E '^-')" != "" ]; then
				print_usage_then_exit;
			else
				ID=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "Unrecognised argument - ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z "$ID" ]; then
	echo "$0; you must provide an id (--id <number>).">&2;
	exit 2;
fi

case "$ID" in
	"0x0800") exit 0; ;;	# IP (IPv4)
	"0x0805") exit 1; ;;	# X25
	"0x0806") exit 0; ;;	# Address Resolution Protocol
	"0x0808") exit 1; ;;	# Frame Relay ARP [RFC1701]
	"0x08FF") exit 1; ;;	# G8BPQ AX.25 over Ethernet
	"0x22F3") exit 1; ;;	# TRILL [RFC6325]
	"0x22F4") exit 1; ;;	# TRILL L2-IS-IS [RFC6325]
	"0x6558") exit 1; ;;	# Transparent Ethernet Bridging [RFC1701]
	"0x6559") exit 1; ;;	# Raw Frame Relay [RFC1701]
	"0x8035") exit 1; ;;	# Reverse ARP [RFC903]
	"0x809B") exit 1; ;;	# Appletalk
	"0x80F3") exit 1; ;;	# Appletalk Address Resolution Protocol
	"0x8137") exit 1; ;;	# Novell IPX
	"0x8191") exit 1; ;;	# NetBEUI
	"0x86DD") exit 1; ;;	# IP version 6
	"0x880B") exit 1; ;;	# Point-to-Point Protocol
	"0x8847") exit 1; ;;	# MPLS [RFC5332]
	"0x8848") exit 1; ;;	# MPLS with upstream-assigned label [RFC5332]
	"0x884C") exit 1; ;;	# MultiProtocol over ATM
	"0x8863") exit 1; ;;	# PPP over Ethernet discovery stage
	"0x8864") exit 1; ;;	# PPP over Ethernet session stage
	"0x8884") exit 1; ;;	# Frame-based ATM Transport over Ethernet
	"0x888E") exit 1; ;;	# EAP over LAN [802.1x]
	"0x88C7") exit 1; ;;	# EAPOL Pre-Authentication [802.11i]
	"0x88CC") exit 1; ;;	# Link Layer Discovery Protocol [802.1ab]
	"0x88E5") exit 1; ;;	# Media Access Control Security [802.1ae]
	"0x88E7") exit 1; ;;	# Provider Backbone Bridging [802.1ah]
	"0x88F5") exit 1; ;;	# Multiple VLAN Registration Protocol [802.1q]
	"0x88F7") exit 1; ;;	# Precision Time Protocol
	"0x8906") exit 1; ;;	# Fibre Channel over Ethernet
	"0x8914") exit 1; ;;	# FCoE Initialization Protocol
	"0x8915") exit 1; ;;	# RDMA over Converged Ethernet
	"0xA0ED") exit 1; ;;	# LoWPAN encapsulation
	"0x8100") exit 0; ;;	# VLAN tagged frame [802.1q]
	"0x88A8") exit 0; ;;	# QinQ Service VLAN tag identifier [802.1q]
	*)
		echo "$0; the layer 2 protocol ID is unrecognised.">&2;
		exit 2;
	;;
esac
