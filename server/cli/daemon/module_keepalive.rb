module Keepalive
  @failed_pings = 0

  def self.hooks(scheduler)
    scheduler.every '5s' do
      run
    end
  end

  private
  def self.run
    Session.init

    return unless Session.user 
    return if Session.localuser?

    id = Session.session_id
    url = "https://#{Util.server_domain}/api/sessions/#{id}/keepalive"
      if system "curl -s -f -m3 #{url}"
        @failed_pings = 0
        return
      end

    @failed_pings += 1

    if @failed_pings > 4
      Session.destroy
      system 'restart lightdm'
      exit!
    end
  end
end

