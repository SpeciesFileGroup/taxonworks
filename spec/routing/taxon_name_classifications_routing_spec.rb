require "rails_helper"

describe TaxonNameClassificationsController, :type => :routing do
  describe "routing" do

    it "routes to #create" do
      expect(post("/taxon_name_classifications")).to route_to("taxon_name_classifications#create")
    end

    it "routes to #update" do
      expect(put("/taxon_name_classifications/1")).to route_to("taxon_name_classifications#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/taxon_name_classifications/1")).to route_to("taxon_name_classifications#destroy", :id => "1")
    end

  end
end
