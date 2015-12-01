require "rails_helper"

RSpec.describe DocumentationController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/documentation").to route_to("documentation#index")
    end

    it "routes to #new" do
      expect(:get => "/documentation/new").to route_to("documentation#new")
    end

    it "routes to #show" do
      expect(:get => "/documentation/1").to route_to("documentation#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/documentation/1/edit").to route_to("documentation#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/documentation").to route_to("documentation#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/documentation/1").to route_to("documentation#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/documentation/1").to route_to("documentation#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/documentation/1").to route_to("documentation#destroy", :id => "1")
    end

  end
end
