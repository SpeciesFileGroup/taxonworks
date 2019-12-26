require 'rails_helper'

describe 'ActionController::InvalidAuthenticityToken handling', type: :request do
  before do
    ActionController::Base.allow_forgery_protection = true
  end

  after do
    ActionController::Base.allow_forgery_protection = false
  end

  context 'when token is missing/invalid' do
    context 'and requesting JSON format' do
      before { post '/users.json' }
      
      it 'returns status 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'indicates unsuccessful response in body' do
        expect(JSON.parse(response.body)).to eq({ "success" => false })
      end
    end

    context 'and requesting default format' do
      before { post '/users' }
      
      it 'redirects to index' do
        expect(response).to redirect_to('/')
      end

      it 'indicates problem in flash' do
        expect(flash[:notice]).to match(/Your last request could not be fulfilled..*/)
      end
    end

  end
end
