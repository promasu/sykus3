module Printers
  def self.hooks(scheduler)
    scheduler.every '1s' do
      data = CliInfo.get[:printers]

      data = [] if CliInfo.get[:printerlock] && Session.is_student?

      if @data != data
        @data = data
        run
      end
    end
  end

  private

  def self.clean
    %x{lpstat -v}.strip.split("\n").each do |line|
      name = line.split(' ')[2][0..-2]

      %x{lpadmin -x #{name}}
    end
  end

  def self.run
    %x{cupsctl 'BrowseRemoteProtocols=""'}

    # wait for command to finish
    sleep 1

    clean

    @data.each do |p|
      name = p[:name].gsub(' ', '-').gsub('/', '-')
      %x{lpadmin -p #{name} -E -v ipp://10.42.1.1/printers/#{p[:id]}}
    end
  end
end

