require "rails_helper"

describe SourcesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/sources")).to route_to("sources#index")
    end

    it "routes to #new" do
      expect(get("/sources/new")).to route_to("sources#new")
    end

    it "routes to #show" do
      expect(get("/sources/1")).to route_to("sources#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/sources/1/edit")).to route_to("sources#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/sources")).to route_to("sources#create")
    end

    it "routes to #update" do
      expect(put("/sources/1")).to route_to("sources#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/sources/1")).to route_to("sources#destroy", :id => "1")
    end

  end
end
