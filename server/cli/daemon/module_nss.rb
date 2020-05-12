module NSS
  def self.hooks(scheduler)
    scheduler.every '1m' do
      download true
    end

    # be network-fault tolerant, download only if db isn't valid
    scheduler.every '5s' do
      download
    end
  end

  def self.download(scheduled_get = false)
    unless scheduled_get
      testfile = '/var/lib/misc/passwd.db'
      return if File.exists?(testfile) && File.size(testfile) > 1024
    end

    %x{#{
      "curl -s -m3 -o /var/lib/misc/passwd.db " + 
      "https://#{Util.server_domain}/nssdb/users_client.db"
    }}

    %x{#{
      "curl -s -m3 -o /var/lib/misc/group.db " + 
      "https://#{Util.server_domain}/nssdb/groups.db"
    }}
  end
end

