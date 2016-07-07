require 'rails_helper'

describe Tasks::LoansController, type: :controller do

  before(:each) {
    sign_in
  }

  describe 'GET #complete' do
    it 'returns http success' do
      get :complete
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #add_determination' do
    it 'returns http success' do
      get :add_determination
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #return_items' do
    it 'returns http success' do
      get :return_items
      expect(response).to have_http_status(:success)
    end
  end
end
