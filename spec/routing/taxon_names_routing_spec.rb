require "rails_helper"

describe TaxonNamesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/taxon_names")).to route_to("taxon_names#index")
    end

    it "routes to #new" do
      expect(get("/taxon_names/new")).to route_to("taxon_names#new")
    end

    it "routes to #show" do
      expect(get("/taxon_names/1")).to route_to("taxon_names#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/taxon_names/1/edit")).to route_to("taxon_names#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/taxon_names")).to route_to("taxon_names#create")
    end

    it "routes to #update" do
      expect(put("/taxon_names/1")).to route_to("taxon_names#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/taxon_names/1")).to route_to("taxon_names#destroy", :id => "1")
    end

  end
end
