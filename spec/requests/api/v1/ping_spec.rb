require 'rails_helper'

describe Api::V1::PingController, type: :request do

  context :ping do
    before { get '/api/v1/ping' } 

    it_behaves_like 'a successful response'

    specify 'responds' do
      expect(JSON.parse(body).dig('pong')).to eq(true)
    end
  end

end
