require 'spec_helper'

require 'api/main'

module Sykus

  class MyApp < Api::App
    get '/test/input' do
      exception_wrapper do
        raise Exceptions::Input, 'xxx'
      end
    end

    get '/test/notfound' do
      exception_wrapper do
        raise Exceptions::NotFound, 'xxx'
      end
    end

    get '/test/permission' do
      exception_wrapper do
        perm = Config::Permissions::PermissionList.first
        raise Exceptions::Permission.new(perm)
      end
    end

    get '/test/server' do
      exception_wrapper do
        raise 'xxx'
      end
    end

    get '/snitest/input' do
      sni_exception_wrapper do
        raise Exceptions::Input, 'xxx'
      end
    end

    get '/snitest/notfound' do
      sni_exception_wrapper do
        raise Exceptions::NotFound, 'xxx'
      end
    end

    get '/snitest/server' do
      sni_exception_wrapper do
        raise 'xxx'
      end
    end
  end

  describe 'Sykus::Api::App Identity Management' do
    def app; MyApp; end

    it 'creates an input error' do
      get '/test/input'

      last_response.status.should == 400
      last_response.body.should include 'xxx'
    end

    it 'creates a not found error' do
      get '/test/notfound'

      last_response.status.should == 404
      last_response.body.should include 'xxx'
    end

    it 'creates a permission error' do
      get '/test/permission'
      perm = Config::Permissions::PermissionList.first

      last_response.status.should == 401
      last_response.body.should include perm.to_s
    end

    it 'creates a server error' do
      get '/test/server'

      last_response.status.should == 500
      last_response.body.should_not include 'xxx'
    end

    context 'SNI error handler' do
      it 'creates an input error' do
        get '/snitest/input'

        last_response.status.should == 200
        last_response.body.should == 'err:input'
      end

      it 'creates a not found error' do
        get '/snitest/notfound'

        last_response.status.should == 200
        last_response.body.should == 'err:notfound'
      end


      it 'creates a server error' do
        get '/snitest/server'

        last_response.status.should == 200
        last_response.body.should == 'err:internal'
      end
    end
  end

end

