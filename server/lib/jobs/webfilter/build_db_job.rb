require 'common'

module Sykus; module Webfilter

  # Creates new Webfilter DBs and restarts squid.
  class BuildDBJob
    extend Resque::Plugins::Queue::Lock
    extend Resque::Plugins::Workers::Lock
    @queue = :slow

    # Category data directory.
    CATEGORY_DIR = '/var/lib/sykus3/blacklists/vendor'

    # Compiled DB output directory
    OUT_DIR = '/var/lib/sykus3/blacklists'

    # Runs the job.
    def self.perform
      # use hashes instead of arrays for performance reasons (see below)
      urls = { 
        black_students: {},
        black_all: {},
      }
      domains = { 
        white_all: {},
        white_nonstudents: {},
        black_students: {},
        black_all: {},
      }

      Entry.each do |entry|
        domain = entry.domain.strip

        case entry.type
        when :white_all
          domains[:white_all][domain] = true
        when :nonstudents_only
          domains[:white_nonstudents][domain] = true
          domains[:black_students][domain] = true
        when :black_all
          domains[:black_all][domain] = true
        end
      end

      Category.each do |cat|
        type = 
          case cat.selected
          when :students
            :black_students
          when :all
            :black_all
          else
            next
          end

        cat_url = "#{CATEGORY_DIR}/#{cat.name}/urls"
          cat_domain = "#{CATEGORY_DIR}/#{cat.name}/domains" 
          if File.exists? cat_url
            File.read(cat_url, encoding: 'binary').split("\n").each do |u|
              urls[type][u.strip] = true
            end
          end
        if File.exists? cat_domain
          File.read(cat_domain, encoding: 'binary').split("\n").each do |d|
            domains[type][d.strip] = true
          end
        end
      end

      domains.keys.each do |key|
        # sort out subdomains that have a base domain
        # to enable whole-domain blocking, this is required
        # due to an ill-designed feature in squidguard
        domains[key].select! do |domain, _|
          # sort out invalid entries
          next false unless domain.include? '.'

          base = domain
          loop do
            base = base.split('.')[1..-1].join('.')
            break true if base.empty?
            break false if domains[key].include? base
          end
        end

        File.open("#{OUT_DIR}/domains_#{key}.tmp", 'w+') do |f|
          domains[key].keys.each do |domain|
            f.write(domain + "\n")
          end
        end
      end

      urls.keys.each do |key|
        File.open("#{OUT_DIR}/urls_#{key}.tmp", 'w+') do |f|
          urls[key].keys.each do |url|
            f.write(url + "\n")
          end
        end
      end

      system 'squidGuard -c /etc/squidguard/compile.conf -C all'

      urls.keys.each do |key|
        FileUtils.mv "#{OUT_DIR}/urls_#{key}.tmp.db", 
          "#{OUT_DIR}/urls_#{key}.db"
      end

      domains.keys.each do |key|
        FileUtils.mv "#{OUT_DIR}/domains_#{key}.tmp.db", 
          "#{OUT_DIR}/domains_#{key}.db"
      end

      system "sudo chown proxy #{OUT_DIR}/*.db"
      system 'sudo squid3 -k reconfigure'
    end
  end

end; end

