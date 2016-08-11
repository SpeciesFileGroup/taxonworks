require "rails_helper"

RSpec.describe SequencesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/sequences").to route_to("sequences#index")
    end

    it "routes to #new" do
      expect(:get => "/sequences/new").to route_to("sequences#new")
    end

    it "routes to #show" do
      expect(:get => "/sequences/1").to route_to("sequences#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/sequences/1/edit").to route_to("sequences#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/sequences").to route_to("sequences#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/sequences/1").to route_to("sequences#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/sequences/1").to route_to("sequences#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/sequences/1").to route_to("sequences#destroy", :id => "1")
    end

  end
end
