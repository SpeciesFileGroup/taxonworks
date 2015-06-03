require "rails_helper"

RSpec.describe CollectionObjectObservationsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/collection_object_observations").to route_to("collection_object_observations#index")
    end

    it "routes to #new" do
      expect(:get => "/collection_object_observations/new").to route_to("collection_object_observations#new")
    end

    it "routes to #show" do
      expect(:get => "/collection_object_observations/1").to route_to("collection_object_observations#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/collection_object_observations/1/edit").to route_to("collection_object_observations#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/collection_object_observations").to route_to("collection_object_observations#create")
    end

    it "routes to #update" do
      expect(:put => "/collection_object_observations/1").to route_to("collection_object_observations#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/collection_object_observations/1").to route_to("collection_object_observations#destroy", :id => "1")
    end

  end
end
