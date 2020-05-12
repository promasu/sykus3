require 'bundler'
Bundler.require :default

Dir.chdir File.dirname(__FILE__)

require_relative './util'
require_relative './session'
require_relative './module_keepalive'
require_relative './module_nss'
require_relative './module_cliinfo'
require_relative './module_screenlock'
require_relative './module_soundlock'
require_relative './module_screenshot'
require_relative './module_printers'
require_relative './module_weblock'

module SykusDaemon
  scheduler = Rufus::Scheduler.new

  Session.init
  CliInfo.init

  CliInfo.hooks scheduler
  NSS.hooks scheduler

  if Session.user
    ScreenLock.hooks scheduler
    SoundLock.hooks scheduler
    WebLock.hooks scheduler
    ScreenShot.hooks scheduler
    Printers.hooks scheduler
    Keepalive.hooks scheduler

    ScreenShot.init
  end

  trap 'INT' do
    ScreenLock.set_state false
  end

  scheduler.cron '0 1 * * *' do
    system 'poweroff'
  end

  scheduler.join
end


