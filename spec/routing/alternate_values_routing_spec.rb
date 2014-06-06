require "spec_helper"

describe AlternateValuesController do
  describe "routing" do

    it "routes to #index" do
      get("/alternate_values").should route_to("alternate_values#index")
    end

    it "routes to #new" do
      get("/alternate_values/new").should route_to("alternate_values#new")
    end

    it "routes to #show" do
      get("/alternate_values/1").should route_to("alternate_values#show", :id => "1")
    end

    it "routes to #edit" do
      get("/alternate_values/1/edit").should route_to("alternate_values#edit", :id => "1")
    end

    it "routes to #create" do
      post("/alternate_values").should route_to("alternate_values#create")
    end

    it "routes to #update" do
      put("/alternate_values/1").should route_to("alternate_values#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/alternate_values/1").should route_to("alternate_values#destroy", :id => "1")
    end

  end
end
