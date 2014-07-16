require "rails_helper"

describe SerialChronologiesController do
  describe "routing" do

    it "routes to #index" do
      get("/serial_chronologies").should route_to("serial_chronologies#index")
    end

    it "routes to #new" do
      get("/serial_chronologies/new").should route_to("serial_chronologies#new")
    end

    it "routes to #show" do
      get("/serial_chronologies/1").should route_to("serial_chronologies#show", :id => "1")
    end

    it "routes to #edit" do
      get("/serial_chronologies/1/edit").should route_to("serial_chronologies#edit", :id => "1")
    end

    it "routes to #create" do
      post("/serial_chronologies").should route_to("serial_chronologies#create")
    end

    it "routes to #update" do
      put("/serial_chronologies/1").should route_to("serial_chronologies#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/serial_chronologies/1").should route_to("serial_chronologies#destroy", :id => "1")
    end

  end
end
