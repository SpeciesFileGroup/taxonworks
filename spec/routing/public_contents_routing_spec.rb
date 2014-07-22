require "rails_helper"

describe PublicContentsController do
  describe "routing" do

    it "routes to #index" do
      get("/public_contents").should route_to("public_contents#index")
    end

    it "routes to #new" do
      get("/public_contents/new").should route_to("public_contents#new")
    end

    it "routes to #show" do
      get("/public_contents/1").should route_to("public_contents#show", :id => "1")
    end

    it "routes to #edit" do
      get("/public_contents/1/edit").should route_to("public_contents#edit", :id => "1")
    end

    it "routes to #create" do
      post("/public_contents").should route_to("public_contents#create")
    end

    it "routes to #update" do
      put("/public_contents/1").should route_to("public_contents#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/public_contents/1").should route_to("public_contents#destroy", :id => "1")
    end

  end
end
