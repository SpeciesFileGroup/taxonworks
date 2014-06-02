require "spec_helper"

describe TaxonDeterminationsController do
  describe "routing" do

    it "routes to #index" do
      get("/taxon_determinations").should route_to("taxon_determinations#index")
    end

    it "routes to #new" do
      get("/taxon_determinations/new").should route_to("taxon_determinations#new")
    end

    it "routes to #show" do
      get("/taxon_determinations/1").should route_to("taxon_determinations#show", :id => "1")
    end

    it "routes to #edit" do
      get("/taxon_determinations/1/edit").should route_to("taxon_determinations#edit", :id => "1")
    end

    it "routes to #create" do
      post("/taxon_determinations").should route_to("taxon_determinations#create")
    end

    it "routes to #update" do
      put("/taxon_determinations/1").should route_to("taxon_determinations#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/taxon_determinations/1").should route_to("taxon_determinations#destroy", :id => "1")
    end

  end
end
