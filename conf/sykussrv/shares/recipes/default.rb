# create dummy groups that get overridden by NSS DB
# make sure GIDs stay the same
{
  'sykus-share-progdata' => 42001,
  'sykus-share-teacher' => 42002,
  'sykus-share-admin' => 42003,
}.each do |name, id|
  group name do
    action :create
    gid id
  end
end

directory '/home/users' do
  action :create
  recursive true
  mode 0755
end

directory '/home/groups' do
  action :create
  recursive true
  mode 0755
end

directory '/home/share' do
  action :create
  recursive true
  mode 0755
end

directory '/home/share/teacher' do
  action :create
  recursive true
  group 'sykus-share-teacher'
  mode 02770
end

directory '/home/share/admin' do
  action :create
  recursive true
  group 'sykus-share-admin'
  mode 02770
end

directory '/home/share/progdata' do
  action :create
  recursive true
  group 'sykus-share-progdata'
  mode 02775
end


