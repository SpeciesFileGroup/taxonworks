require 'rails_helper'

describe Tasks::Gis::OtuDistributionDataController, type: :controller do
  before(:each) {
    sign_in
  }
  let(:otu) { FactoryGirl.create(:valid_otu) }

  describe "GET #show" do
    it "returns http success" do
      get :show, params: {:id => otu.to_param}
      # get 'tasks/gis/otu_distribution_data'
      # pending 'construction of proper otu in this context'
      expect(response).to have_http_status(:success)
    end
  end

end
