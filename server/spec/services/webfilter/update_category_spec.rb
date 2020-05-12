require 'spec_helper'

require 'services/webfilter/update_category'
require 'jobs/webfilter/build_db_job'

module Sykus

  describe Webfilter::UpdateCategory do
    let (:identity) { IdentityTestGod.new } 
    let (:update_category) { Webfilter::UpdateCategory.new identity } 

    let (:selected) { :none }
    let (:category) { Factory Webfilter::Category, selected: selected }
    let (:id) { category.id }

    context 'unselect' do
      let (:selected) { :all }
      it 'works' do
        update_category.run(id, {
          selected: :none,
        })

        ref = Webfilter::Category.get id
        ref.selected.should == :none

        check_entity_evt(EntitySet.new(Webfilter::Category), id, false)
        Resque.dequeue(Webfilter::BuildDBJob).should == 1
      end
    end

    context 'select :all' do
      it 'works' do
        update_category.run(id, {
          selected: 'all',
        })

        ref = Webfilter::Category.get id
        ref.selected.should == :all

        check_entity_evt(EntitySet.new(Webfilter::Category), id, false)
        Resque.dequeue(Webfilter::BuildDBJob).should == 1
      end
    end

    context 'select :students' do
      it 'works' do
        update_category.run(id, {
          selected: 'students',
        })

        ref = Webfilter::Category.get id
        ref.selected.should == :students

        check_entity_evt(EntitySet.new(Webfilter::Category), id, false)
        Resque.dequeue(Webfilter::BuildDBJob).should == 1
      end
    end


    context 'errors' do
      it '#run raises on permission violations' do
        check_service_permission(:webfilter_write, 
                                 Webfilter::UpdateCategory, :run, 4200, {})
      end

      it '#run raises on invalid id' do
        expect {
          update_category.run(4200, {})
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

