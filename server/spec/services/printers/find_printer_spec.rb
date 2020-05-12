require 'spec_helper'

require 'services/printers/find_printer'

module Sykus

  describe Printers::FindPrinter do
    let (:printer) { Factory Printers::Printer }
    let (:find_printer) { 
      Printers::FindPrinter.new IdentityTestGod.new 
    }

    def check_printer(result, ref)
      result[:id].should == ref.id
      result[:name].should == ref.name
      result[:driver].should == ref.driver
      result[:url].should == ref.url
      result[:host_groups].should =~ ref.host_groups.map(&:id)
    end

    context 'permission violations' do
      it 'raises on #all' do
        check_service_permission(:printers_read, Printers::FindPrinter, :all)
      end

      it 'raises on #by_id' do
        check_service_permission(:printers_read, Printers::FindPrinter, 
                                 :by_id, 42)
      end
    end

    context 'returns all printers' do
      subject { find_printer.all }

      before :each do
        3.times { Factory Printers::Printer, driver: 'foomatic:foo' }
      end

      it { should be_a Array }

      it 'returns correct number of printers' do 
        subject.count.should == 3
      end

      it 'returns correct printer data' do
        subject.each do |printer|
          printer[:driver].should == 'foomatic:foo'
        end
      end
    end

    context 'finds printer by id' do
      it 'finds correct printer with all attributes' do
        res = find_printer.by_id(printer.id)
        check_printer res, printer
      end

      it 'raises on invalid printer' do
        expect {
          find_printer.by_id(42000)
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

