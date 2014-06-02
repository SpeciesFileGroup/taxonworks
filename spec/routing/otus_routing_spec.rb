require "spec_helper"

describe OtusController do
  describe "routing" do

    it "routes to #index" do
      get("/otus").should route_to("otus#index")
    end

    it "routes to #new" do
      get("/otus/new").should route_to("otus#new")
    end

    it "routes to #show" do
      get("/otus/1").should route_to("otus#show", :id => "1")
    end

    it "routes to #edit" do
      get("/otus/1/edit").should route_to("otus#edit", :id => "1")
    end

    it "routes to #create" do
      post("/otus").should route_to("otus#create")
    end

    it "routes to #update" do
      put("/otus/1").should route_to("otus#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/otus/1").should route_to("otus#destroy", :id => "1")
    end

  end
end
