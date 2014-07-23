require "rails_helper"

describe CollectingEventsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/collecting_events")).to route_to("collecting_events#index")
    end

    it "routes to #new" do
      expect(get("/collecting_events/new")).to route_to("collecting_events#new")
    end

    it "routes to #show" do
      expect(get("/collecting_events/1")).to route_to("collecting_events#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/collecting_events/1/edit")).to route_to("collecting_events#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/collecting_events")).to route_to("collecting_events#create")
    end

    it "routes to #update" do
      expect(put("/collecting_events/1")).to route_to("collecting_events#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/collecting_events/1")).to route_to("collecting_events#destroy", :id => "1")
    end

  end
end
