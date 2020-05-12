require 'common'

require 'jobs/webfilter/build_db_job'

module Sykus; module Webfilter

  # Imports all webfilter categories into DB.
  class ImportCategoriesJob
    extend Resque::Plugins::Lock
    @queue = :fast

    # Category definition file.
    CATEGORY_FILE = '/var/lib/sykus3/blacklists/vendor/categories.yaml'

    # Runs the job.
    def self.perform
      updated_categories = []
      YAML.load_file(CATEGORY_FILE).each do |cat_def|
        name = cat_def['name'].strip

        category = Category.first(name: name) || 
          Category.new(name: name)

        old = category if category.id

        category.attributes = {
          name: name,
          text: cat_def['text'].strip,
          selected: old ? old.selected : cat_def['default'].to_sym, 
          default: cat_def['default'].to_sym,
        }

        unless category.valid?
          msg = category.errors.full_messages.join('. ')
          LOG.error "Category error [#{name}]: #{msg}"  
            next
        end

        category.save
        updated_categories << category.name

        entity_evt = EntityEvent.new(EntitySet.new(Category), 
                                     category.id, false)
        EntityEventStore.save entity_evt
      end

      Category.all(:name.not => updated_categories).each do |category|
        entity_evt = EntityEvent.new(EntitySet.new(Category),
                                     category.id, true)
        EntityEventStore.save entity_evt

        category.destroy
      end

      Resque.enqueue BuildDBJob
    end
  end

end; end

