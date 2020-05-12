require 'spec_helper'

require 'services/common/get_entity_events'

module Sykus

  describe GetEntityEvents do
    let (:stub_set) { EntitySet.new StubEntity }

    let (:gee_service) { GetEntityEvents.new IdentityTestGod.new }
    let (:entity_evt) { EntityEvent }
    let (:store) { EntityEventStore }

    context 'race condition with update + delete' do
      it 'only returns last entry for each ID (update first)' do
        store.save entity_evt.new(stub_set, 1, false)
        store.save entity_evt.new(stub_set, 1, true)
        res = gee_service.get_events(stub_set, 1)

        res[:updated].should == [ ]
        res[:deleted].should == [ 1 ]
      end
      it 'only returns last entry for each ID (update first)' do
        store.save entity_evt.new(stub_set, 1, true)
        store.save entity_evt.new(stub_set, 1, false)
        res = gee_service.get_events(stub_set, 1)

        res[:updated].should == [ 1 ]
        res[:deleted].should == [ ]
      end
    end

    context 'with two updated and two deleted items' do
      before :each do
        store.save entity_evt.new(stub_set, 1, false)
        store.save entity_evt.new(stub_set, 2, false)
        store.save entity_evt.new(stub_set, 3, true)
        store.save entity_evt.new(stub_set, 4, true)
      end

      shared_examples_for :items_present do
        it 'has items in updated and deleted lists' do
          res[:updated].should == [ 1, 2 ]
          res[:deleted].should == [ 3, 4 ]
        end
      end

      shared_examples_for :items_empty do
        it 'has no items in lists' do
          res[:updated].should == []
          res[:deleted].should == []
        end
      end

      shared_examples_for :valid_timestamp do
        it 'has a valid timestamp' do
          res[:timestamp].should be_within(0.5).of Time.now.to_f
          res[:timestamp].should be < Time.now.to_f
        end
      end

      context 'returns correct lists and timestamp' do
        let (:res) { gee_service.get_events(stub_set, 42) }

        it_behaves_like :items_present
        it_behaves_like :valid_timestamp
      end

      context 'returns empty list on timestamp <= 0' do
        let (:res) { gee_service.get_events(stub_set, 0) }

        it_behaves_like :items_empty
        it_behaves_like :valid_timestamp
      end

      context 'returns empty list on timestamp = Time.now.to_f' do
        let (:res) { gee_service.get_events(stub_set, Time.now.to_f) }

        it_behaves_like :items_empty
        it_behaves_like :valid_timestamp
      end

      context 'returns empty list on timestamp = Time.now.to_f.to_s' do
        let (:res) { gee_service.get_events(stub_set, Time.now.to_f.to_s) }

        it_behaves_like :items_empty
        it_behaves_like :valid_timestamp
      end
    end

    context 'permission violations' do
      it 'raises on #get_events' do
        check_service_permission(
          :common_entity_events, 
          GetEntityEvents, 
          :get_events, stub_set, 1
        )
      end
    end
  end

end

