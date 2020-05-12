require 'spec_helper'

require 'services/webfilter/find_entry'

module Sykus

  describe Webfilter::FindEntry do
    let (:entry) { Factory Webfilter::Entry }
    let (:find_entry) { 
      Webfilter::FindEntry.new IdentityTestGod.new
    }

    def check_entry(result, ref)
      result[:id].should == ref.id
      result[:domain].should == ref.domain
      result[:comment].should == ref.comment
      result[:type].should == ref.type.to_s
    end

    context 'permission violations' do
      it 'raises on #all' do
        check_service_permission(:webfilter_read, 
                                 Webfilter::FindEntry, :all)
      end

      it 'raises on #by_id' do
        check_service_permission(:webfilter_read, Webfilter::FindEntry, 
                                 :by_id, 42)
      end
    end

    context 'returns all categories' do
      subject { find_entry.all }

      before :each do
        3.times { Factory Webfilter::Entry, comment: 'bla' }
      end

      it { should be_a Array }

      it 'returns correct number of categories' do 
        subject.count.should == 3
      end

      it 'returns correct entry data' do
        subject.each do |entry|
          entry[:comment].should == 'bla'
        end
      end
    end

    context 'finds entry by id' do
      it 'finds correct entry with all attributes' do
        res = find_entry.by_id(entry.id)
        check_entry res, entry
      end

      it 'raises on invalid entry' do
        expect {
          find_entry.by_id(42000)
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

