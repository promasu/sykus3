require 'spec_helper'

module Sykus

  describe Calendar::Event do
    it { should have_property :id }
    it { should have_property :start }
    it { should have_property :end }
    it { should have_property :all_day }
    it { should have_property :title }
    it { should have_property :location }
    it { should have_property :created_at }

    it { should have_property :type }

    it { should belong_to :user }
    it { should belong_to :user_group }
    it { should belong_to :user_class }

    it { should validate_presence_of :start }
    it { should validate_presence_of :end }
    it { should validate_presence_of :all_day }
    it { should validate_presence_of :title }
    it { should validate_presence_of :type }

    context 'invalid dates' do
      subject { Factory Calendar::Event }

      it 'should raise if end is before start' do
        subject.end = Time.at(123)
        subject.start = Time.at(234)

        subject.should_not be_valid
      end

      it 'should raise if end is equal to start' do
        subject.end = Time.at(123)
        subject.start = Time.at(123)

        subject.should_not be_valid
      end
end

context 'private event' do
  let (:user) { Factory Users::User }
  subject { Factory Calendar::Event, type: :private, user: user }

  it 'should have valid cal-id' do
    subject.cal_id.should == "private:#{user.id}"
  end

  it 'should create valid cal object' do
    e = Factory Calendar::Event
    e.cal_id = "private:#{user.id}"
      e.type.should == :private
    e.should be_valid
  end
end

context 'global event' do
  subject { Factory Calendar::Event, type: :global }

  it 'should have valid cal-id' do
    subject.cal_id.should == 'global'
  end 

  it 'should create valid cal object' do
    e = Factory Calendar::Event
    e.cal_id = "global"
    e.type.should == :global
    e.should be_valid
  end
end

context 'teacher event' do
  subject { Factory Calendar::Event, type: :teacher }

  it 'should have valid cal-id' do
    subject.cal_id.should == 'teacher'
  end 

  it 'should create valid cal object' do
    e = Factory Calendar::Event
    e.cal_id = "teacher"
    e.type.should == :teacher
    e.should be_valid
  end
end

context 'grade event' do
  subject { Factory Calendar::Event, type: :grade, grade: 7 }

  it 'should have valid cal-id' do
    subject.cal_id.should == "grade:7"
  end 

  it 'should create valid cal object' do
    e = Factory Calendar::Event
    e.cal_id = "grade:7"
    e.type.should == :grade
    e.grade.should == 7
    e.should be_valid
  end

  it 'should be invalid without class' do
    subject.grade = nil
    subject.should_not be_valid
  end
end

context 'class event' do
  let (:uc) { Factory Users::UserClass }
  subject { Factory Calendar::Event, type: :class, user_class: uc }

  it 'should have valid cal-id' do
    subject.cal_id.should == "class:#{uc.id}"
  end 

  it 'should create valid cal object' do
    e = Factory Calendar::Event
    e.cal_id = "class:#{uc.id}"
      e.type.should == :class
    e.user_class.should == uc
    e.should be_valid
  end

  it 'should be invalid without class' do
    subject.user_class = nil
    subject.should_not be_valid
  end
end

context 'group event' do
  let (:ug) { Factory Users::UserGroup }
  subject { Factory Calendar::Event, type: :group, user_group: ug }

  it 'should have valid cal-id' do
    subject.cal_id.should == "group:#{ug.id}"
  end

  it 'should create valid cal object' do
    e = Factory Calendar::Event
    e.cal_id = "group:#{ug.id}"
      e.type.should == :group
    e.user_group.should == ug
    e.should be_valid
  end

  it 'should be invalid without group' do
    subject.user_group = nil
    subject.should_not be_valid
  end
end

context 'resource event' do
  let (:res) { Factory Calendar::Resource }
  subject { Factory Calendar::Event, type: :resource, resource: res }

  it 'should have valid cal-id' do
    subject.cal_id.should == "resource:#{res.id}"
  end

  it 'should create valid cal object' do
    e = Factory Calendar::Event
    e.cal_id = "resource:#{res.id}"
      e.type.should == :resource
    e.resource.should == res
    e.should be_valid
  end

  it 'should be invalid without group' do
    subject.resource = nil
    subject.should_not be_valid
  end
end


  end

end

