require 'rails_helper'

describe Tasks::Serials::SimilarController, :type => :controller do

  describe "GET similar" do
    it "returns http success" do
      get :similar
      expect(response).to have_http_status(:success)
    end
  end

  # describe "GET update" do
  #   it "returns http success" do
  #     get :update
  #     expect(response).to have_http_status(:success)
  #   end
  # end
  #
  # describe "GET within" do
  #   it "returns http success" do
  #     get :within
  #     expect(response).to have_http_status(:success)
  #   end
  # end

end
