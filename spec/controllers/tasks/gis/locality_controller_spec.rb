require 'rails_helper'

RSpec.describe Tasks::Gis::LocalityController, :type => :controller do

  describe "GET nearby" do
    it "returns http success" do
      pending 'proper specification of the route'
      get :nearby
      expect(response).to have_http_status(:success)
    end
  end

end
