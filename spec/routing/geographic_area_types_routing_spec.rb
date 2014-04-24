require "spec_helper"

describe GeographicAreaTypesController do
  describe "routing" do

    it "routes to #index" do
      get("/geographic_area_types").should route_to("geographic_area_types#index")
    end

    it "routes to #new" do
      get("/geographic_area_types/new").should route_to("geographic_area_types#new")
    end

    it "routes to #show" do
      get("/geographic_area_types/1").should route_to("geographic_area_types#show", :id => "1")
    end

    it "routes to #edit" do
      get("/geographic_area_types/1/edit").should route_to("geographic_area_types#edit", :id => "1")
    end

    it "routes to #create" do
      post("/geographic_area_types").should route_to("geographic_area_types#create")
    end

    it "routes to #update" do
      put("/geographic_area_types/1").should route_to("geographic_area_types#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/geographic_area_types/1").should route_to("geographic_area_types#destroy", :id => "1")
    end

  end
end
