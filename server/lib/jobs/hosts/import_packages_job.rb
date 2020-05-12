require 'common'

module Sykus; module Hosts

  # Imports all client software packages into DB.
  class ImportPackagesJob
    extend Resque::Plugins::Lock
    @queue = :fast

    # Base directory for client package data.
    PACKAGES_DIR = '/usr/lib/sykus3/server/cli/packages'

    # Runs the job.
    def self.perform
      updated_packages = []
      Dir[PACKAGES_DIR + '/**/*.yaml'].each do |package_file|
        data = YAML.load_file package_file
        id_name = File.basename(package_file, '.yaml')

        package = Package.first(id_name: id_name) || 
          Package.new(id_name: id_name)

        old = package if package.id

        package.attributes = {
          id_name: id_name, 
          name: data['name'].strip,
          text: data['text'].strip,
          category: data['category'].strip,
          installed: old ? old.installed : false,
          selected: old ? old.selected : data['default'], 
          default: data['default'],
        }

        unless data['apt'].nil? || data['apt'].is_a?(Array)
          LOG.error "Package error [#{id_name}]: apt property must be an array"
          next
        end

        unless package.valid?
          msg = package.errors.full_messages.join('. ')
          LOG.error "Package error [#{id_name}]: #{msg}"  
            next
        end

        package.save
        updated_packages << package.id_name

        entity_evt = EntityEvent.new(EntitySet.new(Package), package.id, false)
        EntityEventStore.save entity_evt
      end

      Package.all(:id_name.not => updated_packages).each do |package|
        entity_evt = EntityEvent.new(EntitySet.new(Package), package.id, true)
        EntityEventStore.save entity_evt

        package.destroy
      end
    end
  end

end; end

