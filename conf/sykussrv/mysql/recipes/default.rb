package 'mysql-server' do
  action :install
end

service 'mysql' do
  provider Chef::Provider::Service::Upstart
end

conf_file = '/var/lib/sykus3/db.yaml'
ruby_block 'mysql init' do
  not_if { File.exists? conf_file }

  notifies :touch, "file[#{conf_file}]", :immediately
  notifies :restart, 'service[mysql]', :immediately

  block do
    user = 'sykus3'
    db = user
    pass = SecureRandom.hex(16).to_s

    f = Tempfile.new 'sql'
    f.write "DELETE FROM mysql.user WHERE user != 'debian-sys-maint';"
    f.write "DELETE FROM mysql.db;"
    f.write "DELETE FROM mysql.columns_priv;"
    f.write "DELETE FROM mysql.tables_priv;"
    f.write "DELETE FROM mysql.procs_priv;"
    f.write "FLUSH PRIVILEGES;"
    f.write "CREATE USER '#{user}'@'localhost' IDENTIFIED BY '#{pass}';"
    f.write "CREATE DATABASE IF NOT EXISTS #{db};"
    f.write "GRANT ALL ON #{db}.* TO '#{user}'@'localhost';"
    f.close

    %x{mysql --defaults-file=/etc/mysql/debian.cnf mysql < #{f.path}}
    f.unlink

    File.open(conf_file, 'w+') do |f|
      f.write({
        db: db,
        user: user,
        pass: pass,
      }.to_yaml)
    end
  end
end

file conf_file do
  action :nothing
  owner 'sykus3'
  group 'sykus3'
  mode 0600
end


cookbook_file '/etc/mysql/my.cnf' do
  action :create
  source 'my.cnf'
  notifies :restart, 'service[mysql]'
end

