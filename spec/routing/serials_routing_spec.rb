require "rails_helper"

describe SerialsController do
  describe "routing" do

    it "routes to #index" do
      get("/serials").should route_to("serials#index")
    end

    it "routes to #new" do
      get("/serials/new").should route_to("serials#new")
    end

    it "routes to #show" do
      get("/serials/1").should route_to("serials#show", :id => "1")
    end

    it "routes to #edit" do
      get("/serials/1/edit").should route_to("serials#edit", :id => "1")
    end

    it "routes to #create" do
      post("/serials").should route_to("serials#create")
    end

    it "routes to #update" do
      put("/serials/1").should route_to("serials#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/serials/1").should route_to("serials#destroy", :id => "1")
    end

  end
end
