require "spec_helper"

describe GeographicAreasController do
  describe "routing" do

    it "routes to #index" do
      get("/geographic_areas").should route_to("geographic_areas#index")
    end

    it "routes to #new" do
      get("/geographic_areas/new").should route_to("geographic_areas#new")
    end

    it "routes to #show" do
      get("/geographic_areas/1").should route_to("geographic_areas#show", :id => "1")
    end

    it "routes to #edit" do
      get("/geographic_areas/1/edit").should route_to("geographic_areas#edit", :id => "1")
    end

    it "routes to #create" do
      post("/geographic_areas").should route_to("geographic_areas#create")
    end

    it "routes to #update" do
      put("/geographic_areas/1").should route_to("geographic_areas#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/geographic_areas/1").should route_to("geographic_areas#destroy", :id => "1")
    end

  end
end
