require "rails_helper"

describe CollectionProfilesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/collection_profiles")).to route_to("collection_profiles#index")
    end

    it "routes to #new" do
      expect(get("/collection_profiles/new")).to route_to("collection_profiles#new")
    end

    it "routes to #show" do
      expect(get("/collection_profiles/1")).to route_to("collection_profiles#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/collection_profiles/1/edit")).to route_to("collection_profiles#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/collection_profiles")).to route_to("collection_profiles#create")
    end

    it "routes to #update" do
      expect(put("/collection_profiles/1")).to route_to("collection_profiles#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/collection_profiles/1")).to route_to("collection_profiles#destroy", :id => "1")
    end

  end
end
