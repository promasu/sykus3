require 'fileutils'
require 'tmpdir'

module ScreenLock
  def self.hooks(scheduler)
    scheduler.every '1s' do
      set CliInfo.get[:screenlock]
    end
  end

  private
  def self.set(state)
    return unless Session.is_student?

    return if state == @state
    @state = state

    if @state
      lock
    else
      unlock
    end
  end

  def self.lock
    input_devices 0

    @dir = Dir.mktmpdir
    FileUtils.touch "#{@dir}/First Run"
    FileUtils.chown_R Session.user[:username], nil, @dir

    Util.userdo %{#{
      "/sbin/start-stop-daemon -m -b -p #{@dir}/unclutter.pid --exec " +
      "/usr/bin/unclutter -S"
    }}

    Util.userdo %{#{
      "/sbin/start-stop-daemon -m -b -p #{@dir}/browser.pid --exec " +
      "/usr/bin/chromium-browser -S -- " +
      "--no-default-browser-check --user-data-dir=#{@dir} --kiosk " +
      "https://#{Util.server_domain}/screenlock.html"
    }}
  end

  def self.unlock
    return unless @dir
    Util.userdo "/sbin/start-stop-daemon -p #{@dir}/unclutter.pid -K"
    Util.userdo "/sbin/start-stop-daemon -p #{@dir}/browser.pid -K"
    FileUtils.rm_rf @dir
    input_devices 1
  end

  def self.input_devices(val)
    30.times do |i|
      Util.userdo "xinput set-int-prop #{i} 'Device Enabled' 8 #{val}"
    end
  end
end

