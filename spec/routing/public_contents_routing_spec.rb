require "rails_helper"

describe PublicContentsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/public_contents")).to route_to("public_contents#index")
    end

    it "routes to #new" do
      expect(get("/public_contents/new")).to route_to("public_contents#new")
    end

    it "routes to #show" do
      expect(get("/public_contents/1")).to route_to("public_contents#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/public_contents/1/edit")).to route_to("public_contents#edit", :id => "1")
    end

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
