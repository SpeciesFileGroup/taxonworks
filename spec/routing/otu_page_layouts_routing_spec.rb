require "rails_helper"

describe OtuPageLayoutsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/otu_page_layouts")).to route_to("otu_page_layouts#index")
    end

    it "routes to #new" do
      expect(get("/otu_page_layouts/new")).to route_to("otu_page_layouts#new")
    end

    it "routes to #show" do
      expect(get("/otu_page_layouts/1")).to route_to("otu_page_layouts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/otu_page_layouts/1/edit")).to route_to("otu_page_layouts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/otu_page_layouts")).to route_to("otu_page_layouts#create")
    end

    it "routes to #update" do
      expect(put("/otu_page_layouts/1")).to route_to("otu_page_layouts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/otu_page_layouts/1")).to route_to("otu_page_layouts#destroy", :id => "1")
    end

  end
end
