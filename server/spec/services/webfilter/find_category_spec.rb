require 'spec_helper'

require 'services/webfilter/find_category'

module Sykus

  describe Webfilter::FindCategory do
    let (:category) { Factory Webfilter::Category }
    let (:find_category) { 
      Webfilter::FindCategory.new IdentityTestGod.new
    }

    def check_category(result, ref)
      result[:id].should == ref.id
      result[:name].should == ref.name
      result[:text].should == ref.text
      result[:selected].should == ref.selected.to_s
      result[:default].should == ref.default.to_s
    end

    context 'permission violations' do
      it 'raises on #all' do
        check_service_permission(:webfilter_read, 
                                 Webfilter::FindCategory, :all)
      end

      it 'raises on #by_id' do
        check_service_permission(:webfilter_read, Webfilter::FindCategory, 
                                 :by_id, 42)
      end
    end

    context 'returns all categories' do
      subject { find_category.all }

      before :each do
        3.times { Factory Webfilter::Category, text: 'bla' }
      end

      it { should be_a Array }

      it 'returns correct number of categories' do 
        subject.count.should == 3
      end

      it 'returns correct category data' do
        subject.each do |category|
          category[:text].should == 'bla'
        end
      end
    end

    context 'finds category by id' do
      it 'finds correct category with all attributes' do
        res = find_category.by_id(category.id)
        check_category res, category
      end

      it 'raises on invalid category' do
        expect {
          find_category.by_id(42000)
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

