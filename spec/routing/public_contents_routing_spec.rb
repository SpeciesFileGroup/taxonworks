require "rails_helper"

describe PublicContentsController, :type => :routing do
  describe "routing" do

    it "routes to #create" do
      expect(post("/public_contents")).to route_to("public_contents#create")
    end

    it "routes to #update" do
      expect(put("/public_contents/1")).to route_to("public_contents#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/public_contents/1")).to route_to("public_contents#destroy", :id => "1")
    end

  end
end
