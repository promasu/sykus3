require 'spec_helper'

module Sykus

  class StubEntity2 < StubEntity; end
  class FakeClass; end

  describe EntitySet do
    subject { EntitySet }

    it 'creates an instance' do
      x = subject.new(StubEntity)

      x.entity_class.should == StubEntity
      x.sub_set.should == nil
    end

    it 'creates an instance with subset' do
      x = subject.new(StubEntity, 'abc')

      x.entity_class.should == StubEntity
      x.sub_set.should == 'abc'
    end

    it 'has correct key' do
      x = subject.new(StubEntity)

      x.key.should == 'Sykus::StubEntity'
    end

    it 'has correct key with subset' do
      x = subject.new(StubEntity, 'abc')

      x.key.should == 'Sykus::StubEntity:abc'
    end

    it 'has correct equality' do
      x1 = subject.new(StubEntity)
      x2 = subject.new(StubEntity)
      x3 = subject.new(StubEntity, 'abc')
      x4 = subject.new(StubEntity, 'abc')
      x5 = subject.new(StubEntity2, 'abc')

      x1.should == x2
      x1.should_not == x3
      x1.should_not == x3

      x3.should == x4
      x4.should_not == x5
    end

    context 'invalid params' do
      it 'raises on invalid class' do
        expect {
          subject.new(FakeClass, 'abc')
        }.to raise_error
      end

      it 'raises on invalid sub set' do
        expect {
          subject.new(StubEntity, 123)
        }.to raise_error
      end
    end
  end

end

