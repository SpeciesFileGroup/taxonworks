require "rails_helper"

describe SerialsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/serials")).to route_to("serials#index")
    end

    it "routes to #new" do
      expect(get("/serials/new")).to route_to("serials#new")
    end

    it "routes to #show" do
      expect(get("/serials/1")).to route_to("serials#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/serials/1/edit")).to route_to("serials#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/serials")).to route_to("serials#create")
    end

    it "routes to #update" do
      expect(put("/serials/1")).to route_to("serials#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/serials/1")).to route_to("serials#destroy", :id => "1")
    end

  end
end
