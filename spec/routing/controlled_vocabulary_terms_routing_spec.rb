require "spec_helper"

describe ControlledVocabularyTermsController do
  describe "routing" do

    it "routes to #index" do
      get("/controlled_vocabulary_terms").should route_to("controlled_vocabulary_terms#index")
    end

    it "routes to #new" do
      get("/controlled_vocabulary_terms/new").should route_to("controlled_vocabulary_terms#new")
    end

    it "routes to #show" do
      get("/controlled_vocabulary_terms/1").should route_to("controlled_vocabulary_terms#show", :id => "1")
    end

    it "routes to #edit" do
      get("/controlled_vocabulary_terms/1/edit").should route_to("controlled_vocabulary_terms#edit", :id => "1")
    end

    it "routes to #create" do
      post("/controlled_vocabulary_terms").should route_to("controlled_vocabulary_terms#create")
    end

    it "routes to #update" do
      put("/controlled_vocabulary_terms/1").should route_to("controlled_vocabulary_terms#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/controlled_vocabulary_terms/1").should route_to("controlled_vocabulary_terms#destroy", :id => "1")
    end

  end
end
