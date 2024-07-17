#!/bin/sh

#
#	Usage: (at the bottom)
#	help (display all help)
#	help scripts (display help when extending the project)
#	help configuration (display help when configuring the project to configure your NetFilter install.)
#
#	TODO: extend the help command by further detailing functionality of each script.
#	TODO: extend the help command by further detailing the usefulness of each script.
#

display_functions_script_helpers () {
	echo "./SCRIPT_HELPERS/absolute(">&2;
	echo "  --number <number>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/check_interface_exists_by_mac_address(">&2;
	echo "  --address <string>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/check_interface_exists_by_name (">&2;
	echo "  --name <string>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/check_ipv4_address_is_in_network(">&2;
	echo "  --address <X.X.X.X>">&2;
	echo "  --network <X.X.X.X/X>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/check_ipv4_address_is_in_range(">&2;
	echo "  --address <X.X.X.X>">&2;
	echo "  --range <X.X.X.X-X.X.X.X>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/check_ipv4_address_is_valid(">&2;
	echo "  --address <X.X.X.X>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/check_ipv4_network_is_valid(">&2;
	echo "  --address <X.X.X.X>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/check_layer_2_protocol_id_is_valid(">&2;
	echo "  --id <number>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/check_layer_4_protocol_id_is_valid(">&2;
	echo "  --id <number>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/check_mac_address_is_multicast(">&2;
	echo "  --address <XX:XX:XX:XX:XX:XX>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/check_mac_address_is_private(">&2;
	echo "  --address <XX:XX:XX:XX:XX:XX>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/check_mac_address_is_public(">&2;
	echo "  --address <XX:XX:XX:XX:XX:XX>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/check_mac_address_is_unicast(">&2;
	echo "  --address <XX:XX:XX:XX:XX>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/check_mac_address_is_valid(">&2;
	echo "  --address <XX:XX:XX:XX:XX:XX>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/check_port_is_valid(">&2;
	echo "  --port <number>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/check_vlan_id_is_valid(">&2;
	echo "  --id <number>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/convert_base10_to_binary(">&2;
	echo "  --number <number>">&2;
	echo "  --output-bit-order <big-endian|little-endian>">&2;
	echo "  --output-bit-length <1-32>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/convert_binary_to_base10(">&2;
	echo "  --binary <string>">&2;
	echo "  --input-bit-order <big-endian|little-endian>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/convert_cidr_network_to_base_address(">&2;
	echo "  --network <X.X.X.X/X>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/convert_cidr_network_to_end_address(">&2;
	echo "  --network <X.X.X.X/X>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/convert_ipv4_address_to_binary(">&2;
	echo "  --address <X.X.X.X>">&2;
	echo "  --output-bit-order <big-endian|little-endian>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/convert_ipv4_address_to_decimal(">&2;
	echo "  --address <X.X.X.X>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/convert_ipv4_address_to_segments(">&2;
	echo "  --address <X.X.X.X>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/convert_layer_2_protocol_id_to_name(">&2;
	echo "  --id <number>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/convert_layer_4_protocol_id_to_name(">&2;
	echo "  --id <number>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/exponent(">&2;
	echo "  --base <number>">&2;
	echo "  --exponent <number>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/get_user_id_by_name(">&2;
	echo "  --name <string>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./SCRIPT_HELPERS/substring(">&2;
	echo "  --input <string>">&2;
	echo "  --start-idx <number>">&2;
	echo "  --length <number>">&2;
	echo ");">&2;
}

display_functions_bogons_mac () {
	echo "./BOGONS/MAC/drop_bogon_mac_address_broadcast(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_iana_multicast_all_L1_MI(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_iana_multicast_all_L2_MI(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_iana_multicast_BFDonLAG(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_iana_multicast_ipv4(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_iana_multicast_ipv6(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_iana_multicast_mpls(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_iana_multicast_mpls_tp_p2p(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_iana_multicast_reserved(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_iana_multicast_TRILL_OAM(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_iana_unicast_BFDforVXLAN(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_iana_unicast_PacketPWEthA(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_iana_unicast_PacketPWEthB(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_iana_unicast_ProxyMobileIPV6(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_iana_unicast_reserved(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_iana_unicast_TRILL_OAM(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_iana_unicast_vrrpv4(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_iana_unicast_vrrpv6(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_multicast(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_private(--address-type <source|destination>);">&2;
	echo "./BOGONS/MAC/drop_bogon_mac_address_unspecified(--address-type <source|destination>);">&2;
}

