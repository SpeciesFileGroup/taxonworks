require "rails_helper"

describe TaxonNameRelationshipsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/taxon_name_relationships")).to route_to("taxon_name_relationships#index")
    end

    it "routes to #new" do
      expect(get("/taxon_name_relationships/new")).to route_to("taxon_name_relationships#new")
    end

    it "routes to #show" do
      expect(get("/taxon_name_relationships/1")).to route_to("taxon_name_relationships#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/taxon_name_relationships/1/edit")).to route_to("taxon_name_relationships#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/taxon_name_relationships")).to route_to("taxon_name_relationships#create")
    end

    it "routes to #update" do
      expect(put("/taxon_name_relationships/1")).to route_to("taxon_name_relationships#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/taxon_name_relationships/1")).to route_to("taxon_name_relationships#destroy", :id => "1")
    end

  end
end
