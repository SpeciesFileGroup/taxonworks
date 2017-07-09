require "rails_helper"

RSpec.describe SequenceRelationshipsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/sequence_relationships").to route_to("sequence_relationships#index")
    end

    it "routes to #new" do
      expect(:get => "/sequence_relationships/new").to route_to("sequence_relationships#new")
    end

    it "routes to #show" do
      expect(:get => "/sequence_relationships/1").to route_to("sequence_relationships#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/sequence_relationships/1/edit").to route_to("sequence_relationships#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/sequence_relationships").to route_to("sequence_relationships#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/sequence_relationships/1").to route_to("sequence_relationships#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/sequence_relationships/1").to route_to("sequence_relationships#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/sequence_relationships/1").to route_to("sequence_relationships#destroy", :id => "1")
    end

  end
end
