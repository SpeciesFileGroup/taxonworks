require "spec_helper"

describe TaggedSectionKeywordsController do
  describe "routing" do

    it "routes to #index" do
      get("/tagged_section_keywords").should route_to("tagged_section_keywords#index")
    end

    it "routes to #new" do
      get("/tagged_section_keywords/new").should route_to("tagged_section_keywords#new")
    end

    it "routes to #show" do
      get("/tagged_section_keywords/1").should route_to("tagged_section_keywords#show", :id => "1")
    end

    it "routes to #edit" do
      get("/tagged_section_keywords/1/edit").should route_to("tagged_section_keywords#edit", :id => "1")
    end

    it "routes to #create" do
      post("/tagged_section_keywords").should route_to("tagged_section_keywords#create")
    end

    it "routes to #update" do
      put("/tagged_section_keywords/1").should route_to("tagged_section_keywords#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/tagged_section_keywords/1").should route_to("tagged_section_keywords#destroy", :id => "1")
    end

  end
end
