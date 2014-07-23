require "rails_helper"

describe NamespacesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/namespaces")).to route_to("namespaces#index")
    end

    it "routes to #new" do
      expect(get("/namespaces/new")).to route_to("namespaces#new")
    end

    it "routes to #show" do
      expect(get("/namespaces/1")).to route_to("namespaces#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/namespaces/1/edit")).to route_to("namespaces#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/namespaces")).to route_to("namespaces#create")
    end

    it "routes to #update" do
      expect(put("/namespaces/1")).to route_to("namespaces#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/namespaces/1")).to route_to("namespaces#destroy", :id => "1")
    end

  end
end
