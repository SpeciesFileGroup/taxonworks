require "rails_helper"

describe OtuPageLayoutSectionsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/otu_page_layout_sections")).to route_to("otu_page_layout_sections#index")
    end

    it "routes to #new" do
      expect(get("/otu_page_layout_sections/new")).to route_to("otu_page_layout_sections#new")
    end

    it "routes to #show" do
      expect(get("/otu_page_layout_sections/1")).to route_to("otu_page_layout_sections#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/otu_page_layout_sections/1/edit")).to route_to("otu_page_layout_sections#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/otu_page_layout_sections")).to route_to("otu_page_layout_sections#create")
    end

    it "routes to #update" do
      expect(put("/otu_page_layout_sections/1")).to route_to("otu_page_layout_sections#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/otu_page_layout_sections/1")).to route_to("otu_page_layout_sections#destroy", :id => "1")
    end

  end
end
