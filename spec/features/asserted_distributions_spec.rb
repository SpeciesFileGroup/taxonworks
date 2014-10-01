require 'rails_helper'

RSpec.describe "AssertedDistributions", :type => :request do
  describe "GET /asserted_distributions" do
    it "works! (now write some real specs)" do
      get asserted_distributions_path
      expect(response).to have_http_status(200)
    end
  end
end
