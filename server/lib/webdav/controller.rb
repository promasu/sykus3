require 'common'

module Sykus; module WebDAV

  # Controller add-ons / modifications.
  class Controller < DAV4Rack::Controller
    include DAV4Rack::HTTPStatus

    # This is non-standard, but include it to prevent exceptions
    def userinfo; NotImplemented; end

    # No locking (stubbed out, because Mac OS does not allow writing without)
    def lock; OK; end
    # No unlocking either... 
    def unlock; OK; end

    # No custom properties.
    def proppatch; Forbidden; end

    # Generate allprop XML document.
    def allprop_xml
      Nokogiri::XML::Builder.new do |xml|
        xml['D'].propfind({ 'xmlns:D' => 'DAV:'}) { |pf| pf.allprop }
      end.doc
    end

    # Spec says that empty body equals allprop request, 
    # but dav4rack raises on empty body
    def request_document
      super
      @request_document = allprop_xml if @request_document.children.empty?
      @request_document
    end

    # MS clients need unauthorized OPTIONS request
    def authenticate
      return true if @request.request_method == 'OPTIONS'
      super
    end
  end

end; end

