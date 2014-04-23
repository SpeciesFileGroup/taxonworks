require "spec_helper"

describe GeoreferencesController do
  describe "routing" do

    it "routes to #index" do
      get("/georeferences").should route_to("georeferences#index")
    end

    it "routes to #new" do
      get("/georeferences/new").should route_to("georeferences#new")
    end

    it "routes to #show" do
      get("/georeferences/1").should route_to("georeferences#show", :id => "1")
    end

    it "routes to #edit" do
      get("/georeferences/1/edit").should route_to("georeferences#edit", :id => "1")
    end

    it "routes to #create" do
      post("/georeferences").should route_to("georeferences#create")
    end

    it "routes to #update" do
      put("/georeferences/1").should route_to("georeferences#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/georeferences/1").should route_to("georeferences#destroy", :id => "1")
    end

  end
end
