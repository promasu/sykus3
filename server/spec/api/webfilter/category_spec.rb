require 'spec_helper'

require 'services/webfilter/find_category'
require 'services/webfilter/update_category'

require 'api/main'

module Sykus

  describe 'Webfilter::Category API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityTestGod.new } 

    let (:find_category) { Webfilter::FindCategory.new identity }
    let (:update_category) { Webfilter::UpdateCategory.new identity }
    let (:cat_id) { Factory.create(Webfilter::Category, selected: :none).id }

    context 'GET /webfilter/categories/' do
      it 'returns empty array' do
        get '/webfilter/categories/'

        last_response.should be_ok
        last_response.body.should == [].to_json
      end

      it 'returns returns two categories' do
        2.times { Factory Webfilter::Category }
        get '/webfilter/categories/'

        last_response.should be_ok
        last_response.body.should == find_category.all.to_json
      end
    end

    context 'GET /webfilter/categories/diff/:timestamp' do
      it 'returns nothing with current time' do
        get '/webfilter/categories/diff/' + Time.now.to_f.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == []
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end

      it 'returns category in diff resultset' do
        ts = Time.now.to_f
        id = cat_id
        update_category.run id, { selected: 'students' }
        get '/webfilter/categories/diff/' + ts.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == [ find_category.by_id(id) ]
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end
    end

    context 'GET /webfilter/categories/:id' do
      it 'returns category' do
        get '/webfilter/categories/' + cat_id.to_s

        last_response.should be_ok
        json_response.should == find_category.by_id(cat_id)
      end

      it 'fails on invalid id' do
        get '/webfilter/categories/42000'

        last_response.status.should == 404
      end
    end

    context 'PUT /webfilter/categories/:id' do
      it 'updates a category' do
        data = {
          selected: 'all'
        }.to_json
        put '/webfilter/categories/' + cat_id.to_s, data

        last_response.status.should == 204
        category = find_category.by_id cat_id
        category[:selected].should == 'all'
      end

      it 'fails on invalid id' do
        put '/webfilter/categories/4200', {}.to_json

        last_response.status.should == 404
      end
    end
  end

end

