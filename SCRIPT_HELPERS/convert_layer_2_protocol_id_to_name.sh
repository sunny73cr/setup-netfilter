#!/bin/sh

print_usage_then_exit () {
	printf "Usage: $0 <argument>\n">&2;
	printf " --id 0xYYYY (where Y is A-F, or 0-9).\n">&2;
	printf "\n">&2;
	exit 2;
}

ID="";

while true; do
	case $1 in
		--id)
			if [ $# -lt 2 ]; then
				print_usage_then_exit;
			elif [ "$2" = "" ]; then
				print_usage_then_exit;
			else
				ID=$2;
				shift 2;
			fi
		;;
		"") break; ;;
		*) printf "Unrecognised argument $1. ">&2; print_usage_then_exit; ;;
	esac
done

if [ -z $ID ]; then
	echo "\nMissing --id. ">&2;
	print_usage_then_exit;
fi

case $ID in
	"0x0800") echo "IPV4"; exit 0; ;; 	# IP (IPv4)
	"0x0805") echo exit 1; ;;		# X25
	"0x0806") echo "ARP"; exit 0; ;;	# Address Resolution Protocol
	"0x0808") echo exit 1; ;;		# Frame Relay ARP [RFC1701]
	"0x08FF") echo exit 1; ;;		# G8BPQ AX.25 over Ethernet
	"0x22F3") echo exit 1; ;;		# TRILL [RFC6325]
	"0x22F4") echo exit 1; ;;		# TRILL L2-IS-IS [RFC6325]
	"0x6558") echo exit 1; ;;		# Transparent Ethernet Bridging [RFC1701]
	"0x6559") echo exit 1; ;;		# Raw Frame Relay [RFC1701]
	"0x8035") echo exit 1; ;;		# Reverse ARP [RFC903]
	"0x809B") echo exit 1; ;;		# Appletalk
	"0x80F3") echo exit 1; ;;		# Appletalk Address Resolution Protocol
	"0x8137") echo exit 1; ;;		# Novell IPX
	"0x8191") echo exit 1; ;;		# NetBEUI
	"0x86DD") echo "IPV6"; exit 0; ;;	# IP version 6
	"0x880B") echo exit 1; ;;		# Point-to-Point Protocol
	"0x8847") echo exit 1; ;;		# MPLS [RFC5332]
	"0x8848") echo exit 1; ;;		# MPLS with upstream-assigned label [RFC5332]
	"0x884C") echo exit 1; ;;		# MultiProtocol over ATM
	"0x8863") echo exit 1; ;;		# PPP over Ethernet discovery stage
	"0x8864") echo exit 1; ;;		# PPP over Ethernet session stage
	"0x8884") echo exit 1; ;;		# Frame-based ATM Transport over Ethernet
	"0x888E") echo exit 1; ;;		# EAP over LAN [802.1x]
	"0x88C7") echo exit 1; ;;		# EAPOL Pre-Authentication [802.11i]
	"0x88CC") echo exit 1; ;;		# Link Layer Discovery Protocol [802.1ab]
	"0x88E5") echo exit 1; ;;		# Media Access Control Security [802.1ae]
	"0x88E7") echo exit 1; ;;		# Provider Backbone Bridging [802.1ah]
	"0x88F5") echo exit 1; ;;		# Multiple VLAN Registration Protocol [802.1q]
	"0x88F7") echo exit 1; ;;		# Precision Time Protocol
	"0x8906") echo exit 1; ;;		# Fibre Channel over Ethernet
	"0x8914") echo exit 1; ;;		# FCoE Initialization Protocol
	"0x8915") echo exit 1; ;;		# RDMA over Converged Ethernet
	"0xA0ED") echo exit 1; ;;		# LoWPAN encapsulation
	"0x8100") echo "VLAN-C"; exit 0; ;;	# VLAN tagged frame [802.1q]
	"0x88A8") echo "VLAN-S"; exit 0; ;;	# QinQ Service VLAN tag identifier [802.1q]
	*) 					#Unknown
		echo "\nInvalid --id">&2;
		print_usage_then_exit;
	;;
esac

exit 0;
