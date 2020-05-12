require 'spec_helper'

require 'jobs/hosts/import_packages_job'

module Sykus

  describe Hosts::ImportPackagesJob do
    include FakeFS::SpecHelpers
    dir = Hosts::ImportPackagesJob::PACKAGES_DIR

    let (:oldpackage) { Factory Hosts::Package }
    # use strings as keys, not symbols
    let (:data) {{
      'name' => 'newpack',
      'category' => 'category',
      'text' => 'text',
      'default' => true,
    }}

    before :each do
      FileUtils.mkdir_p dir
      oldpackage
    end

    context 'no new packages' do
      it 'deletes the old package' do
        oldid = oldpackage.id
        Hosts::ImportPackagesJob.perform

        Hosts::Package.count.should == 0
        check_entity_evt(EntitySet.new(Hosts::Package), oldid, true)
      end
    end

    context 'same package id_name' do 
      it 'updates the package' do
        File.open("#{dir}/#{oldpackage.id_name}.yaml", 'w+') do |f|
          f.write data.to_yaml
        end

        Hosts::ImportPackagesJob.perform

        Hosts::Package.count.should == 1
        Hosts::Package.first.name.should == data['name']
        check_entity_evt(EntitySet.new(Hosts::Package), oldpackage.id, false)
      end
    end

    context 'new package' do 
      it 'updates the package and deletes the old one' do
        oldid = oldpackage.id
        File.open("#{dir}/newpack.yaml", 'w+') do |f|
          f.write data.to_yaml
        end

        Hosts::ImportPackagesJob.perform

        Hosts::Package.count.should == 1
        Hosts::Package.first.name.should == data['name']
        Hosts::Package.first.category.should == data['category']
        Hosts::Package.first.text.should == data['text']
        Hosts::Package.first.default.should == data['default']
        check_entity_evt(EntitySet.new(Hosts::Package), 
                         Hosts::Package.first.id, false)
        check_entity_evt(EntitySet.new(Hosts::Package), oldid, true)
      end
    end

    context 'invalid package' do
      it 'does not import package' do
        data['name'] = ''
        File.open("#{dir}/newpack.yaml", 'w+') do |f|
          f.write data.to_yaml
        end

        Hosts::ImportPackagesJob.perform
        Hosts::Package.count.should == 0
      end
    end

    context 'invalid package (apt line)' do
      it 'does not import package' do
        data['apt'] = 'curl wget'
        File.open("#{dir}/newpack.yaml", 'w+') do |f|
          f.write data.to_yaml
        end

        Hosts::ImportPackagesJob.perform
        Hosts::Package.count.should == 0
      end
    end

  end

end

