require 'spec_helper'

require 'jobs/webfilter/import_categories_job'
require 'jobs/webfilter/build_db_job'

module Sykus

  describe Webfilter::ImportCategoriesJob do
    include FakeFS::SpecHelpers
    category_file = Webfilter::ImportCategoriesJob::CATEGORY_FILE

    let! (:oldcategory) { 
      Factory Webfilter::Category, name: 'bundle/cat',
      selected: :students
    }

    let (:name) { 'bundle/cat' }
    # use strings as keys, not symbols
    let (:data) { [ {
      'name' => name,
      'text' => 'text',
      'default' => 'all',
    } ] }

    before :each do
      FileUtils.mkdir_p File.dirname(category_file)
      File.open(category_file, 'w+') do |f|
        f.write data.to_yaml
      end
    end

    context 'no new categories' do
      let (:data) { [] }
      it 'deletes the old category' do
        oldid = oldcategory.id
        Webfilter::ImportCategoriesJob.perform

        Webfilter::Category.count.should == 0
        check_entity_evt(EntitySet.new(Webfilter::Category), oldid, true)
        Resque.dequeue(Webfilter::BuildDBJob).should == 1
      end
    end

    context 'same category name' do 
      it 'updates the category' do
        Webfilter::ImportCategoriesJob.perform

        Webfilter::Category.count.should == 1
        Webfilter::Category.first.name.should == data.first['name']
        Webfilter::Category.first.selected.should == :students
        Webfilter::Category.first.default.should == :all
        check_entity_evt(EntitySet.new(Webfilter::Category),
                         oldcategory.id, false)
        Resque.dequeue(Webfilter::BuildDBJob).should == 1
      end
    end

    context 'new category' do 
      let (:name) { 'new/cat' }
      it 'updates the category and deletes the old one' do
        oldid = oldcategory.id

        Webfilter::ImportCategoriesJob.perform

        Webfilter::Category.count.should == 1
        Webfilter::Category.first.name.should == data.first['name']
        Webfilter::Category.first.text.should == data.first['text']
        Webfilter::Category.first.default.should == :all
        Webfilter::Category.first.selected.should == :all
        check_entity_evt(EntitySet.new(Webfilter::Category), 
                         Webfilter::Category.first.id, false)
        check_entity_evt(EntitySet.new(Webfilter::Category), oldid, true)
        Resque.dequeue(Webfilter::BuildDBJob).should == 1
      end
    end

    context 'invalid category' do
      let (:name) { '@invalid$' }
      it 'does not import category' do
        Webfilter::ImportCategoriesJob.perform
        Webfilter::Category.count.should == 0
        Resque.dequeue(Webfilter::BuildDBJob).should == 1
      end
    end

  end

end

