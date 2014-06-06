require "spec_helper"

describe OtuPageLayoutSectionsController do
  describe "routing" do

    it "routes to #index" do
      get("/otu_page_layout_sections").should route_to("otu_page_layout_sections#index")
    end

    it "routes to #new" do
      get("/otu_page_layout_sections/new").should route_to("otu_page_layout_sections#new")
    end

    it "routes to #show" do
      get("/otu_page_layout_sections/1").should route_to("otu_page_layout_sections#show", :id => "1")
    end

    it "routes to #edit" do
      get("/otu_page_layout_sections/1/edit").should route_to("otu_page_layout_sections#edit", :id => "1")
    end

    it "routes to #create" do
      post("/otu_page_layout_sections").should route_to("otu_page_layout_sections#create")
    end

    it "routes to #update" do
      put("/otu_page_layout_sections/1").should route_to("otu_page_layout_sections#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/otu_page_layout_sections/1").should route_to("otu_page_layout_sections#destroy", :id => "1")
    end

  end
end
