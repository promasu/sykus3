package 'quota' do
  action :install
end

file '/etc/fstab' do
  action :create
  mode 0644

  has_home = false
  data = File.readlines('/etc/fstab')

  data.each {|l| has_home = true if l.split(' ')[1] == '/home' }

  fstab_content = data.map do |line|
    next if /^(#|$)/.match line.strip
    dev, target, fs, options, dump, pass = line.split(' ')

    options = 
      case target
      when '/'
        has_home ? 'defaults' : 'defaults,usrquota'
      when '/home'
        'defaults,usrquota'
      else 
        options
      end

    [ dev, target, fs, options, dump, pass ].join('  ')
  end.compact.join("\n") + "\n\n"

  content fstab_content 

  notifies :run, 'bash[remount]', :immediately
end

bash 'remount' do
  action :nothing

  code <<-EOF
    mount -o remount /
    mount -o remount /home
    quotacheck -fucma
    exit 0
  EOF
end

