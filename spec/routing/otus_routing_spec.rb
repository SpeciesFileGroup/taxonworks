require "rails_helper"

describe OtusController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/otus")).to route_to("otus#index")
    end

    it "routes to #list" do
      expect(get("/otus/list")).to route_to("otus#list")
    end

    it "routes to #new" do
      expect(get("/otus/new")).to route_to("otus#new")
    end

    it "routes to #show" do
      expect(get("/otus/1")).to route_to("otus#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/otus/1/edit")).to route_to("otus#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/otus")).to route_to("otus#create")
    end

    it "routes to #update" do
      expect(put("/otus/1")).to route_to("otus#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/otus/1")).to route_to("otus#destroy", :id => "1")
    end

  end
end
