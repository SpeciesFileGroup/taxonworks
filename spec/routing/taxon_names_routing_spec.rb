require "spec_helper"

describe TaxonNamesController do
  describe "routing" do

    it "routes to #index" do
      get("/taxon_names").should route_to("taxon_names#index")
    end

    it "routes to #new" do
      get("/taxon_names/new").should route_to("taxon_names#new")
    end

    it "routes to #show" do
      get("/taxon_names/1").should route_to("taxon_names#show", :id => "1")
    end

    it "routes to #edit" do
      get("/taxon_names/1/edit").should route_to("taxon_names#edit", :id => "1")
    end

    it "routes to #create" do
      post("/taxon_names").should route_to("taxon_names#create")
    end

    it "routes to #update" do
      put("/taxon_names/1").should route_to("taxon_names#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/taxon_names/1").should route_to("taxon_names#destroy", :id => "1")
    end

  end
end
