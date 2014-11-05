require "rails_helper"

describe CitationsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/citations")).to route_to("citations#index")
    end

    it "routes to #list" do
      expect(get("/citations/list")).to route_to("citations#list")
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
