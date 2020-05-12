# encoding: utf-8
require 'spec_helper'


module Sykus

  describe NormalizeString do
    subject { NormalizeString.run str }

    context 'strips whitespace' do
      let (:str) { ' abc  ' }
      it { should == 'abc' }
    end

    context 'converts to lowercase' do
      let (:str) { 'AbCd' }
      it { should == 'abcd' }
    end

    context 'converts accented chars correctly' do
      let (:str) { 'áà' }
      it { should == 'aa' }
    end

    context 'converts german umlauts correctly' do
      let (:str) { 'äöü ÄÖÜ' }
      it { should =='aeoeue aeoeue' }
    end

    context 'converts german esszett' do
      let (:str) { 'ß' }
      it { should == 'ss' }
    end
  end

end

