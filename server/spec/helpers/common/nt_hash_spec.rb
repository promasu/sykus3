# encoding: utf-8
require 'spec_helper'

module Sykus

  describe NTHash do
    it 'is correct for test string' do
      NTHash.get('The quick brown fox jumps over the lazy dog').should ==
        '4e6a076ae1b04a815fa6332f69e2e231'
    end

    it 'is correct for empty string' do
      NTHash.get('').should == '31d6cfe0d16ae931b73c59d7e0c089c0'
    end

    it 'fails for non-string' do
      expect {
        NTHash.get 123
      }.to raise_error
    end
  end

end

