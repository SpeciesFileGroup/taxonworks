require "rails_helper"

describe GeographicAreaTypesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/geographic_area_types")).to route_to("geographic_area_types#index")
    end

    it "routes to #new" do
      expect(get("/geographic_area_types/new")).to route_to("geographic_area_types#new")
    end

    it "routes to #show" do
      expect(get("/geographic_area_types/1")).to route_to("geographic_area_types#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/geographic_area_types/1/edit")).to route_to("geographic_area_types#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/geographic_area_types")).to route_to("geographic_area_types#create")
    end

    it "routes to #update" do
      expect(put("/geographic_area_types/1")).to route_to("geographic_area_types#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/geographic_area_types/1")).to route_to("geographic_area_types#destroy", :id => "1")
    end

  end
end
