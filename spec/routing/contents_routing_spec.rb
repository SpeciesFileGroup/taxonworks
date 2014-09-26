require "rails_helper"

describe ContentsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/contents")).to route_to("contents#index")
    end

    it "routes to #list" do
      expect(get("/contents/list")).to route_to("contents#list")
    end

    it "routes to #new" do
      expect(get("/contents/new")).to route_to("contents#new")
    end

    it "routes to #show" do
      expect(get("/contents/1")).to route_to("contents#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/contents/1/edit")).to route_to("contents#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/contents")).to route_to("contents#create")
    end

    it "routes to #update" do
      expect(put("/contents/1")).to route_to("contents#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/contents/1")).to route_to("contents#destroy", :id => "1")
    end

  end
end
