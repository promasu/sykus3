require 'fileutils'
require 'tempfile'
require 'digest'

module ScreenShot
  def self.init
    return unless Session.is_student?

    %x{#{
      "x11vnc -q -display :0 -auth /mnt/home/.Xauthority " +
      "-reopen -scale .6 -viewonly -localhost -nopw -norc " +
      "-nocursor -forever -bg"
    }}
    FileUtils.rm_f Dir['/var/lib/sykus3/screenshot/*']
  end

  def self.shot
    return unless Session.is_student?

    dst = Digest::SHA256.hexdigest "SYKUSSCREENSHOT#{Session.session_id}"

    file = Tempfile.new 'screen'
    file2 = Tempfile.new 'screen'
    %x{vncsnapshot -quiet -quality 45 -vncQuality 5 :0 #{file.path}}

    # this step prevents display errors in some browsers
    %x{convert jpg:#{file.path} #{file2.path}}

      # do not serve file while it is being written to, so move just now
      dstpath = "/var/lib/sykus3/screenshot/#{dst}.jpg"
      FileUtils.mv file2.path, dstpath
    FileUtils.chmod 0644, dstpath 

    file.unlink
    file2.unlink
      end

    def self.hooks(scheduler)
      scheduler.every '3s' do
        shot
      end
    end

  end

