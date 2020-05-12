require 'spec_helper'

module Sykus

  # all tests assume certain values in lib/config/quota.rb
  # change tests if you change config
  describe Users::CalculateQuotas do
    let (:user_count) { 100 }
    let (:total_space) { 100 * 1000 }
    let (:free_space) { 90 * 1000 }

    subject { Users::CalculateQuotas.get user_count, free_space, total_space }

    context 'with 10% full disk' do
      it 'returns correct values' do
        subject[:student].should be_within(500).of(4000)
        subject[:teacher].should be_within(1500).of(12000)
        subject[:admin].should == 20 * 1000
      end
    end

    context 'with 10% full disk and many users' do
      let (:user_count) { 1000 }

      it 'returns correct values' do
        subject[:student].should be_within(100).of(300)
        subject[:teacher].should be_within(300).of(900)
        subject[:admin].should == 20 * 1000
      end
    end

    context 'with 100% full disk' do
      let (:free_space) { 0 }

      it 'returns correct values' do
        subject[:student].should be_within(300).of(800)
        subject[:teacher].should be_within(300).of(2400)
        subject[:admin].should == 20 * 1000
      end
    end
  end

end

