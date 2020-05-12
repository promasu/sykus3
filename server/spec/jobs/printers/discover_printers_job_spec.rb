require 'spec_helper'

require 'jobs/printers/discover_printers_job'

module Sykus

  describe Printers::DiscoverPrintersJob do
    it 'discovers printers correctly' do

      job = Printers::DiscoverPrintersJob

      data = 'network lpd://10.42.20.1:515/PASSTHRU "Printer 1" "text"' + "\n"
      data << 'network lpd://10.42.200.1:515/PASSTHRU "Dummy" "text"' + "\n"
      data << 'network socket://10.42.40.1 "Printer 2" "text"'

      job.should_receive(:`).with('sudo /usr/lib/cups/backend/snmp').
        and_return(data)

      job.perform

      result = REDIS.get 'Printers.discovered'
      result.should_not be_nil
      result = JSON.parse result, symbolize_names: true
      result.should be_a Array
      result.count.should == 2

      result.first.should == {
        name: 'Printer 1',
        url: 'lpd://10.42.20.1:515/PASSTHRU'
      }
      result.last.should == {
        name: 'Printer 2',
        url: 'socket://10.42.40.1'
      }
    end
  end

end

