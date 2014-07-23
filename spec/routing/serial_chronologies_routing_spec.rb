require "rails_helper"

describe SerialChronologiesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/serial_chronologies")).to route_to("serial_chronologies#index")
    end

    it "routes to #new" do
      expect(get("/serial_chronologies/new")).to route_to("serial_chronologies#new")
    end

    it "routes to #show" do
      expect(get("/serial_chronologies/1")).to route_to("serial_chronologies#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/serial_chronologies/1/edit")).to route_to("serial_chronologies#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/serial_chronologies")).to route_to("serial_chronologies#create")
    end

    it "routes to #update" do
      expect(put("/serial_chronologies/1")).to route_to("serial_chronologies#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/serial_chronologies/1")).to route_to("serial_chronologies#destroy", :id => "1")
    end

  end
end
