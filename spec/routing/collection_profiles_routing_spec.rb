require "spec_helper"

describe CollectionProfilesController do
  describe "routing" do

    it "routes to #index" do
      get("/collection_profiles").should route_to("collection_profiles#index")
    end

    it "routes to #new" do
      get("/collection_profiles/new").should route_to("collection_profiles#new")
    end

    it "routes to #show" do
      get("/collection_profiles/1").should route_to("collection_profiles#show", :id => "1")
    end

    it "routes to #edit" do
      get("/collection_profiles/1/edit").should route_to("collection_profiles#edit", :id => "1")
    end

    it "routes to #create" do
      post("/collection_profiles").should route_to("collection_profiles#create")
    end

    it "routes to #update" do
      put("/collection_profiles/1").should route_to("collection_profiles#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/collection_profiles/1").should route_to("collection_profiles#destroy", :id => "1")
    end

  end
end
