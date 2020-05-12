# recipes that do not depend on sykus3 user
include_recipe 'timezone::default'
include_recipe 'apt::default'
include_recipe 'hostname::default'
include_recipe 'local-dns::default'
include_recipe 'grub::default'
include_recipe 'dyndns::default'
include_recipe 'firewall::default'
include_recipe 'ssh::default'
include_recipe 'sshkey::default'
include_recipe 'quota::default'
include_recipe 'adminutils::default'
include_recipe 'kvm::default'
include_recipe 'ruby::default'
include_recipe 'redis::default'
include_recipe 'nginx::default'
include_recipe 'pdns-recursor::default'
include_recipe 'dhcpd::default'
include_recipe 'cups::default'
include_recipe 'ntp::default'
include_recipe 'shares::default'
include_recipe 'samba::default'

include_recipe 'permissions::default'

# recipes that depend on sykus3 user
include_recipe 'mysql::default'
include_recipe 'nss::default'
include_recipe 'squid::default'
include_recipe 'radius::default'

include_recipe 'snipxe::default'
include_recipe 'webif::default'
include_recipe 'server::default'

