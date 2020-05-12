require 'spec_helper'

require 'services/printers/update_printer'
require 'jobs/printers/update_printer_job'

module Sykus

  describe Printers::UpdatePrinter do
    let (:identity) { IdentityTestGod.new } 
    let (:update_printer) { Printers::UpdatePrinter.new identity } 

    let (:printer) { Factory Printers::Printer, driver: 'foo:matic' }
    let (:id) { printer.id }
    let (:new_group) { Factory Hosts::HostGroup }

    before :each do
      drivers = [ {
        id: 'foo:matic',
        name: 'Fooprint',
      }, {
        id: 'foo:matic2',
        name: 'Fooprint',
      }  ]
      REDIS.set 'Printers.drivers', drivers.to_json
    end

    context 'input parameters' do
      it 'works with all attributes' do
        update_printer.run(id, {
          name: 'Printer New',
          driver: 'foo:matic2',
          url: 'socket://10.42.42.1',
          host_groups: [ new_group.id ],
        })

        ref = Printers::Printer.get id
        ref.name.should == 'Printer New'
        ref.driver.should == 'foo:matic2'
        ref.url.should == 'socket://10.42.42.1'
        ref.host_groups.should == [ new_group ]

        check_entity_evt(EntitySet.new(Printers::Printer), id, false)
        Resque.dequeue(Printers::UpdatePrinterJob, id).should == 1
      end

      it 'works with empty data' do
        ref = Printers::Printer.get(id).to_json
        update_printer.run id, {}
        Printers::Printer.get(id).to_json.should == ref
      end
    end

    context 'errors' do
      it 'fails on invalid driver' do
        expect { 
          update_printer.run(id, { driver: 'foo:faa' })
        }.to raise_error Exceptions::Input
      end

      it '#run raises on permission violations' do
        check_service_permission(:printers_write, 
                                 Printers::UpdatePrinter, :run, 4200, {})
      end

      it '#run raises on invalid id' do
        expect {
          update_printer.run(4200, {})
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

