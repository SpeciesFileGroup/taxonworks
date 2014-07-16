require "rails_helper"

describe CollectingEventsController do
  describe "routing" do

    it "routes to #index" do
      get("/collecting_events").should route_to("collecting_events#index")
    end

    it "routes to #new" do
      get("/collecting_events/new").should route_to("collecting_events#new")
    end

    it "routes to #show" do
      get("/collecting_events/1").should route_to("collecting_events#show", :id => "1")
    end

    it "routes to #edit" do
      get("/collecting_events/1/edit").should route_to("collecting_events#edit", :id => "1")
    end

    it "routes to #create" do
      post("/collecting_events").should route_to("collecting_events#create")
    end

    it "routes to #update" do
      put("/collecting_events/1").should route_to("collecting_events#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/collecting_events/1").should route_to("collecting_events#destroy", :id => "1")
    end

  end
end
