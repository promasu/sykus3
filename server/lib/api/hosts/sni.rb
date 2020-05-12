require 'common'


require 'services/users/create_session'
require 'services/hosts/find_host_group'
require 'services/hosts/create_host'
require 'services/hosts/confirm_host'

module Sykus; module Api

  class App
    get '/sni/login' do
      sni_exception_wrapper do
        Users::CreateSession.new(IdentityAnonymous.new).
          run(params, true)[:id]
      end
    end

    get '/sni/add' do
      sni_exception_wrapper do 
        Hosts::CreateHost.new(sni_get_identity).run(params)
        'ok'
      end
    end

    get '/sni/groups' do
      sni_exception_wrapper do 
        Hosts::FindHostGroup.new(sni_get_identity).all.map { |hg| 
          hg[:name] 
        }.sort.join(', ')
      end
    end

    get '/sni/confirm' do
      sni_exception_wrapper do
        Hosts::ConfirmHost.new(IdentityAnonymous.new).
          run(get_ip, params)
        'ok'
      end
    end
  end

end; end

