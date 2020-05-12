require 'spec_helper'

require 'services/printers/create_printer'
require 'jobs/printers/update_printer_job'

module Sykus

  describe Printers::CreatePrinter do
    let (:create_printer) { 
      Printers::CreatePrinter.new IdentityTestGod.new 
    }

    let (:hg) { Factory Hosts::HostGroup }
    let (:printer1) {{
      name: 'Printer 1',
      driver: 'foomatic:fooprint',
      url: 'socket://10.42.20.1/',
      host_groups: [ hg.id ],
    }}

    before :each do
      drivers = [ {
        id: 'foomatic:fooprint',
        name: 'Fooprint',
      } ]
      REDIS.set 'Printers.drivers', drivers.to_json
    end

    subject { create_printer.run printer1 }

    it 'works with all required parameters' do
      result = subject

      id = result[:id]
      id.should be_a Integer

      printer = Printers::Printer.get id
      printer.name.should == 'Printer 1'
      printer.driver.should == 'foomatic:fooprint'
      printer.url.should == 'socket://10.42.20.1/'
      printer.host_groups.should == [ hg ]

      check_entity_evt(EntitySet.new(Printers::Printer), id, false)
      Resque.dequeue(Printers::UpdatePrinterJob, id).should == 1
    end

    context 'errors' do
      it '#run raises on permission violation' do
        check_service_permission(:printers_write, 
                                 Printers::CreatePrinter, :run, {})
      end

      it 'raises on invalid driver' do
        printer1.merge! driver: 'foo:dummy'

        expect { subject }.to raise_error Exceptions::Input
      end

      it 'raises on invalid host group data' do
        printer1.merge! host_groups: 12

        expect { subject }.to raise_error Exceptions::Input
      end


      it 'raises on invalid url' do
        printer1.merge! url: 'http://print'

        expect { subject }.to raise_error Exceptions::Input
      end
    end
  end

end

