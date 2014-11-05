require "rails_helper"

describe CitationTopicsController, :type => :routing do
  describe "routing" do

    it "routes to #create" do
      expect(post("/citation_topics")).to route_to("citation_topics#create")
    end

    it "routes to #update" do
      expect(put("/citation_topics/1")).to route_to("citation_topics#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/citation_topics/1")).to route_to("citation_topics#destroy", :id => "1")
    end

  end
end
