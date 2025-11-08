# setup-netfilter

https://git.netfilter.org/nftables/tree/src/payload.c
Line 342:

`
if (base != PROTO_BASE_TRANSPORT_HDR)
   return;
`

https://git.netfilter.org/nftables/tree/src/netlink_delinearize.c
Line 458 to Line 471:

`
netlink_parse_bitwise_mask_xor(...
  struct nft_data_delinearize nld;
  ...
  nld.value = nftnl_expr_get(nle, NFTNL_EXPR_BITWIZE_MASK, &nld.len);
     ^                                                     ^
     Null dereference...                                   Undefined behaviour; uninitialised ptr...
`

Please read the LICENSE file.
