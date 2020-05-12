# encoding: utf-8
require 'spec_helper'


module Sykus

  describe Users::GenerateUsername do
    let (:johndoe) { Users::FullUserName.new('John', 'Doe') }
    let (:longjohn) { Users::FullUserName.new('Johnnathon', 'Longjohnson') }
    let (:frenchdoe) { Users::FullUserName.new('Jöhn', 'Doé') }
    let (:dashdoe) { Users::FullUserName.new('Joe-Boy', 'Doe Coy') }
    let (:sysuser) { Users::FullUserName.new('Ot', 'Ro') }

    context 'with long name' do
      it 'generates proper username' do
        Users::GenerateUsername.run(longjohn).should == 'longjohnjohn'
      end
    end

    context 'non-ascii full name' do
      it 'converts to appropriate ascii' do
        Users::GenerateUsername.run(frenchdoe).should == 'doejoeh'
      end
    end 

    context 'whitespace and dash full name' do
      it 'converts to appropriate ascii' do
        Users::GenerateUsername.run(dashdoe).should == 'doecoyjoeb'
      end
    end

    context 'with no users present' do
      it 'generates simple username' do
        Users::GenerateUsername.run(johndoe).should == 'doejohn'
      end
    end

    context 'with already one "doejohn" present' do
      before :each do
        Factory Users::User, username: 'doejohn'
      end

      it 'generates number username' do
        Users::GenerateUsername.run(johndoe).should == 'doejohn1'
      end

      it 'returns same username if given ref id' do
        uid = Users::User.first(username: 'doejohn').id
        Users::GenerateUsername.run(johndoe, uid).should == 'doejohn'
      end

      it 'returns same username if username without number became available' do
        Factory Users::User, username: 'doejohn1'
        uid = Users::User.first(username: 'doejohn1').id
        Users::User.first(username: 'doejohn').destroy

        Users::GenerateUsername.run(johndoe, uid).should == 'doejohn1'
      end
    end
  end

end

