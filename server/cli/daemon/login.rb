require 'json'
require 'timeout'
require 'shellwords'
require 'fileutils'
require 'logger'

Dir.chdir File.dirname(__FILE__)

require_relative './util'

module SykusLogin
  UMOUNT_SHARE_LIST = [
    '/mnt/home/.gvfs', '/mnt/home', '/mnt/groups', 
    '/mnt/share.admin', '/mnt/share.teacher', 
    '/mnt/progdata',
  ]

  def self.run
    %x{stop sykus3-daemon}
    parse
    cleanup
    if @user == 'localuser'
      mount_localhome
    else
      mount_home
      home_cleanup
    end

    skel
    logout_button

    if @user == 'localuser'
      FileUtils.chown_R 'localuser', 'localuser', '/home/localuser'
    else
      mount_shares
      mount_groups
      webif_link
    end

    save_session
    %x{start sykus3-daemon}
  end

  def self.parse
    @data = JSON.parse ENV['PAM_AUTHTOK'], symbolize_names: true
    @user = @data[:user][:username]
    raise unless @user == ENV['PAM_USER']
  end

  def self.mounted?(share)
    File.readlines('/proc/mounts').map { |x| x.split(' ')[1] }.include? share
  end

  def self.groups
    `groups #{@user}`.split(':')[1].strip.split(' ')
  end

  def self.cleanup
    FileUtils.mkdir_p '/mnt'
    UMOUNT_SHARE_LIST.each do |share|
      next unless File.exists? share
      share = File.realdirpath share
      Timeout::timeout(25) do
        count = 0
        loop do
          break unless mounted? share

          system "umount #{share} #{count > 15 ? '-l' : ''}"
          sleep 0.3
          count += 1
        end
      end
      FileUtils.rm_rf share
      FileUtils.mkdir share
    end
    FileUtils.rm_rf '/mnt/home'
  end

  def self.create_link(target, name, icon)
    file = "/mnt/home/Desktop/InternalSykus #{name}.desktop"
    File.open(file, 'w+') do |f|
      f.write "[Desktop Entry]\n"
      f.write "Version=1.0\n"
      f.write "Type=Link\n"
      f.write "Name=#{name}\n"
      f.write "URL=file://#{target}\n"
      f.write "Icon=#{icon}\n"
    end
    FileUtils.chmod 0755, file

    File.open('/mnt/home/.gtk-bookmarks', 'a+') do |f|
      f.write "file://#{target} #{name}\n"
    end
  end

  def self.logout_button
    file = "/mnt/home/Desktop/InternalSykus logout.desktop"
    File.open(file, 'w+') do |f|
      f.write "[Desktop Entry]\n"
      f.write "Version=1.0\n"
      f.write "Type=Application\n"
      f.write "Icon=gnome-session-logout\n"
      f.write "Name=Abmelden\n"
      f.write "Exec=xfce4-session-logout\n"
      f.write "Categories=Sykus\n"
    end
    FileUtils.chmod 0755, file
  end

  def self.webif_link
    url = "https://#{Util.server_domain}/#session/LoginWithUsername!#{@user}"

    file = "/mnt/home/Desktop/InternalSykus WebIF.desktop"
    File.open(file, 'w+') do |f|
      f.write "[Desktop Entry]\n"
      f.write "Version=1.0\n"
      f.write "Type=Application\n"
      f.write "Name=Sykus 3\n"
      f.write "Exec=chromium-browser --no-default-browser-check " +
        "--disable-extensions --disable-translate " +
        "--app=#{url}\n"
      f.write "Icon=gnome-workspace\n"
    end
    FileUtils.chmod 0755, file
  end

  def self.mount(name, target, linkname = nil, icon = nil)
    FileUtils.mkdir_p target
    FileUtils.chown @user, nil, target
    FileUtils.chmod 0700, target

    %x{#{
      "export PASSWD=#{Shellwords.shellescape @data[:password]}; " + 
      "mount.cifs //10.42.1.1/#{name} #{target} " +
      "-o user=#{@user},forceuid,uid=#{@user}"
    }}
    raise unless mounted? target

    create_link target, linkname, icon if linkname
  end

  def self.mount_groups
    target = '/mnt/groups'
    FileUtils.mkdir_p target
    FileUtils.chown @user, nil, target
    FileUtils.chmod 0700, target

    %x{#{
      "echo #{@user}\\\\n#{Shellwords.shellescape @data[:password]}" + 
      "| mount.davfs https://#{Util.server_domain}/dav/resourcegroups/ " +
      "#{target} -o uid=#{@user}"
    }}

    raise unless mounted? target

    create_link target, 'Gruppendateien', 'folders-publicshare'
  end

  def self.mount_localhome
    target = '/home/localuser'
    FileUtils.mkdir_p target
    FileUtils.chown @user, nil, target
    FileUtils.chmod 0700, target
    FileUtils.ln_sf target, '/mnt/home'

    %x{mount -t tmpfs none #{target}}
    raise unless mounted? target
  end

  def self.mount_home
    FileUtils.ln_sf "/home/#{@user}", '/mnt/home'
    mount 'home', "/home/#{@user}"
  end

  def self.mount_shares
    mount 'progdata', '/mnt/progdata', 'Serverdateien', 'shares'

    if groups.include? 'sykus-share-teacher'
      mount 'share.teacher', '/mnt/share.teacher', 
        'Lehrerfreigabe', 'folders-publicshare'
    end

    if groups.include? 'sykus-share-admin'
      mount 'share.admin', '/mnt/share.admin', 
        'Adminfreigabe', 'folders-publicshare'
    end
  end

  def self.home_cleanup
    FileUtils.rm_rf '/mnt/home/.cache'

    # can cause login/app launch problems when persists
    FileUtils.rm_f '/mnt/home/.Xauthority'
    FileUtils.rm_f '/mnt/home/.config/chromium/SingletonLock'
  end

  def self.skel
    dir = '/var/lib/sykus3/skel'
    FileUtils.cp_r (Dir["#{dir}/*"] + Dir["#{dir}/.??*"]), 
      '/mnt/home'
    FileUtils.mkdir_p '/mnt/home/Desktop'
    FileUtils.rm_f Dir['/mnt/home/Desktop/InternalSykus*.desktop']
    FileUtils.rm_f '/mnt/home/.gtk-bookmarks'
  end

  def self.save_session
    File.open('/var/lib/sykus3/user.json', 'w+', 0600) do |f|
      f.write @data.to_json
    end
  end
end

begin 
  SykusLogin.run
rescue Exception => e
  Logger.new('/var/log/sykus3-login.log').error \
    "Error #{e.class.name}: #{e.to_s}\n#{e.backtrace}"

  exit 1
end

