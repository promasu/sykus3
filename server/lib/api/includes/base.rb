require 'common'

module Sykus; module Api

  # Api Sinatra App.
  # All Api methods are added to this class.
  class App < Sinatra::Base
    set :raise_errors, true
    set :logging, nil
    set :static, false
    set :show_exceptions, false
    set :protection, reaction: :default_reaction

    before do
      content_type 'application/json', charset: 'utf-8'
    end

    # Sinatra#not_found does not work since it also catches app generated
    # 404 errors
    error Sinatra::NotFound do
      'Not Found'.to_json
    end
  end

end; end


