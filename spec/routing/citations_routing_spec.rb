require "spec_helper"

describe CitationsController do
  describe "routing" do

    it "routes to #index" do
      get("/citations").should route_to("citations#index")
    end

    it "routes to #new" do
      get("/citations/new").should route_to("citations#new")
    end

    it "routes to #show" do
      get("/citations/1").should route_to("citations#show", :id => "1")
    end

    it "routes to #edit" do
      get("/citations/1/edit").should route_to("citations#edit", :id => "1")
    end

    it "routes to #create" do
      post("/citations").should route_to("citations#create")
    end

    it "routes to #update" do
      put("/citations/1").should route_to("citations#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/citations/1").should route_to("citations#destroy", :id => "1")
    end

  end
end
