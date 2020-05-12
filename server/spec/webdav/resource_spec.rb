require 'spec_helper'

require 'webdav/main'

module Sykus

  describe WebDAV::Resource do
    def app; Sykus::WebDAV.app; end

    it 'does not allow proppatch' do
      webdav_auth
      request '/dav/', method: 'PROPPATCH'

      last_response.status.should == 403
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
  end

end

