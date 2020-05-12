require 'spec_helper'

require 'services/calendar/find_event'

module Sykus

  describe Calendar::FindEvent do
    let (:identity) { IdentityTestGod.new }
    let (:find_event) { Calendar::FindEvent.new identity }

    let (:user) { Factory Users::User }
    let (:ug) { Factory Users::UserGroup }
    let (:ug2) { Factory Users::UserGroup }
    let (:uc) { Factory Users::UserClass }
    let (:uc2) { Factory Users::UserClass }
    let (:res) { Factory Calendar::Resource }
    let (:res2) { Factory Calendar::Resource }

    let! (:event_global) { Factory Calendar::Event, type: :global }
    let! (:event_teacher) { Factory Calendar::Event, type: :teacher }
    let! (:event_private) { 
      Factory Calendar::Event, user: user, type: :private 
    }
    let! (:event_group) { 
      Factory Calendar::Event, type: :group, user_group: ug
    }
    let! (:event_group2) { 
      Factory Calendar::Event, type: :group, user_group: ug2
    }
    let! (:event_grade) { 
      Factory Calendar::Event, type: :grade, grade: 7
    }
    let! (:event_grade2) { 
      Factory Calendar::Event, type: :grade, grade: 42
    }
    let! (:event_class) { 
      Factory Calendar::Event, type: :class, user_class: uc
    }
    let! (:event_class2) { 
      Factory Calendar::Event, type: :class, user_class: uc2
    }
    let! (:event_res) { 
      Factory Calendar::Event, type: :resource, resource: res
    }
    let! (:event_res2) { 
      Factory Calendar::Event, type: :resource, resource: res2
    }


    before :each do
      identity.user_id = user.id
    end

    def check_event(result, ref)
      result[:id].should == ref.id
      result[:title].should == ref.title
      result[:location].should == ref.location
      result[:all_day].should == ref.all_day
      result[:start].should == ref.start.to_i
      result[:end].should == ref.end.to_i
      result[:created_at].should == ref.created_at.to_i
      result[:user].should == ref.user.id
    end

    context 'returns all events of a type' do
      subject { find_event.all_by_cal_id('global') }

      before :each do
        Calendar::Event.destroy
        3.times { Factory Calendar::Event, title: 'title', type: :global }
      end

      it { should be_a Array }

      it 'returns correct number of events' do 
        subject.count.should == 3
      end

      it 'returns correct event data' do
        subject.each do |event|
          event[:title].should == 'title'
        end
      end
    end

    context 'correct results for each cal id type' do
      it 'is correct for global' do
        find_event.all_by_cal_id('global').should == 
          [ find_event.by_id(event_global.id) ]
      end

      it 'is correct for teacher' do
        find_event.all_by_cal_id('teacher').should == 
          [ find_event.by_id(event_teacher.id) ]
      end

      it 'is correct for private' do
        find_event.all_by_cal_id("private:#{user.id}").should == 
          [ find_event.by_id(event_private.id) ]
      end

      it 'is correct for group' do
        find_event.all_by_cal_id("group:#{ug.id}").should == 
          [ find_event.by_id(event_group.id) ]
      end

      it 'is correct for grade' do
        find_event.all_by_cal_id("grade:7").should == 
          [ find_event.by_id(event_grade.id) ]
      end

      it 'is correct for class' do
        find_event.all_by_cal_id("class:#{uc.id}").should == 
          [ find_event.by_id(event_class.id) ]
      end

      it 'is correct for resource' do
        find_event.all_by_cal_id("resource:#{res.id}").should == 
          [ find_event.by_id(event_res.id) ]
      end


      it 'raises on insuffienct permissions' do
        identity.only_permission(nil)

        expect {
          find_event.all_by_cal_id("group:#{ug.id}")
        }.to raise_error Exceptions::Permission
      end
    end

    context 'finds event by id' do
      it 'finds correct event with all attributes' do
        res = find_event.by_id(event_global.id)
        check_event res, event_global
      end

      it 'raises on invalid event' do
        expect {
          find_event.by_id(42000)
        }.to raise_error Exceptions::NotFound
      end

      it 'raises on insufficient permissions' do
        identity.only_permission(nil)

        expect {
          find_event.by_id(event_teacher.id)
        }.to raise_error Exceptions::Permission
      end
    end

  end

end

