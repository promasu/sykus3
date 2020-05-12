require 'spec_helper'


module Sykus

  describe Printers::ValidPrinterURL do
    valid_urls = [
      'lpd://10.42.10.1:515/QUEUE',
      'lpd://10.42.20.1/QUEUE',
      'lpd://10.42.2.1',
      'socket://10.42.10.1:9100',
      'socket://10.42.70.1',
      'ipp://10.42.70.1/lp1',
    ]

    invalid_urls = [
      'http://10.42.20.1/QUEUE',
      'lpd://printer/queue',
      'socket://10.42.200.1',
      'lpd://10.42.20.1/QUEUE?something',
      'lpd://10.42.20.1/QUEUE#printer',
    ]

    valid_urls.each do |str|
      it "is valid for: #{str}" do
        Printers::ValidPrinterURL.enforce! str
      end
    end

    invalid_urls.each do |str|
      it "raises for: #{str}" do
        expect {
        Printers::ValidPrinterURL.enforce! str
      }.to raise_error Exceptions::Input
      end
    end
  end

end

