require "rails_helper"

describe TaxonNameClassificationsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/taxon_name_classifications")).to route_to("taxon_name_classifications#index")
    end

    it "routes to #new" do
      expect(get("/taxon_name_classifications/new")).to route_to("taxon_name_classifications#new")
    end

    it "routes to #show" do
      expect(get("/taxon_name_classifications/1")).to route_to("taxon_name_classifications#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/taxon_name_classifications/1/edit")).to route_to("taxon_name_classifications#edit", :id => "1")
    end

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
