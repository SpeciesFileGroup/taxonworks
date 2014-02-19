require "spec_helper"

describe TaxonNameRelationshipsController do
  describe "routing" do

    it "routes to #index" do
      get("/taxon_name_relationships").should route_to("taxon_name_relationships#index")
    end

    it "routes to #new" do
      get("/taxon_name_relationships/new").should route_to("taxon_name_relationships#new")
    end

    it "routes to #show" do
      get("/taxon_name_relationships/1").should route_to("taxon_name_relationships#show", :id => "1")
    end

    it "routes to #edit" do
      get("/taxon_name_relationships/1/edit").should route_to("taxon_name_relationships#edit", :id => "1")
    end

    it "routes to #create" do
      post("/taxon_name_relationships").should route_to("taxon_name_relationships#create")
    end

    it "routes to #update" do
      put("/taxon_name_relationships/1").should route_to("taxon_name_relationships#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/taxon_name_relationships/1").should route_to("taxon_name_relationships#destroy", :id => "1")
    end

  end
end
