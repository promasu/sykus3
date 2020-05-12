require 'common'

require 'services/files/get_file'

module Sykus; module Api

  class App
    get %r{^/files/(.+)/$} do |path|
      exception_wrapper do
        Files::GetFile.new(get_identity(true)).get_dir(path).to_json
      end
    end 

    get %r{^/files/(.+)$} do |path|
      exception_wrapper do
        file = Files::GetFile.new(get_identity(true)).get_file(path)
        content_type 'application/octet-stream'

        return File.read(file) if APP_ENV == :test
        send_file file
      end
    end 
  end

end; end

