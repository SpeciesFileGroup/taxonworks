require 'rails_helper'

RSpec.describe "ContainerItems", :type => :request do
  describe "GET /container_items" do
    it "works! (now write some real specs)" do
      get container_items_path
      expect(response).to have_http_status(200)
    end
  end
end
