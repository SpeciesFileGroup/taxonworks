require "rails_helper"

RSpec.describe OtuRelationshipsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/otu_relationships").to route_to("otu_relationships#index")
    end

    it "routes to #new" do
      expect(get: "/otu_relationships/new").to route_to("otu_relationships#new")
    end

    it "routes to #show" do
      expect(get: "/otu_relationships/1").to route_to("otu_relationships#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/otu_relationships/1/edit").to route_to("otu_relationships#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/otu_relationships").to route_to("otu_relationships#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/otu_relationships/1").to route_to("otu_relationships#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/otu_relationships/1").to route_to("otu_relationships#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/otu_relationships/1").to route_to("otu_relationships#destroy", id: "1")
    end
  end
end
