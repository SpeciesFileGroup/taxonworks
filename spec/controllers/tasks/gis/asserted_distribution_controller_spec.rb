require 'rails_helper'

describe Tasks::Gis::AssertedDistributionController, :type => :controller do
  before(:each) {
    sign_in
  }

  let(:valid_otu) { FactoryGirl.create(:valid_otu) }
  let(:valid_source) { FactoryGirl.create(:valid_source) }

  describe "GET new" do
    it "returns http success" do
      get 'new', asserted_distribution: {otu_id: valid_otu.id, source_id: valid_source.id}
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET create" do
    it "returns http success" do
      get 'create'
      expect(response).to have_http_status(:success)
    end
  end

end
