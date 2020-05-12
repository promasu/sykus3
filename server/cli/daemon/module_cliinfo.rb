module CliInfo
  def self.init
    @data = {
      printers: [],
    }
  end

  def self.get
    @data
  end

  def self.hooks(scheduler)
    scheduler.every '4s' do
      begin
        res = %x{curl -s -m3 https://#{Util.server_domain}/api/cli/}
          @data = JSON.parse res, symbolize_names: true
      rescue Exception
      end
    end
  end
end

