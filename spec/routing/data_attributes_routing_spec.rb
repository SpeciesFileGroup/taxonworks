require "rails_helper"

describe DataAttributesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/data_attributes")).to route_to("data_attributes#index")
    end

    it "routes to #new" do
      expect(get("/data_attributes/new")).to route_to("data_attributes#new")
    end

    it "routes to #show" do
      expect(get("/data_attributes/1")).to route_to("data_attributes#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/data_attributes/1/edit")).to route_to("data_attributes#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/data_attributes")).to route_to("data_attributes#create")
    end

    it "routes to #update" do
      expect(put("/data_attributes/1")).to route_to("data_attributes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/data_attributes/1")).to route_to("data_attributes#destroy", :id => "1")
    end

  end
end
