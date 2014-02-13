require "spec_helper"

describe CollectionObjectsController do
  describe "routing" do

    it "routes to #index" do
      get("/collection_objects").should route_to("collection_objects#index")
    end

    it "routes to #new" do
      get("/collection_objects/new").should route_to("collection_objects#new")
    end

    it "routes to #show" do
      get("/collection_objects/1").should route_to("collection_objects#show", :id => "1")
    end

    it "routes to #edit" do
      get("/collection_objects/1/edit").should route_to("collection_objects#edit", :id => "1")
    end

    it "routes to #create" do
      post("/collection_objects").should route_to("collection_objects#create")
    end

    it "routes to #update" do
      put("/collection_objects/1").should route_to("collection_objects#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/collection_objects/1").should route_to("collection_objects#destroy", :id => "1")
    end

  end
end
