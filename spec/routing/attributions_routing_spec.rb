require "rails_helper"

RSpec.describe AttributionsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/attribution").to route_to("attribution#index")
    end

    it "routes to #new" do
      expect(:get => "/attribution/new").to route_to("attribution#new")
    end

    it "routes to #show" do
      expect(:get => "/attribution/1").to route_to("attribution#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/attribution/1/edit").to route_to("attribution#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/attribution").to route_to("attribution#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/attribution/1").to route_to("attribution#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/attribution/1").to route_to("attribution#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/attribution/1").to route_to("attribution#destroy", :id => "1")
    end
  end
end
