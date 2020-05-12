require 'spec_helper'

require 'services/printers/reset_printer'
require 'jobs/printers/reset_printer_job'

module Sykus

  describe Printers::ResetPrinter do
    let (:identity) { IdentityTestGod.new } 
    let (:reset_printer) { Printers::ResetPrinter.new identity } 

    let (:printer) { Factory Printers::Printer }
    let (:id) { printer.id }

    it 'works' do
      reset_printer.run(id)
      Resque.dequeue(Printers::ResetPrinterJob, id).should == 1
    end

    context 'errors' do
      it '#run raises on permission violations' do
        check_service_permission(:printers_reset, 
                                 Printers::ResetPrinter, :run, 4200)
      end

      it '#run raises on invalid id' do
        expect {
          reset_printer.run(4200)
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end


