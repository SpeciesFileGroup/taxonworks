require "rails_helper"

RSpec.describe PinboardItemsController, :type => :routing do
  describe "routing" do

    it "routes to #create" do
      expect(:post => "/pinboard_items").to route_to("pinboard_items#create")
    end

    it "routes to #destroy" do
      expect(:delete => "/pinboard_items/1").to route_to("pinboard_items#destroy", :id => "1")
    end

  end
end
