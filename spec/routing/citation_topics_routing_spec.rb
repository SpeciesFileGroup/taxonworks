require "rails_helper"

describe CitationTopicsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/citation_topics")).to route_to("citation_topics#index")
    end

    it "routes to #new" do
      expect(get("/citation_topics/new")).to route_to("citation_topics#new")
    end

    it "routes to #show" do
      expect(get("/citation_topics/1")).to route_to("citation_topics#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/citation_topics/1/edit")).to route_to("citation_topics#edit", :id => "1")
    end

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
