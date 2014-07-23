require "rails_helper"

describe CitationsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/citations")).to route_to("citations#index")
    end

    it "routes to #new" do
      expect(get("/citations/new")).to route_to("citations#new")
    end

    it "routes to #show" do
      expect(get("/citations/1")).to route_to("citations#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/citations/1/edit")).to route_to("citations#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/citations")).to route_to("citations#create")
    end

    it "routes to #update" do
      expect(put("/citations/1")).to route_to("citations#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/citations/1")).to route_to("citations#destroy", :id => "1")
    end

  end
end
