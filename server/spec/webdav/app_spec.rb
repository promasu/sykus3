require 'spec_helper'

require 'webdav/main'

module Sykus

  describe 'WebDAV App' do
    it 'is a valid app' do
      WebDAV.app.should be_a Rack::URLMap
    end
  end

end

