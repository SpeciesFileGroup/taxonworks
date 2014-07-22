require "rails_helper"

describe CitationTopicsController do
  describe "routing" do

    it "routes to #index" do
      get("/citation_topics").should route_to("citation_topics#index")
    end

    it "routes to #new" do
      get("/citation_topics/new").should route_to("citation_topics#new")
    end

    it "routes to #show" do
      get("/citation_topics/1").should route_to("citation_topics#show", :id => "1")
    end

    it "routes to #edit" do
      get("/citation_topics/1/edit").should route_to("citation_topics#edit", :id => "1")
    end

    it "routes to #create" do
      post("/citation_topics").should route_to("citation_topics#create")
    end

    it "routes to #update" do
      put("/citation_topics/1").should route_to("citation_topics#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/citation_topics/1").should route_to("citation_topics#destroy", :id => "1")
    end

  end
end