display_functions_bogons_ipv4 () {
	echo "./BOGONS/IPV4/drop_bogon_ipv4_network_loopback(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_network_unspecified(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_address_unspecified(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_network_empty_except_empty_address(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_network_link_local(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_network_private_10(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_network_private_172_16(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_network_private_192_168(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_network_shared_100_64(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_network_multicast(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_address_broadcast(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_address_service_continuity(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_address_dummy(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_address_port_control_protocol_anycast(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_relay_nat_traversal_anycast(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_address_nat_64_discovery(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_address_dns_64_discovery(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_network_ietf_protocol_assignments(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_network_test_1(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_network_test_2(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_network_test_3(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_network_as112v4(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_network_as112v4_direct_delegation(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_network_amt(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_network_6to4_relay_anycast(--address-type <source|destination>);">&2;
	echo "./BOGONS/IPV4/drop_bogon_ipv4_network_benchmarking(--address-type <source|destination>);">&2;
}

display_functions_layer_1 () {
	echo "./LAYER_1/try_match_interface.sh (">&2;
	echo "  --direction <in|out>">&2;
	echo "  --interface-name <string>">&2;
	echo ");">&2;
}

display_functions_ethernet () {
	echo "./ETHERNET/drop_invalid_ethernet_header();">&2;
	echo "">&2;
	echo "./ETHERNET/try_match_ethernet_header(">&2;
	echo "  --ether-type-id <string>">&2;
	echo "  [--vlan-id-dot1q <number>]">&2;
	echo "  [--source-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "  [--destination-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo ");">&2;
}

display_functions_ipv4 () {
	echo "./IPV4/drop_invalid_ipv4_header();">&2;
	echo "">&2;
	echo "./IPV4/try_match_ipv4_header(">&2;
	echo "  [--source-ipv4-address <string>]">&2;
	echo "  [--destination-ipv4-address <string>]">&2;
	echo ");">&2;
}

display_functions_tcp () {
	#TODO: annotate each function.

	echo "./TCP/drop_invalid_tcp_header();">&2;
	echo "">&2;
	echo "./TCP/try_match_tcp_flags_cwr_set();">&2;
	echo "./TCP/try_match_tcp_flags_ece_set();">&2;
	echo "./TCP/try_match_tcp_flags_urg_set();">&2;
	echo "./TCP/try_match_tcp_flags_ack_set();">&2;
	echo "./TCP/try_match_tcp_flags_psh_set();">&2;
	echo "./TCP/try_match_tcp_flags_rst_set();">&2;
	echo "./TCP/try_match_tcp_flags_syn_set();">&2;
	echo "./TCP/try_match_tcp_flags_fin_set();">&2;
	echo "./TCP/try_match_tcp_flags_cwr_unset();">&2;
	echo "./TCP/try_match_tcp_flags_ece_unset();">&2;
	echo "./TCP/try_match_tcp_flags_urg_unset();">&2;
	echo "./TCP/try_match_tcp_flags_ack_unset();">&2;
	echo "./TCP/try_match_tcp_flags_psh_unset();">&2;
	echo "./TCP/try_match_tcp_flags_rst_unset();">&2;
	echo "./TCP/try_match_tcp_flags_syn_unset();">&2;
	echo "./TCP/try_match_tcp_flags_fin_unset();">&2;
	echo "">&2;
	echo "./TCP/try_match_tcp_syn(">&2;
	echo "  --source-port <1-655353>">&2;
	echo "  --destination-port <1-65535>">&2;
	echo "  --service-user-id <number>">&2;
	echo ");">&2;
	echo "">&2;s
	echo "./TCP/try_match_tcp_ack(">&2;
	echo "  --source-port <1-655353>">&2;
	echo "  --destination-port <1-65535>">&2;
	echo "  --service-user-id <number>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./TCP/try_match_tcp_fin(">&2;
	echo "  --source-port <1-655353>">&2;
	echo "  --destination-port <1-65535>">&2;
	echo "  --service-user-id <number>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./TCP/try_match_tcp_rst(">&2;
	echo "  --source-port <1-655353>">&2;
	echo "  --destination-port <1-65535>">&2;
	echo "  --service-user-id <number>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./TCP/try_match_tcp_client_request(">&2;
	echo "  --direction <in|out>">&2;
	echo "	--interface-name <string>">&2;
	echo "	[--vlan-id-dot1q <number>]">&2;
	echo "	[--client-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--client-ip-address <X.X.X.X>]">&2;
	echo "	[--client-ip-network <X.X.X.X/X>]">&2;
	echo "	[--client-port <1-65535>]">&2;
	echo "	[--server-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--server-ip-address <X.X.X.X>]">&2;
	echo "	[--server-ip-network <X.X.X.X/X>]">&2;
	echo "	[--server-port <1-65535>]">&2;
	echo "	[--service-user-id <number>]">&2;
	echo ");">&2;
	echo "">&2;
	echo "./TCP/try_match_tcp_client_response(">&2;
	echo "	--direction <in|out>">&2;
	echo "	--interface-name <string>">&2;
	echo "	[--vlan-id-dot1q <number>]">&2;
	echo "	[--client-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--client-ip-address <X.X.X.X>]">&2;
	echo "	[--client-ip-network <X.X.X.X/X>]">&2;
	echo "	[--client-port <1-65535>]">&2;
	echo "	[--server-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--server-ip-address <X.X.X.X>]">&2;
	echo "	[--server-ip-network <X.X.X.X/X>]">&2;
	echo "	[--server-port <1-65535>]">&2;
	echo "	[--service-user-id <number>]">&2;
	echo ");">&2;
	echo "">&2;
	echo "./TCP/try_match_tcp_client_fin(">&2;
	echo "	--direction <in|out>">&2;
	echo "	--interface-name <string>">&2;
	echo "	[--vlan-id-dot1q <number>]">&2;
	echo "	[--client-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--client-ip-address <X.X.X.X>]">&2;
	echo "	[--client-ip-network <X.X.X.X/X>]">&2;
	echo "	[--client-port <1-65535>]">&2;
	echo "	[--server-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--server-ip-address <X.X.X.X>]">&2;
	echo "	[--server-ip-network <X.X.X.X/X>]">&2;
	echo "	[--server-port <1-65535>]">&2;
	echo "	[--service-user-id <number>]">&2;
	echo ");">&2;
	echo "">&2;
	echo "./TCP/try_match_tcp_client_rst(">&2;
	echo "	--direction <in|out>">&2;
	echo "	--interface-name <string>">&2;
	echo "	[--vlan-id-dot1q <number>]">&2;
	echo "	[--client-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--client-ip-address <X.X.X.X>]">&2;
	echo "	[--client-ip-network <X.X.X.X/X>]">&2;
	echo "	[--client-port <1-65535>]">&2;
	echo "	[--server-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--server-ip-address <X.X.X.X>]">&2;
	echo "	[--server-ip-network <X.X.X.X/X>]">&2;
	echo "	[--server-port <1-65535>]">&2;
	echo "	[--service-user-id <number>]">&2;
	echo ");">&2;
	echo "">&2;
	echo "./TCP/try_match_tcp_server_request(">&2;
	echo "	--direction <in|out>">&2;
	echo "	--interface-name <string>">&2;
	echo "	[--vlan-id-dot1q <number>]">&2;
	echo "	[--server-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--server-ip-address <X.X.X.X>]">&2;
	echo "	[--server-ip-network <X.X.X.X/X>]">&2;
	echo "	[--server-port <1-65535>]">&2;
	echo "	[--client-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--client-ip-address <X.X.X.X>]">&2;
	echo "	[--client-ip-network <X.X.X.X/X>]">&2;
	echo "	[--client-port <1-65535>]">&2;
	echo "	[--service-user-id <number>]">&2;
	echo ");">&2;
	echo "">&2;
	echo "./TCP/try_match_tcp_server_response(">&2;
	echo "	--direction <in|out>">&2;
	echo "	--interface-name <string>">&2;
	echo "	[--vlan-id-dot1q <number>]">&2;
	echo "	[--server-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--server-ip-address <X.X.X.X>]">&2;
	echo "	[--server-ip-network <X.X.X.X/X>]">&2;
	echo "	[--server-port <1-65535>]">&2;
	echo "	[--client-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--client-ip-address <X.X.X.X>]">&2;
	echo "	[--client-ip-network <X.X.X.X/X>]">&2;
	echo "	[--client-port <1-65535>]">&2;
	echo "	[--service-user-id <number>]">&2;
	echo ");">&2;
	echo "">&2;
	echo "./TCP/try_match_tcp_server_fin(">&2;
	echo "	--direction <in|out>">&2;
	echo "	--interface-name <string>">&2;
	echo "	[--vlan-id-dot1q <number>]">&2;
	echo "	[--server-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--server-ip-address <X.X.X.X>]">&2;
	echo "	[--server-ip-network <X.X.X.X/X>]">&2;
	echo "	[--server-port <1-65535>]">&2;
	echo "	[--client-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--client-ip-address <X.X.X.X>]">&2;
	echo "	[--client-ip-network <X.X.X.X/X>]">&2;
	echo "	[--client-port <1-65535>]">&2;
	echo "	[--service-user-id <number>]">&2;
	echo ");">&2;
	echo "">&2;
	echo "./TCP/try_match_tcp_server_rst(">&2;
	echo "	--direction <in|out>">&2;
	echo "	--interface-name <string>">&2;
	echo "	[--vlan-id-dot1q <number>]">&2;
	echo "	[--server-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--server-ip-address <X.X.X.X>]">&2;
	echo "	[--server-ip-network <X.X.X.X/X>]">&2;
	echo "	[--server-port <1-65535>]">&2;
	echo "	[--client-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--client-ip-address <X.X.X.X>]">&2;
	echo "	[--client-ip-network <X.X.X.X/X>]">&2;
	echo "	[--client-port <1-65535>]">&2;
	echo "	[--service-user-id <number>]">&2;
	echo ");">&2;
}

display_functions_udp () {
	echo "./UDP/drop_invalid_udp_header();">&2;
	echo "">&2;
	echo "./UDP/try_match_udp_session_start(">&2;
	echo "  --source-port <number>">&2;
	echo "  --destination-port <number>">&2;
	echo "  --service-user-id <number>">&2;
	echo ");">&2;	
	echo "">&2;
	echo "./UDP/try_match_udp_session_middle(">&2;
	echo "  --source-port <number>">&2;
	echo "  --destination-port <number>">&2;
	echo "  --service-user-id <number>">&2;
	echo ");">&2;
	echo "">&2;
	echo "./UDP/try_match_client_request(">&2;
	echo "	--direction <in|out>">&2;
	echo "	--interface-name <string>">&2;
	echo "	[--vlan-id-dot1q <number>]">&2;
	echo "	[--client-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--client-ip-address <X.X.X.X>]">&2;
	echo "	[--client-ip-network <X.X.X.X/X>]">&2;
	echo "	[--client-port <1-65535>]">&2;
	echo "	[--server-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--server-ip-address <X.X.X.X>]">&2;
	echo "	[--server-ip-network <X.X.X.X/X>]">&2;
	echo "	[--server-port <1-65535>]">&2;
	echo "	[--service-user-id <number>]">&2;
	echo ");">&2;
	echo "">&2;
	echo "./UDP/try_match_client_response(">&2;
	echo "	--direction <in|out>">&2;
	echo "	--interface-name <string>">&2;
	echo "	[--vlan-id-dot1q <number>]">&2;
	echo "	[--client-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--client-ip-address <X.X.X.X>]">&2;
	echo "	[--client-ip-network <X.X.X.X/X>]">&2;
	echo "	[--client-port <1-65535>]">&2;
	echo "	[--server-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--server-ip-address <X.X.X.X>]">&2;
	echo "	[--server-ip-network <X.X.X.X/X>]">&2;
	echo "	[--server-port <1-65535>]">&2;
	echo "	[--service-user-id <number>]">&2;
	echo ");">&2;
	echo "">&2;
	echo "./UDP/try_match_server_response(">&2;
	echo "	--direction <in|out>">&2;
	echo "	--interface-name <string>">&2;
	echo "	[--vlan-id-dot1q <number>]">&2;
	echo "	[--server-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--server-ip-address <X.X.X.X>]">&2;
	echo "	[--server-ip-network <X.X.X.X/X>]">&2;
	echo "	[--server-port <1-65535>]">&2;
	echo "	[--client-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--client-ip-address <X.X.X.X>]">&2;
	echo "	[--client-ip-network <X.X.X.X/X>]">&2;
	echo "	[--client-port <1-65535>]">&2;
	echo "	[--service-user-id <number>]">&2;
	echo ");">&2;
}

display_functions_icmp () {
	echo "./ICMP/drop_invalid_icmp_header();">&2;
	echo "">&2;
	echo "./ICMP/try_match_icmp_destination_port_unreachable(">&2;
	echo "  --direction <in|out>">&2;
	echo "	--interface-name <string>">&2;
	echo "	[--vlan-id-dot1q <number>]">&2;
	echo "	[--server-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--server-ip-address <X.X.X.X>]">&2;
	echo "	[--server-ip-network <X.X.X.X/X>]">&2;
	echo "	[--server-port <1-65535>]">&2;
	echo "	[--client-mac-address <XX:XX:XX:XX:XX:XX>]">&2;
	echo "	[--client-ip-address <X.X.X.X>]">&2;
	echo "	[--client-ip-network <X.X.X.X/X>]">&2;
	echo "	[--client-port <1-65535>]">&2;
	echo "	[--service-user-id <number>]">&2;
	echo ");">&2;
}

if [ "$1" = "" ]; then
	display_functions_script_helpers
	display_functions_bogons_mac
	display_functions_bogons_ipv4
	display_functions_layer_1
	display_functions_ethernet
	display_functions_ipv4
	display_functions_tcp
	display_functions_udp
	display_functions_icmp
else
	while true; do
		case "$1" in
			scripts)
				display_functions_script_helpers
				display_functions_bogons_mac
				display_functions_bogons_ipv4
				display_functions_layer_1
				display_functions_ethernet
				display_functions_ipv4
				display_functions_tcp
				display_functions_udp
				display_functions_icmp
				exit 2;
			;;
			configuration)
				
			;;
			"") break; ;;
			*)
				echo "">&2;
				echo "Unrecognised option: $1">&2;
				echo "">&2;
				echo "Usage $0 --help <arguments>">&2;
				echo "\tArguments:">&2;
				echo "\t\t\"scripts\":">&2;
				echo "\t\t\tDisplay help when extending this project.">&2;
				echo "">&2;
				echo "\t\t\"configuration\":">&2;
				echo "\t\t\tDisplay help when using this project to configure NetFilter.">&2;
				echo "">&2;
				exit 2;
			;;
		esac
	done
