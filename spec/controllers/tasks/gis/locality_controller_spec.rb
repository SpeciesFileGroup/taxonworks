require 'rails_helper'

describe Tasks::Gis::LocalityController, :type => :controller do
  before(:each) {
    sign_in
    generate_ce_test_objects
  }
  after(:each) {
    clean_slate_geo
  }
  describe "GET nearby" do
    it "returns http success" do
      # pending 'proper specification of the route'
      get :nearby, {:id => @ce_p1.to_param}
      expect(response).to have_http_status(:success)
    end
  end

end
