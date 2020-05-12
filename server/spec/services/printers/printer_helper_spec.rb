require 'spec_helper'

require 'services/printers/printer_helper'

module Sykus

  describe Printers::PrinterHelper do
    let (:printer_helpers) { 
      Printers::PrinterHelper.new IdentityTestGod.new 
    }

    it 'returns correct list of drivers' do
      drivers = [
        { id: 'id1', name: 'name1' },
        { id: 'id2', name: 'name2' },
      ]
      REDIS.set 'Printers.drivers', drivers.to_json

      printer_helpers.drivers.should == drivers
    end

    it 'returns correct list of discovered printers' do
      printers = [
        { name: 'name1', url: 'socket://10.42.20.1' },
        { name: 'name2', url: 'socket://10.42.20.2' },
      ]
      REDIS.set 'Printers.discovered', printers.to_json

      printer_helpers.discovered.should == printers
    end

    context 'permission violations' do
      it 'raises on #drivers' do
        check_service_permission(:printers_read, Printers::PrinterHelper, 
                                 :drivers)
      end

      it 'raises on #discovered' do
        check_service_permission(:printers_read, Printers::PrinterHelper, 
                                 :discovered)
      end
    end
  end

end

