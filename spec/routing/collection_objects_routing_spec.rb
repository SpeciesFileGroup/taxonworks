require "rails_helper"

describe CollectionObjectsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/collection_objects")).to route_to("collection_objects#index")
    end

    it "routes to #list" do
      expect(get("/collection_objects/list")).to route_to("collection_objects#list")
    end

    it "routes to #new" do
      expect(get("/collection_objects/new")).to route_to("collection_objects#new")
    end

    it "routes to #show" do
      expect(get("/collection_objects/1")).to route_to("collection_objects#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/collection_objects/1/edit")).to route_to("collection_objects#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/collection_objects")).to route_to("collection_objects#create")
    end

    it "routes to #update" do
      expect(put("/collection_objects/1")).to route_to("collection_objects#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/collection_objects/1")).to route_to("collection_objects#destroy", :id => "1")
    end

  end
end
