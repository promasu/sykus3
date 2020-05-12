require 'common'

require 'services/webfilter/search_categories'

module Sykus; module Api

  class App
    post '/webfilter/search/' do
      exception_wrapper do
        Webfilter::SearchCategories.new(get_identity).run(json_request).to_json
      end
    end
  end

end; end

