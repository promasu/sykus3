require 'spec_helper'

require 'webdav/main'

module Sykus

  describe WebDAV::InterceptorResource do
    def app; Sykus::WebDAV.app; end

    def check_dirs(dirlist) 
      request '/dav/', method: 'PROPFIND'
      last_response.status.should == 207

      result = Nokogiri::XML.parse last_response.body

      ns = { 'D' => 'DAV:' }
      nl = result.xpath '//D:response/D:propstat/D:prop/D:displayname', ns
      nl.map { |node| node.content.strip }.should =~ (dirlist + [ 'dav' ])
    end  

    context 'with person/no admin' do
      let! (:user) { 
        Factory Users::User, position_group: :person, admin_group: :none 
      }

      it 'returns correct dirs' do
        webdav_auth user

        check_dirs [
          Config::I18n::WEBDAV_BASEPATHS['ResourceHome'],
          Config::I18n::WEBDAV_BASEPATHS['ResourceShareProgdata'],
          Config::I18n::WEBDAV_BASEPATHS['ResourceGroups'],
        ]
      end
    end

    context 'with teacher/superadmin' do
      let! (:user) { 
        Factory Users::User, position_group: :teacher, admin_group: :super
      }

      it 'returns correct dirs' do
        webdav_auth user
        check_dirs Config::I18n::WEBDAV_BASEPATHS.values
      end
    end
  end

end

