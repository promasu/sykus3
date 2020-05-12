require 'common'

module Sykus; module Teacher

  # Gets Room Control data (client info + room state).
  class GetRoomctl < ServiceBase

    # @param [Integer] hg Host Group id.
    def run(hg)
      enforce_permission! :teacher_roomctl

      hg = hg.to_i
      unless Hosts::HostGroup.get(hg)
        raise Exceptions::NotFound, 'Invalid host group' 
      end

      screens = Users::Session.all(:host.not => nil).map do |session|
        next unless session.host.host_group.id == hg
        next unless session.user.position_group == :student

        img = Digest::SHA256.hexdigest "SYKUSSCREENSHOT#{session.id}"
        url = "http://#{session.host.ip.to_s}:81/#{img}.jpg"

          host_name = session.host.host_group.name + '-' + session.host.name

        {
          user_name: session.user.full_name.to_s,
          host_name: host_name,
          img: url, 
        }
      end

      {
        screens: screens.compact,
        screenlock: !!REDIS.get("Roomctl.#{hg}.screenlock"),
        weblock: !!REDIS.get("Roomctl.#{hg}.weblock"),
        printerlock: !!REDIS.get("Roomctl.#{hg}.printerlock"),
        soundlock: !!REDIS.get("Roomctl.#{hg}.soundlock"),
      }
    end
  end

end; end

