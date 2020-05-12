module Sykus

  # Generates a NT hash.
  module NTHash

    # Returns a NT hash in hex.
    # @param [String] data Input data.
    # @return [String] Output hash.
    def self.get(data)
      raise unless data.is_a? String
      OpenSSL::Digest::MD4.hexdigest(data.encode('utf-16le')).downcase
    end
  end

end

