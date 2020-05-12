module Sykus; module Printers

  # Checks whether the given URL is a valid Sykus printer URL.
  module ValidPrinterURL

    # Raises if not valid.
    # @param [String] str Input string
    def self.enforce!(str)
      url = URI str

      unless %w{ipp lpd socket}.include? url.scheme
        raise Exceptions::Input, 'Invalid URL scheme'
      end

      ip = IPAddr.new url.host
      if ip < IPAddr.new('10.42.2.1') || ip > IPAddr.new('10.42.99.254') 
        raise Exceptions::Input, 'IP must be in custom assign range.'
      end

      if url.query or url.fragment 
        raise Exceptions::Input, 'URL query/fragment' 
      end
    rescue Exception
      raise Exceptions::Input, 'Invalid URL' 
    end
  end

end; end

