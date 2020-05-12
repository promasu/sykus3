require 'spec_helper'

require 'services/webfilter/find_entry'
require 'services/webfilter/create_entry'

require 'api/main'

module Sykus

  describe 'Webfilter::Entry API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityTestGod.new } 

    let (:find_entry) { Webfilter::FindEntry.new identity }
    let (:create_entry) { Webfilter::CreateEntry.new identity }

    let (:examplecom) {{
      domain: 'example.com',
      comment: 'test',
      type: :black_all,
    }}

    let (:examplecom_id) { create_entry.run(examplecom)[:id] }

    context 'GET /webfilter/entries/' do
      it 'returns empty array' do
        get '/webfilter/entries/'

        last_response.should be_ok
        last_response.body.should == [].to_json
      end

      it 'returns returns two webfilter/entries' do
        2.times { Factory Webfilter::Entry }
        get '/webfilter/entries/'

        last_response.should be_ok
        last_response.body.should == find_entry.all.to_json
      end
    end

    context 'GET /webfilter/entries/diff/:timestamp' do
      it 'returns nothing with current time' do
        get '/webfilter/entries/diff/' + Time.now.to_f.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == []
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end

      it 'returns entry in diff resultset' do
        ts = Time.now.to_f
        id = examplecom_id
        get '/webfilter/entries/diff/' + ts.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == [ find_entry.by_id(id) ]
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end
    end

    context 'GET /webfilter/entries/:id' do
      it 'returns entry' do
        get '/webfilter/entries/' + examplecom_id.to_s

        last_response.should be_ok
        json_response.should == find_entry.by_id(examplecom_id)
      end

      it 'fails on invalid id' do
        get '/webfilter/entries/42000'

        last_response.status.should == 404
      end
    end

    context 'POST /webfilter/entries/' do
      it 'creates a new entry' do
        post '/webfilter/entries/', examplecom.to_json

        last_response.status.should == 201
        res = json_response
        res[:id].should be_a Integer
        find_entry.by_id res[:id]
      end

      it 'fails on invalid data' do
        post '/webfilter/entries/', {}.to_json

        last_response.status.should == 400
      end
    end

    context 'DELETE /webfilter/entries/:id' do
      it 'deletes a entry' do
        delete '/webfilter/entries/' + examplecom_id.to_s

        last_response.status.should == 204
      end

      it 'fails on invalid data' do
        delete '/webfilter/entries/4200'

        last_response.status.should == 404
      end
    end
  end

end

