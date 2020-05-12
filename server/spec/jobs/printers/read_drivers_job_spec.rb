require 'spec_helper'

require 'jobs/printers/read_drivers_job'

module Sykus

  describe Printers::ReadDriversJob do
    it 'reads printer drivers correctly' do
      job = Printers::ReadDriversJob

      data = 'foomatic:printerfoo Printer Driver 1' + "\n"
      # it should only show the first entry for the same name
      data << 'dummy:printermoo Printer Driver 1' + "\n"
      data << 'gutendoodle:printermoo Printer Driver 2'

      job.should_receive(:`).with('sudo lpinfo -m').and_return(data)

      job.perform

      result = REDIS.get 'Printers.drivers'
      result.should_not be_nil
      result = JSON.parse result, symbolize_names: true
      result.should be_a Array
      result.count.should == 2

      result.first.should == {
        id: 'foomatic:printerfoo',
        name: 'Printer Driver 1',
      }
      result.last.should == {
        id: 'gutendoodle:printermoo',
        name: 'Printer Driver 2',
      }
    end
  end

end

