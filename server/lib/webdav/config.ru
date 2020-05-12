$:.unshift(File.dirname(__FILE__) + '/../')

require 'webdav/main'

begin
  run Sykus::WebDAV.app
rescue Exception => e
  Sykus::LOG.exception 'WebDAV Outside', e
end


