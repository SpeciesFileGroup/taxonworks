require "rails_helper"

describe OtuPageLayoutsController do
  describe "routing" do

    it "routes to #index" do
      get("/otu_page_layouts").should route_to("otu_page_layouts#index")
    end

    it "routes to #new" do
      get("/otu_page_layouts/new").should route_to("otu_page_layouts#new")
    end

    it "routes to #show" do
      get("/otu_page_layouts/1").should route_to("otu_page_layouts#show", :id => "1")
    end

    it "routes to #edit" do
      get("/otu_page_layouts/1/edit").should route_to("otu_page_layouts#edit", :id => "1")
    end

    it "routes to #create" do
      post("/otu_page_layouts").should route_to("otu_page_layouts#create")
    end

    it "routes to #update" do
      put("/otu_page_layouts/1").should route_to("otu_page_layouts#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/otu_page_layouts/1").should route_to("otu_page_layouts#destroy", :id => "1")
    end

  end
end
