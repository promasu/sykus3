require 'spec_helper'


module Sykus

  describe EntityEventStore do

    let! (:stub_set) { EntitySet.new StubEntity }

    let (:event) { EntityEvent.new(stub_set, 12, false) }
    let (:event2) { EntityEvent.new(stub_set, 42, false) }


    before :each do
      REDIS.flushdb
      subject.save event
    end

    context 'one saved event' do
      it 'can save the same event again with not effect' do
        subject.save event
        res = subject.get_events_since(stub_set, 1)
        res.should == [ event ]
      end

      it 'can retrieve the event' do
        res = subject.get_events_since(stub_set, 1)
        res.should == [ event ]
      end

      it 'returns nothing on current timestamp' do
        res = subject.get_events_since(stub_set, Time.now.to_f)
        res.should == []
      end

      it 'returns the event on current timestamp - 5' do
        res = subject.get_events_since(stub_set, Time.now.to_f - 5.0)
        res.should == [ event ]
      end

      it 'returns both events after saving the second' do
        subject.save event2
        res = subject.get_events_since(stub_set, 1)
        res.should == [ event, event2 ]
      end

      it 'returns only the second event with close timestamp' do
        ts = Time.now.to_f
        subject.save event2
        res = subject.get_events_since(stub_set, ts)
        res.should == [ event2 ]
      end
    end

  end

end

