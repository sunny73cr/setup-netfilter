#!/bin/sh

#Source: https://www.iana.org/assignments/ieee-802-numbers/ieee-802.numbers.xhtml
#Source: https://standards-oui.ieee.org/ethertype/eth.csv
#TODO: Add all ethertypes to the switch case

usage () {
	echo "Usage: $0 --id <string>">&2;
	exit 2;
}

ID="";

while true; do
	case "$1" in
		--id )
			ID="$2";
			#if not enough arguments
			if [ "$#" -lt 2 ]; then usage; else shift 2; fi
		;;
		"" ) break; ;;
		*)
			echo "">&2;
			echo "Unrecognised option: $1 $2">&2;
			usage;
		;;
	esac
done

if [ -z "$ID" ]; then
	echo "$0; you must provide an id (--id <number>).">&2;
	exit 2;
fi

case "$ID" in
	"0x0800") echo "true"; exit 0; ;;						# IP (IPv4)
	"0x0805") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# X25
	"0x0806") echo "true"; exit 0; ;;						# Address Resolution Protocol
	"0x0808") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# Frame Relay ARP [RFC1701]
	"0x08FF") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# G8BPQ AX.25 over Ethernet
	"0x22F3") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# TRILL [RFC6325]
	"0x22F4") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# TRILL L2-IS-IS [RFC6325]
	"0x6558") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# Transparent Ethernet Bridging [RFC1701]
	"0x6559") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# Raw Frame Relay [RFC1701]
	"0x8035") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# Reverse ARP [RFC903]
	"0x809B") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# Appletalk
	"0x80F3") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# Appletalk Address Resolution Protocol
	"0x8137") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# Novell IPX
	"0x8191") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# NetBEUI
	"0x86DD") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# IP version 6
	"0x880B") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# Point-to-Point Protocol
	"0x8847") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# MPLS [RFC5332]
	"0x8848") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# MPLS with upstream-assigned label [RFC5332]
	"0x884C") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# MultiProtocol over ATM
	"0x8863") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# PPP over Ethernet discovery stage
	"0x8864") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# PPP over Ethernet session stage
	"0x8884") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# Frame-based ATM Transport over Ethernet
	"0x888E") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# EAP over LAN [802.1x]
	"0x88C7") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# EAPOL Pre-Authentication [802.11i]
	"0x88CC") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# Link Layer Discovery Protocol [802.1ab]
	"0x88E5") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# Media Access Control Security [802.1ae]
	"0x88E7") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# Provider Backbone Bridging [802.1ah]
	"0x88F5") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# Multiple VLAN Registration Protocol [802.1q]
	"0x88F7") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# Precision Time Protocol
	"0x8906") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# Fibre Channel over Ethernet
	"0x8914") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# FCoE Initialization Protocol
	"0x8915") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# RDMA over Converged Ethernet
	"0xA0ED") echo "$0; unsupported layer 2 protocol">&2; exit 2; ;;	# LoWPAN encapsulation
	"0x8100") echo "true"; exit 0; ;;						# VLAN tagged frame [802.1q]
	"0x88A8") echo "true"; exit 0; ;;						# QinQ Service VLAN tag identifier [802.1q]
	*)
		echo "$0; the layer 2 protocol ID is unrecognised.">&2;
		exit 2;
	;;
esac
