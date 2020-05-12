require 'common'

module Sykus; module Webfilter

  # Searches category entries.
  class SearchCategories < ServiceBase
    # Blacklist base directory.
    LIST_DIRECTORY = '/var/lib/sykus3/blacklists/vendor'

    # Find all categories that include the given domain name.
    # @param [Hash] args Argument hash.
    # @return [Array] Category names.
    def run(args)
      enforce_permission! :webfilter_read

      domain = args[:domain].to_s.downcase.strip

      # remove proto:// prefix
      domain = domain.split('://').last

      # remove /path/dir/ suffix
      domain = domain.split('/').first

      # remove www. prefix
      domain.gsub!(/^www\./, '')

      raise Exceptions::Input, 'Invalid domain' unless domain.length > 3

      lists = []
      expr = '^' + Shellwords.shellescape(domain) + '$'
      %x{grep -r #{expr} #{LIST_DIRECTORY}/*}.strip.split("\n").each do |line|
        list = line.split(':').first
        list.gsub!(LIST_DIRECTORY + '/', '')
        list = list.split('/')[0..-2].join('/')
        next unless list.include? '/'

        lists << list
      end

      { lists: lists.compact.uniq }
    end
  end

end; end

