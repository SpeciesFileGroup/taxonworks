require "rails_helper"

describe TaxonDeterminationsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/taxon_determinations")).to route_to("taxon_determinations#index")
    end

    it "routes to #new" do
      expect(get("/taxon_determinations/new")).to route_to("taxon_determinations#new")
    end

    it "routes to #show" do
      expect(get("/taxon_determinations/1")).to route_to("taxon_determinations#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/taxon_determinations/1/edit")).to route_to("taxon_determinations#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/taxon_determinations")).to route_to("taxon_determinations#create")
    end

    it "routes to #update" do
      expect(put("/taxon_determinations/1")).to route_to("taxon_determinations#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/taxon_determinations/1")).to route_to("taxon_determinations#destroy", :id => "1")
    end

  end
end
