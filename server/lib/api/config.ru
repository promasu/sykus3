$:.unshift(File.dirname(__FILE__) + '/../')

require 'api/main'

begin
  run Sykus::Api::App
rescue Exception => e
  Sykus::LOG.exception 'API Outside', e
end


