require 'spec_helper'

require 'services/hosts/find_package'

module Sykus

  describe Hosts::FindPackage do
    let (:package) { Factory Hosts::Package }
    let (:find_package) { Hosts::FindPackage.new IdentityTestGod.new }

    def check_package(result, ref)
      result[:id].should == ref.id
      result[:id_name].should == ref.id_name
      result[:name].should == ref.name
      result[:category].should == ref.category
      result[:text].should == ref.text
      result[:selected].should == ref.selected
      result[:installed].should == ref.installed
      result[:default].should == ref.default
    end

    context 'permission violations' do
      it 'raises on #all' do
        check_service_permission(:packages_read, Hosts::FindPackage, :all)
      end

      it 'raises on #by_id' do
        check_service_permission(:packages_read, Hosts::FindPackage, 
                                 :by_id, 42)
      end
    end

    context 'returns all packages' do
      subject { find_package.all }

      before :each do
        3.times { Factory Hosts::Package, text: 'bla' }
      end

      it { should be_a Array }

      it 'returns correct number of packages' do 
        subject.count.should == 3
      end

      it 'returns correct package data' do
        subject.each do |package|
          package[:text].should == 'bla'
        end
      end
    end

    context 'finds package by id' do
      it 'finds correct package with all attributes' do
        res = find_package.by_id(package.id)
        check_package res, package
      end

      it 'raises on invalid package' do
        expect {
          find_package.by_id(42000)
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

