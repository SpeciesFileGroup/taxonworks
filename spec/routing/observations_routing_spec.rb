require "rails_helper"

RSpec.describe ObservationsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/observations").to route_to("observations#index")
    end

    it "routes to #new" do
      expect(:get => "/observations/new").to route_to("observations#new")
    end

    it "routes to #show" do
      expect(:get => "/observations/1").to route_to("observations#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/observations/1/edit").to route_to("observations#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/observations").to route_to("observations#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/observations/1").to route_to("observations#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/observations/1").to route_to("observations#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/observations/1").to route_to("observations#destroy", :id => "1")
    end

  end
end
