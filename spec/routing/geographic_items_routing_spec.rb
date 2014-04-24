require "spec_helper"

describe GeographicItemsController do
  describe "routing" do

    it "routes to #index" do
      get("/geographic_items").should route_to("geographic_items#index")
    end

    it "routes to #new" do
      get("/geographic_items/new").should route_to("geographic_items#new")
    end

    it "routes to #show" do
      get("/geographic_items/1").should route_to("geographic_items#show", :id => "1")
    end

    it "routes to #edit" do
      get("/geographic_items/1/edit").should route_to("geographic_items#edit", :id => "1")
    end

    it "routes to #create" do
      post("/geographic_items").should route_to("geographic_items#create")
    end

    it "routes to #update" do
      put("/geographic_items/1").should route_to("geographic_items#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/geographic_items/1").should route_to("geographic_items#destroy", :id => "1")
    end

  end
end
