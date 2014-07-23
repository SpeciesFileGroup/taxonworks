require "rails_helper"

describe ControlledVocabularyTermsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/controlled_vocabulary_terms")).to route_to("controlled_vocabulary_terms#index")
    end

    it "routes to #new" do
      expect(get("/controlled_vocabulary_terms/new")).to route_to("controlled_vocabulary_terms#new")
    end

    it "routes to #show" do
      expect(get("/controlled_vocabulary_terms/1")).to route_to("controlled_vocabulary_terms#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/controlled_vocabulary_terms/1/edit")).to route_to("controlled_vocabulary_terms#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/controlled_vocabulary_terms")).to route_to("controlled_vocabulary_terms#create")
    end

    it "routes to #update" do
      expect(put("/controlled_vocabulary_terms/1")).to route_to("controlled_vocabulary_terms#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/controlled_vocabulary_terms/1")).to route_to("controlled_vocabulary_terms#destroy", :id => "1")
    end

  end
end
