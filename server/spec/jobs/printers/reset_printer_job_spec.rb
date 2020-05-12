require 'spec_helper'

require 'jobs/printers/reset_printer_job'

module Sykus

  describe Printers::ResetPrinterJob do
    before :each do
      Factory Printers::Printer
    end

    it 'resets a printer correctly' do
      job = Printers::ResetPrinterJob
      job.should_receive(:system).with('sudo cupsenable -c p1')

      job.perform 1
    end
  end

end

