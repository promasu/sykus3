# install apps first since there may be dependencies with multiple
# candidates for the later packages
%w{
  xfburn evince simple-scan file-roller gcalctool ristretto mousepad

  acpi-support ttf-ubuntu-font-family
  xubuntu-artwork xubuntu-icon-theme xubuntu-wallpapers
  xfce4-indicator-plugin indicator-sound-gtk2 indicator-power
  xfce4-terminal xfce4-screenshooter
  thunar-archive-plugin thunar-media-tags-plugin
  xfce4-mixer xfce4-volumed gvfs-backends gvfs-fuse 
}.each do |name|
  package name do
    action :install
  end
end

# These drivers caused X server problems in some clients.
# REVIEW: Remove when fixed
package 'xserver-xorg-video-sis' do
  action :purge
end
package 'xserver-xorg-video-intel' do
  action :purge
end


xfconf_dir = '/var/lib/sykus3/skel/.config/xfce4/xfconf/xfce-perchannel-xml'

directory xfconf_dir do
  action :create
  recursive true
end

# Qt config
cookbook_file '/var/lib/sykus3/skel/.config/Trolltech.conf' do
  action :create
  mode 0644
  source 'Trolltech.conf'
end

%w{
  xfce4-panel.xml xfce4-desktop.xml xfce4-session.xml thunar-volman.xml
}.each do |file|
  cookbook_file File.join(xfconf_dir, file) do
    action :create
    mode 0644
    source file
  end
end

cookbook_file '/etc/xdg/user-dirs.conf' do
  action :create
  mode 0644
  source 'user-dirs.conf'
end

cookbook_file '/etc/xdg/xdg-xubuntu/menus/xfce-applications.menu' do
  action :create
  mode 0644
  source 'xfce-applications.menu'
end

directory '/var/lib/sykus3/skel/.config/autostart' do 
  action :create
  mode 0755
end

# Disable screensaver
cookbook_file '/var/lib/sykus3/skel/.config/autostart/screensaver.desktop' do
  action :create
  mode 0755
  source 'screensaver-autostart.desktop'
end

cookbook_file '/usr/lib/sykus3/screensaver.sh' do
  action :create
  mode 0755
  source 'screensaver.sh'
end


