require 'rails_helper'

describe Api::V1::BaseController, type: :request do

  context :index do
    before { get '/api/v1/' }
    it_behaves_like 'a successful response'
  end
end
