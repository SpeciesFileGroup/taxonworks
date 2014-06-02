require "spec_helper"

describe IdentifiersController do
  describe "routing" do

    it "routes to #index" do
      get("/identifiers").should route_to("identifiers#index")
    end

    it "routes to #new" do
      get("/identifiers/new").should route_to("identifiers#new")
    end

    it "routes to #show" do
      get("/identifiers/1").should route_to("identifiers#show", :id => "1")
    end

    it "routes to #edit" do
      get("/identifiers/1/edit").should route_to("identifiers#edit", :id => "1")
    end

    it "routes to #create" do
      post("/identifiers").should route_to("identifiers#create")
    end

    it "routes to #update" do
      put("/identifiers/1").should route_to("identifiers#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/identifiers/1").should route_to("identifiers#destroy", :id => "1")
    end

  end
end
