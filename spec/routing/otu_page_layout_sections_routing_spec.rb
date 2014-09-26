require "rails_helper"

describe OtuPageLayoutSectionsController, :type => :routing do
  describe "routing" do

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
