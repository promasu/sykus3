require 'spec_helper'

require 'webdav/main'

module Sykus

  describe WebDAV::AuthResource do
    def app; Sykus::WebDAV.app; end

    it 'requests auth if no info is given' do
      request '/dav/', method: 'PROPFIND'

      last_response.status.should == 401
      last_response.headers['WWW-Authenticate'].should =~ /^Basic/
    end 

    it 'requests auth if wrong info is given' do
      authorize 'user', 'badwolf'
      request '/dav/', method: 'PROPFIND'

      last_response.status.should == 401
    end

    it 'requests auth if password is expired' do
      user = Factory Users::User, password_expired: true
      webdav_auth user

      request '/dav/', method: 'PROPFIND'

      last_response.status.should == 401
    end

    it 'works if correct user is given' do
      webdav_auth
      request '/dav/', method: 'PROPFIND'

      last_response.status.should == 207
    end
  end

end

