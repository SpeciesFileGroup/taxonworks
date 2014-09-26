require "rails_helper"

describe TaggedSectionKeywordsController, :type => :routing do
  describe "routing" do

    it "routes to #create" do
      expect(post("/tagged_section_keywords")).to route_to("tagged_section_keywords#create")
    end

    it "routes to #update" do
      expect(put("/tagged_section_keywords/1")).to route_to("tagged_section_keywords#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/tagged_section_keywords/1")).to route_to("tagged_section_keywords#destroy", :id => "1")
    end

  end
end
