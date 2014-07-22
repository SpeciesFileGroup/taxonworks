require "rails_helper"

describe TaxonNameClassificationsController do
  describe "routing" do

    it "routes to #index" do
      get("/taxon_name_classifications").should route_to("taxon_name_classifications#index")
    end

    it "routes to #new" do
      get("/taxon_name_classifications/new").should route_to("taxon_name_classifications#new")
    end

    it "routes to #show" do
      get("/taxon_name_classifications/1").should route_to("taxon_name_classifications#show", :id => "1")
    end

    it "routes to #edit" do
      get("/taxon_name_classifications/1/edit").should route_to("taxon_name_classifications#edit", :id => "1")
    end

    it "routes to #create" do
      post("/taxon_name_classifications").should route_to("taxon_name_classifications#create")
    end

    it "routes to #update" do
      put("/taxon_name_classifications/1").should route_to("taxon_name_classifications#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/taxon_name_classifications/1").should route_to("taxon_name_classifications#destroy", :id => "1")
    end

  end
end
