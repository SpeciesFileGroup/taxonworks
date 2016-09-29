require 'rails_helper'

RSpec.describe Tasks::People::AuthorController, type: :controller do
  before(:each) {
    sign_in
  }

  describe 'GET #list' do
    it 'returns http success' do
      get :list
      expect(response).to have_http_status(:success)
    end
  end

end
