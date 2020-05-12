require 'spec_helper'

module Sykus

  describe EntityEvent do
    subject { EntityEvent }

    let! (:stub_set)  { EntitySet.new(StubEntity, 'abc') }
    let! (:stub_set2) { EntitySet.new(StubEntity, 'def') }

    it 'creates an instance' do
      x = subject.new(stub_set, 12, false)

      x.entity_set.should == stub_set
      x.id.should == 12
      x.deleted.should == false
    end

    it 'has correct equality' do
      x1 = subject.new(stub_set, 1, false)
      x2 = subject.new(stub_set, 1, false)
      x3 = subject.new(stub_set, 1, true)
      x4 = subject.new(stub_set, 12, false)
      x5 = subject.new(stub_set2, 1, false)

      x1.should == x2
      x1.should_not == x3
      x1.should_not == x4
      x1.should_not == x5
    end

    context 'invalid params' do
      it 'raises on first param' do
        expect {
          subject.new({}, 12, false)
        }.to raise_error
      end

      it 'raises on second param' do
        expect {
          subject.new(stub_set, '1', false)
        }.to raise_error
      end
    end
  end

end

