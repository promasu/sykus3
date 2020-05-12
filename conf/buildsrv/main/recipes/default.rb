include_recipe 'timezone::default'
include_recipe 'apt::default'
include_recipe 'grub::default'
include_recipe 'ssh::default'
include_recipe 'ntp::default'
include_recipe 'ruby::default'
include_recipe 'node::default'
include_recipe 'kvm::default'
include_recipe 'adminutils::default'

include_recipe 'permissions::default'

include_recipe 'webif::default'
include_recipe 'build::default'