fi

##########################################################
#		HELPER SCRIPTS
##########################################################

#
#	TODO: Wrappers for the following signatures (eventually packet content signature checks for unencrypted communications)
#

#./ARP/try_match_arp_probe(--direction <in|out>, --interface-name <string>, [--vlan-id-dot1q <number>], [--source-mac-address <string>], --probed-address-or-network <string>);
#./ARP/try_match_arp_reply
#./ARP/try_match_arp_reply_gratuitous_broadcast
#./ARP/try_match_arp_reply_gratuitous_multicast
#
#./TCP/try_match_tcp_http_request
#./TCP/try_match_tcp_http_response
#./TCP_try_match_tcp_https_reqeust
#./TCP_try_match_tcp_https_response
#./TCP/try_match_tcp_dns_over_tls_query
#./TCP/try_match_tcp_dns_over_tls_reply
#
#./UDP/try_match_udp_dhcp_ack
#./UDP/try_match_udp_dhcp_decline_broadcast
#./UDP/try_match_udp_dhcp_decline_multicast
#./UDP/try_match_udp_dhcp_discover_broadcast
#./UDP/try_match_udp_dhcp_discover_multicast
#./UDP/try_match_udp_dhcp_nak
#./UDP/try_match_udp_dhcp_offer
#./UDP/try_match_udp_dhcp_release
#./UDP/try_match_udp_dhcp_request_broadcast
#./UDP/try_match_udp_dhcp_request_multicast
#./UDP/try_match_udp_dns_query
#./UDP/try_match_udp_dns_reply
#./UDP/try_match_udp_ntp_kiss_of_death
#./UDP/try_match_udp_ntp_stratum_1_request
#./UDP/try_match_udp_ntp_stratum_1_response
#./UDP/try_match_stratum_2_or_greater_request
#./UDP/try_match_stratum_2_or_greater_response
#
#./ICMP/try_match_icmp_destination_port_unreachable
#./ICMP/try_match_icmp_echo_reqeust
#./ICMP_try_match_icmp_echo_reply
#

