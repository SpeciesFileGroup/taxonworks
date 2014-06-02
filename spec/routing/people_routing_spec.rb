require "spec_helper"

describe PeopleController do
  describe "routing" do

    it "routes to #index" do
      get("/people").should route_to("people#index")
    end

    it "routes to #new" do
      get("/people/new").should route_to("people#new")
    end

    it "routes to #show" do
      get("/people/1").should route_to("people#show", :id => "1")
    end

    it "routes to #edit" do
      get("/people/1/edit").should route_to("people#edit", :id => "1")
    end

    it "routes to #create" do
      post("/people").should route_to("people#create")
    end

    it "routes to #update" do
      put("/people/1").should route_to("people#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/people/1").should route_to("people#destroy", :id => "1")
    end

  end
end
