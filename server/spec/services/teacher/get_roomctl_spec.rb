require 'spec_helper'

require 'services/teacher/get_roomctl'

module Sykus

  describe Teacher::GetRoomctl do
    let (:identity) { IdentityTestGod.new } 
    let (:get_roomctl) { Teacher::GetRoomctl.new identity }

    let (:hg) { Factory Hosts::HostGroup }
    let (:hg2) { Factory Hosts::HostGroup }
    let (:host1) { Factory Hosts::Host, host_group: hg }
    let (:host2) { Factory Hosts::Host, host_group: hg }
    let (:host3) { Factory Hosts::Host, host_group: hg2 }

    let (:user1) { Factory Users::User, position_group: :student }
    let (:user2) { Factory Users::User, position_group: :person }
    let (:user3) { Factory Users::User, position_group: :student }

    subject { get_roomctl.run hg.id }

    context 'with flags disabled' do
      it 'returns correct values' do
        res = subject

        res[:screenlock].should == false
        res[:weblock].should == false
        res[:printerlock].should == false
        res[:soundlock].should == false
      end
    end

    context 'with flags enabled' do
      before :each do
        REDIS.set "Roomctl.#{hg.id}.screenlock", true
          REDIS.set "Roomctl.#{hg.id}.weblock", true
          REDIS.set "Roomctl.#{hg.id}.printerlock", true
          REDIS.set "Roomctl.#{hg.id}.soundlock", true
      end

      it 'returns correct values' do
        res = subject

        res[:screenlock].should == true
        res[:weblock].should == true
        res[:printerlock].should == true
        res[:soundlock].should == true
      end
    end

    context 'with no users' do
      it 'returns no screens' do
        subject[:screens].should == []
      end
    end

    context 'with three users logged in, two in hg, one is a student' do
      let! (:session1) { Factory Users::Session, user: user1, host: host1 }
      let! (:session2) { Factory Users::Session, user: user2, host: host2 }
      let! (:session3) { Factory Users::Session, user: user3, host: host3 }

      it 'returns one screen' do
        img = Digest::SHA256.hexdigest("SYKUSSCREENSHOT#{session1.id}")
        imgurl = "http://#{host1.ip.to_s}:81/#{img}.jpg"
          host_name = host1.host_group.name + '-' + host1.name
        subject[:screens].should == [ {
          host_name: host_name,
          user_name: user1.full_name.to_s,
          img: imgurl,
        } ]
      end
    end

    context 'with invalid host group' do
      it 'raises' do
        expect {
          get_roomctl.run 42
        }.to raise_error Exceptions::NotFound
      end
    end

    context 'permission violations' do
      it 'raises on #run' do
        check_service_permission(:teacher_roomctl, 
                                 Teacher::GetRoomctl, :run, 42)
      end
    end
  end

end

