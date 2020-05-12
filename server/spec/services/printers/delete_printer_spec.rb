require 'spec_helper'

require 'services/printers/delete_printer'
require 'jobs/printers/update_printer_job'

module Sykus

  describe Printers::DeletePrinter do
    let (:identity) { IdentityTestGod.new } 
    let (:delete_printer) { Printers::DeletePrinter.new identity }

    let (:hg) { Factory Hosts::HostGroup }
    let (:printer) { Factory Printers::Printer, host_groups: [ hg ] }
    let (:id) { printer.id }

    context 'input parameters' do
      it 'works with printer id' do
        delete_printer.run id

        Printers::Printer.get(id).should be_nil
        Hosts::HostGroup.get(hg.id).should_not be_nil
        check_entity_evt(EntitySet.new(Printers::Printer), id, true)
        Resque.dequeue(Printers::UpdatePrinterJob, id).should == 1
      end
    end

    context 'errors' do
      it 'raises on permission violation' do
        check_service_permission(:printers_write,
                                 Printers::DeletePrinter, :run, 1)
      end

      it 'raises on invalid id' do
        expect {
          delete_printer.run 4200
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

