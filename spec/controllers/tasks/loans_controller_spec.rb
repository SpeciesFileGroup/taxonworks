require 'rails_helper'

describe Tasks::LoansController, type: :controller do
  before(:each) {
    sign_in
  }
  let(:loan) { FactoryGirl.create(:valid_loan) }

  describe 'GET #complete' do
    it 'returns http success' do
      get :complete, {:id => loan.to_param}
      expect(response).to have_http_status(:success)
    end
  end

  #
  # TODO: These were changed to 'POST', need new tests
  #
  describe 'GET #add_determination' do
    xit 'returns http success' do
      get :add_determination
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #return_items' do
    xit 'returns http success' do
      get :return_items
      expect(response).to have_http_status(:success)
    end
  end
end
