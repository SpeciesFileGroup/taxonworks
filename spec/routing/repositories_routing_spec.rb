require "spec_helper"

describe RepositoriesController do
  describe "routing" do

    it "routes to #index" do
      get("/repositories").should route_to("repositories#index")
    end

    it "routes to #new" do
      get("/repositories/new").should route_to("repositories#new")
    end

    it "routes to #show" do
      get("/repositories/1").should route_to("repositories#show", :id => "1")
    end

    it "routes to #edit" do
      get("/repositories/1/edit").should route_to("repositories#edit", :id => "1")
    end

    it "routes to #create" do
      post("/repositories").should route_to("repositories#create")
    end

    it "routes to #update" do
      put("/repositories/1").should route_to("repositories#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/repositories/1").should route_to("repositories#destroy", :id => "1")
    end

  end
end
