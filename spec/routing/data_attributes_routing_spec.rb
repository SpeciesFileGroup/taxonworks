require "spec_helper"

describe DataAttributesController do
  describe "routing" do

    it "routes to #index" do
      get("/data_attributes").should route_to("data_attributes#index")
    end

    it "routes to #new" do
      get("/data_attributes/new").should route_to("data_attributes#new")
    end

    it "routes to #show" do
      get("/data_attributes/1").should route_to("data_attributes#show", :id => "1")
    end

    it "routes to #edit" do
      get("/data_attributes/1/edit").should route_to("data_attributes#edit", :id => "1")
    end

    it "routes to #create" do
      post("/data_attributes").should route_to("data_attributes#create")
    end

    it "routes to #update" do
      put("/data_attributes/1").should route_to("data_attributes#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/data_attributes/1").should route_to("data_attributes#destroy", :id => "1")
    end

  end
end
