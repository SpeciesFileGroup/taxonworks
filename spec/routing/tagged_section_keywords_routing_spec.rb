require "rails_helper"

describe TaggedSectionKeywordsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/tagged_section_keywords")).to route_to("tagged_section_keywords#index")
    end

    it "routes to #new" do
      expect(get("/tagged_section_keywords/new")).to route_to("tagged_section_keywords#new")
    end

    it "routes to #show" do
      expect(get("/tagged_section_keywords/1")).to route_to("tagged_section_keywords#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/tagged_section_keywords/1/edit")).to route_to("tagged_section_keywords#edit", :id => "1")
    end

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
