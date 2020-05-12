require 'spec_helper'

require 'services/files/get_file'

require 'api/main'

module Sykus

  describe Files::GetFile do
    include FakeFS::SpecHelpers

    def app; Sykus::Api::App; end

    let (:user) { Factory Users::User }
    let (:session) { Factory Users::Session, user: user }
    let (:id) { IdentityTestGod.new }

    let (:get_file) { Files::GetFile.new id }

    before :each do
      id.user_id = user.id

      FileUtils.mkdir_p '/home/users/u1/dir1'
      File.open('/home/users/u1/dir1/file', 'w+') do |f|
        f.write 'abc'
      end
    end

    it 'returns correct directory data' do
      set_cookie 'session_id=' + session.id
      get '/files/home/'

      last_response.should be_ok
      json_response.should == get_file.get_dir('/home')
    end


    it 'returns correct file' do
      set_cookie 'session_id=' + session.id
      get '/files/home/dir1/file'

      last_response.should be_ok
      last_response.headers['Content-Type'].should == 
        'application/octet-stream'
      last_response.body.should == 'abc'
    end
  end

end

