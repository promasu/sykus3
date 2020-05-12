# encoding: utf-8
require 'common'

require 'jobs/users/update_samba_job'
require 'jobs/hosts/import_packages_job'
require 'jobs/printers/read_drivers_job'

require 'services/users/find_username'
require 'services/users/create_user'
require 'services/users/create_user_group'
require 'services/users/create_user_class'
require 'services/hosts/create_host'
require 'services/hosts/create_host_group'
require 'services/printers/create_printer'
require 'services/webfilter/create_entry'

require 'services/calendar/create_event'

module Sykus

  # Fill DB with demo-data.
  module DemoDataJob
    # Runs the job.
    def self.perform(db_size_factor = 1)
      # reproducable randomness
      srand 42

      # REVIEW: make this nice and clean

      unless `hostname`.strip == 'sykus-demo.de'
        raise 'Hostname is NOT sykus-demo.de. Aborting.'
      end

      system 'sudo stop sykus3'
      system 'sudo stop smbd'
      sleep 3

      DataMapper.auto_migrate!
      REDIS.flushdb

      identity = IdentityTestGod.new

      create_user = Users::CreateUser.new identity
      create_user_class = Users::CreateUserClass.new identity
      create_user_group = Users::CreateUserGroup.new identity
      find_username = Users::FindUsername.new identity

      create_host = Hosts::CreateHost.new identity
      create_host_group = Hosts::CreateHostGroup.new identity

      create_printer = Printers::CreatePrinter.new identity

      create_webfilter_entry = Webfilter::CreateEntry.new identity

      create_event = Calendar::CreateEvent.new identity


      # delete all data on filesystem (need bash for globs)
      system 'bash -c "sudo rm -rf /var/lib/sykus3/samba.tdb"'
      system 'bash -c "sudo rm -rf /home/users/u*"'
      system 'bash -c "sudo rm -rf /home/groups/{.g*,*}"'
      system 'bash -c "sudo rm -rf /home/share/admin/{.??*,*}"'
      system 'bash -c "sudo rm -rf /home/share/teacher/{.??*,*}"'
      system 'bash -c "sudo rm -rf /home/share/progdata/{.??*,*}"'

      create_user.run username: 'admin', 
        first_name: 'Andreas', 
        last_name: 'Admin', 
        birthdate: '01.01.1990',
        position_group: :person,
        admin_group: :super

      identity.user_id = Users::User.first(username: 'admin').id

      #
      # demo data
      #

      Config::ConfigValue.set('demo', true)
      Config::ConfigValue.set('school_name', 'Demoschule')
      Config::ConfigValue.set('wlan_ssid', 'Sykus Demo')
      Config::ConfigValue.set('wlan_key', 'sonnenschein')

      # UserClass
      (7..9).each do |num|
        'ab'.split('').each do |alpha|
          create_user_class.run({
            name: num.to_s + alpha
          })
        end
      end

      # User + UserGroup
      first_names_teacher = %w{
        Nicole Anja Claudia Stefanie Andrea Tanja Katrin Susanne Petra Sabine 
        Sandra Britta Martina Silke Birgit Christina Manuela Heike Katja
        Stefan Michael Andreas Thomas Frank Markus Christian Oliver Matthias 
        Torsten Martin Sven Alexander Dirk Karsten Ralf Jörg Jan Mark Peter
      }

      first_names_student = %w{
        Lisa Julia Anna Laura Vanessa Annika Franziska Sarah Jennifer Katharina 
        Johanna Nadine Jessica Lena Ann Jasmin Jacqueline Jana Kim Karoline 
        Jan Philipp Max Dennis Kevin Tobias Tim Lukas Florian Marcel Felix
        Sebastian Alexander Daniel Jonas Max Yannik Fabian Patrik Timo
      }

      last_names = %w{
        Schulz Hoffmann Schäfer Bauer Koch Richter Klein Wolf Schräder Neumann 
        Schwarz Braun Zimmermann Hartmann Krüger Werner Lange Schmitz Krause
        Lehmann Huber Walter König Schulze Fuchs Kaiser Peters Scholz Jung 
        Müller Schmidt Schneider Fischer Weber Meyer Wagner Becker 
        Böhm Winter Ludwig Vogt Jäger Haas Brandt Kuhn Schulte Pohl Sauer 
        Bergmann Möller Hahn Keller Vogel Schubert Roth Beck Berger Lorenz 
        Winkler Schuster Busch Seifert Kern Barth Hermann Nagel Grimm Bock 
        Langer Haase Lutz Kraft Michel Marx Berg Arndt Petersen Reinhardt 
        Ebert Gruber Hein Bayer
      }

      user_group_names = %w{
        Englisch Deutsch Mathe Französisch Latein Erdkunde Geschichte
        Informatik Chemie Biologie Physik Politik Klassenfahrt 
      }


      # User Teachers
      (db_size_factor * 7).times do
        name = {
          first_name: first_names_teacher.sample,
          last_name: last_names.sample,
        }
        username = find_username.run(name)[:username]
        create_user.run({
          username: username,
          position_group: 'teacher',
          admin_group: (rand(1..5) == 5) ? 'senior' : 'none',
          birthdate: dob(40, 20),
        }.merge(name))
      end

      user_classes = Users::UserClass.all.map { |uc| uc.id }

      (Users::User.all(position_group: :teacher) + 
       Users::User.first(username: 'admin')).each do |user|
        # UserGroup creation + ownership
        2.times do 
          name_addon = 
            case rand 0..2
            when 0 
              ' Jg. ' + Users::UserClass.get(user_classes.sample).grade.to_s
            when 1 
              ' Kl. ' + Users::UserClass.get(user_classes.sample).name.to_s
            else
              ''
            end
          create_user_group.run({
            name: user_group_names.sample + name_addon,
            owner: user.id,
            users: [ user.id ],
          })
        end
       end

      # User Students
      (db_size_factor * 25).times do 
        name = {
          first_name: first_names_student.sample,
          last_name: last_names.sample,
        }
        username = find_username.run(name)[:username]
        create_user.run({
          username: username,
          position_group: 'student',
          admin_group: (rand(1..20) == 20) ? 'junior' : 'none',
          user_class: user_classes.sample,
          birthdate: dob(15, 3),
        }.merge(name))
      end

      # User Students to User Groups
      user_list = Users::User.all(position_group: :student)
      admin = Users::User.first(username: 'admin') 
      Users::UserGroup.each do |ug|
        ug.users = [ ug.owner ] + (0..10).map { user_list.sample }
        ug.users << admin if rand(0..1) == 0
        ug.save
      end

      # Host Groups
      %w{raum110 admin raum112 lehrerzimmer bibliothek}.each do |name|
        hg = create_host_group.run({
          name: name,
        })[:id]

        (db_size_factor * 3).times do |i|
          hid = create_host.run({
            name: 'pc%02d' % (i + 1),
            host_group: hg,
            mac: (1..6).map { '%02x' % rand(255) }.join(':'),
          })[:id]

          h = Hosts::Host.get(hid)
          h.cpu_speed = rand(60..400)
          h.ram_mb = 2 ** rand(9..13)
          h.ready = (rand(0..5) > 0)
          h.save
        end
      end

      # reset all passwords
      Users::User.all.each do |user|
        password = 'demo'

        # do not modify user.password_initial (for demo purposes)

        user.password_expired = false
        user.password_sha256 = Digest::SHA256.hexdigest(password)
        user.password_nt = NTHash.get password 

        Resque.enqueue Users::UpdateSambaJob, user.username
        user.save
      end

      Hosts::ImportPackagesJob.perform
      Hosts::Package.all(default: true).each do |pack| 
        pack.installed = true
        pack.save
      end

      # Printers
      Printers::ReadDriversJob.perform

      create_printer.run name: 'Laserdrucker-Raum-110', 
        host_groups: [ Hosts::HostGroup.first(name: 'raum110').id ],
        driver: 'drv:///c2esp.drv/Kodak_ESP_9.ppd',
        url: 'socket://10.42.10.1'

      create_printer.run name: 'Drucker-Lehrerzimmer', 
        host_groups: [ Hosts::HostGroup.first(name: 'lehrerzimmer').id ],
        driver: 'drv:///hpijs.drv/hp-915-hpijs.ppd',
        url: 'socket://10.42.10.2'

      # Webfilter Entries
      create_webfilter_entry.run domain: 'verybad.com', 
        comment: 'Gewaltdarstellung, nicht in Blacklist.',
        type: :black_all

      create_webfilter_entry.run domain: 'youtube.com', 
        comment: 'YouTube nur für Lehrer.',
        type: :nonstudents_only

      create_webfilter_entry.run domain: 'wikipedia.org', 
        comment: 'WP immer erlaubt.',
        type: :white_all

      # Demo Files + Folders
      Users::User.each do |user|
        dir = "/home/users/u#{user.id}"
        FileUtils.mkdir_p "#{dir}/Dokumente"
        FileUtils.mkdir_p "#{dir}/Hausaufgaben"
        FileUtils.mkdir_p "#{dir}/Projektarbeit"

        FileUtils.touch "#{dir}/Aufgabenliste.txt"
        FileUtils.touch "#{dir}/Dokumente/Periodensystem.txt"

        FileUtils.chown_R user.system_id, nil, dir
      end

      Users::UserGroup.each do |group|
        dir = "/home/groups/.g#{group.id}"
        FileUtils.mkdir_p "#{dir}/Aufgaben"
        FileUtils.mkdir_p "#{dir}/Infomaterial"

        FileUtils.touch "#{dir}/Info.txt"
        FileUtils.touch "#{dir}/Aufgaben/Aufgabe 1.txt"
        FileUtils.touch "#{dir}/Aufgaben/Aufgabe 2.txt"
        FileUtils.touch "#{dir}/Infomaterial/Klausurthemen.txt"

        FileUtils.chown_R nil, group.system_id, dir
      end

      dir = "/home/share/progdata"
      FileUtils.mkdir_p "#{dir}/Infomaterial"
      FileUtils.touch "#{dir}/Open Source Software.txt"
      FileUtils.touch "#{dir}/Infomaterial/Info.txt"

      dir = "/home/share/teacher"
      FileUtils.mkdir_p "#{dir}/Alte Klausuren"
      FileUtils.touch "#{dir}/WLAN Passwort.txt"

      dir = "/home/share/admin"
      FileUtils.mkdir_p "#{dir}/Printserver Passwörter"
      FileUtils.touch "#{dir}/IP Bereiche.txt"


      #
      # Calendar
      # 

      [
        { 
        start: time(1, 3,  8), 
        :end => time(1, 3, 10), 
        all_day: false, 
        cal_id: 'global',
        title: 'Bücherausgabe', 
        location: 'Raum A032'
      },  { 
        start: time(2, 1,  16), 
        :end => time(2, 1, 18), 
        all_day: false, 
        cal_id: 'global',
        title: 'Vortrag Studium', 
        location: 'Aula'
      },
        { 
        start: time(2, 5,  5), 
        :end => time(3, 4, 6), 
        all_day: true, 
        cal_id: 'global',
        title: 'Hitzefrei', 
        location: ''
      },
        { 
        start: time(4, 5,  5), 
        :end => time(4, 5, 6), 
        all_day: true, 
        cal_id: 'global',
        title: 'Sportfest', 
        location: 'Sportplatz 2'
      },

      ].each do |event|
        create_event.run event
      end


      # restore "true" randomness
      srand

      # run postinstall hooks (since db got deleted)
      system 'sudo /usr/lib/sykus3/server/sykus-tool postinstall'

      system 'sudo start smbd'
      system 'sudo start sykus3'
    end

    private
    def self.time(week, weekday, hours)
      day = DateTime.now - DateTime.now.day + 1
      day -= 1 until day.monday?

      day += (7 * (week - 1)) + (weekday - 1)

      day.to_date.to_time.to_i + (hours * 3600)
    end

    def self.dob(age, delta)
      year = Time.now.year - age 
      '%02d' % rand(1..27) + '.' + '%02d' % rand(1..12) + '.' +
        rand((year - delta)..(year + delta)).to_s
    end

  end

end

