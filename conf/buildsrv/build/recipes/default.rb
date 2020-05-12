execute 'bundle install --path /home/sykus3/cache/.bundle' do
  action :run
  cwd '/home/sykus3/build'
end

package 'console-data' do
  action :install
end

package 'aptitude' do
  action :install
end

