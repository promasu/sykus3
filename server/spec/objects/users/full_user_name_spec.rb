require 'spec_helper'

module Sykus

  describe Users::FullUserName do
    subject { Users::FullUserName }

    it 'creates a valid object' do
      user = subject.new('John', 'Doe')

      user.validate!
      user.to_s.should == 'John Doe'
    end

    it 'creates a valid object with long name' do
      user = subject.new('John-Abraham', 'Doe Dudoder')

      user.validate!
      user.to_s.should == 'John-Abraham Doe Dudoder'
    end

    it 'strips whitespace' do
      user = subject.new(' John', 'Doe ')
      user.validate!
      user.first_name.should == 'John'
      user.last_name.should == 'Doe'
      user.to_s.should == 'John Doe'
    end

    it 'has proper equality' do
      x1 = subject.new('John', 'Doe')
      x2 = subject.new('John', 'Doe')
      x3 = subject.new('Bob', 'Dane')

      x1.should == x2
      x1.should_not == x3
    end

    context 'errors' do
      shared_examples_for :fails do
        it 'fails on last name' do
          expect {
            subject.new('John', name).validate!
          }.to raise_error Exceptions::Input
        end

        it 'fails on first name' do
          expect {
            subject.new(name, 'Doe').validate!
          }.to raise_error Exceptions::Input
        end
      end  

      [ 
        # no numbers
        42,
        'John2',

        # no special chars
        '$John', 
      ].each do |cur|
        it_should_behave_like :fails do
          let (:name) { cur }
        end
      end

    end
  end

end

