require "spec_helper"

describe ContentsController do
  describe "routing" do

    it "routes to #index" do
      get("/contents").should route_to("contents#index")
    end

    it "routes to #new" do
      get("/contents/new").should route_to("contents#new")
    end

    it "routes to #show" do
      get("/contents/1").should route_to("contents#show", :id => "1")
    end

    it "routes to #edit" do
      get("/contents/1/edit").should route_to("contents#edit", :id => "1")
    end

    it "routes to #create" do
      post("/contents").should route_to("contents#create")
    end

    it "routes to #update" do
      put("/contents/1").should route_to("contents#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/contents/1").should route_to("contents#destroy", :id => "1")
    end

  end
end
