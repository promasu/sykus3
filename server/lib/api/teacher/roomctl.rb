require 'common'

require 'services/teacher/get_roomctl'
require 'services/teacher/set_roomctl'

module Sykus; module Api

  class App
    get %r{^/roomctl/(\d+)$} do |id|
      exception_wrapper do
        Teacher::GetRoomctl.new(get_identity).run(id).to_json
      end
    end

    post %r{^/roomctl/(\d+)$} do |id|
      exception_wrapper do
        Teacher::SetRoomctl.new(get_identity).run(id, json_request).to_json
        204
      end
    end
  end

end; end

