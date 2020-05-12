require 'spec_helper'

require 'webdav/main'

module Sykus

  describe WebDAV::Controller do
    def app; Sykus::WebDAV.app; end

    it 'does not allow proppatch' do
      webdav_auth
      request '/dav/', method: 'PROPPATCH'

      last_response.status.should == 403
    end

    it 'does implement locking' do
      webdav_auth
      request '/dav/', method: 'LOCK'

      last_response.status.should == 200
    end

    it 'does implement unlocking' do
      webdav_auth
      request '/dav/', method: 'UNLOCK'

      last_response.status.should == 200
    end

    it 'does not implement userinfo (non-standard)' do
      webdav_auth
      request '/dav/', method: 'USERINFO'

      last_response.status.should == 501
    end

    it 'allows empty request body for propfind' do
      webdav_auth
      request '/dav', method: 'PROPFIND'

      last_response.status.should == 207
      last_response.body.should include '200 OK'
    end

    it 'returns correct options and does not require auth' do
      options '/dav/'

      last_response.should be_ok
      last_response.headers['DAV'].should == '1, 2'
      last_response.headers['Allow'].split(',').should =~
      %w{
      GET HEAD POST PUT DELETE OPTIONS MKCOL 
      COPY MOVE PROPPATCH PROPFIND LOCK UNLOCK
      }
    end
  end

end

