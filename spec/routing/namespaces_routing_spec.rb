require "spec_helper"

describe NamespacesController do
  describe "routing" do

    it "routes to #index" do
      get("/namespaces").should route_to("namespaces#index")
    end

    it "routes to #new" do
      get("/namespaces/new").should route_to("namespaces#new")
    end

    it "routes to #show" do
      get("/namespaces/1").should route_to("namespaces#show", :id => "1")
    end

    it "routes to #edit" do
      get("/namespaces/1/edit").should route_to("namespaces#edit", :id => "1")
    end

    it "routes to #create" do
      post("/namespaces").should route_to("namespaces#create")
    end

    it "routes to #update" do
      put("/namespaces/1").should route_to("namespaces#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/namespaces/1").should route_to("namespaces#destroy", :id => "1")
    end

  end
end
