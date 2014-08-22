require "rails_helper"

RSpec.describe PinboardItemsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/pinboard_items").to route_to("pinboard_items#index")
    end

    it "routes to #new" do
      expect(:get => "/pinboard_items/new").to route_to("pinboard_items#new")
    end

    it "routes to #show" do
      expect(:get => "/pinboard_items/1").to route_to("pinboard_items#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/pinboard_items/1/edit").to route_to("pinboard_items#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/pinboard_items").to route_to("pinboard_items#create")
    end

    it "routes to #update" do
      expect(:put => "/pinboard_items/1").to route_to("pinboard_items#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/pinboard_items/1").to route_to("pinboard_items#destroy", :id => "1")
    end

  end
end
