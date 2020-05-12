require 'spec_helper'

require 'services/users/find_user_class'
require 'services/users/create_user_class'

require 'api/main'

module Sykus

  describe 'Users::ImportUsers API' do
    def app; Sykus::Api::App; end

    context 'POST /userimport/' do
      # smoke test only
      it 'returns array' do
        data = {
          data: '',
          delete: true,
          type: :student,
          confirm: true,
        }.to_json
        post '/userimport/', data

        last_response.should be_ok
        last_response.body.should == { result: [] }.to_json
      end
    end
  end

end

