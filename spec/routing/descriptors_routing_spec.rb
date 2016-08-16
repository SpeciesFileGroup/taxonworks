require "rails_helper"

RSpec.describe DescriptorsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/descriptors").to route_to("descriptors#index")
    end

    it "routes to #new" do
      expect(:get => "/descriptors/new").to route_to("descriptors#new")
    end

    it "routes to #show" do
      expect(:get => "/descriptors/1").to route_to("descriptors#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/descriptors/1/edit").to route_to("descriptors#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/descriptors").to route_to("descriptors#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/descriptors/1").to route_to("descriptors#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/descriptors/1").to route_to("descriptors#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/descriptors/1").to route_to("descriptors#destroy", :id => "1")
    end

  end
end
