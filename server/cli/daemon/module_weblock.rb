module WebLock
  def self.hooks(scheduler)
    scheduler.every '2s' do
      flag = CliInfo.get[:weblock] && Session.is_student?

      if @flag != flag
        @flag = flag
        run
      end
    end
  end

  private
  def self.run
    %x{iptables -t nat -F}
    return unless @flag

    %x{#{
      "iptables -t nat -A OUTPUT -p tcp --dport 3128 " +
      "-j DNAT --to-destination 10.42.1.1:83"
    }}
  end
end

