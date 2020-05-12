require 'spec_helper'

require 'jobs/printers/update_printer_job'

module Sykus

  describe Printers::UpdatePrinterJob do
    before :each do
      Factory Printers::Printer, 
        driver: 'foo:matic', url: 'socket://10.42.20.1'
    end

    it 'creates or updates a printer correctly' do
      job = Printers::UpdatePrinterJob
      job.should_receive(:system).
        with('sudo lpadmin -p p1 -E -m foo:matic -v socket://10.42.20.1')

      job.perform 1
    end

    it 'deletes a printer correctly' do
      job = Printers::UpdatePrinterJob
      job.should_receive(:system).with('sudo lpadmin -x p2')

      job.perform 2
    end
  end

end

