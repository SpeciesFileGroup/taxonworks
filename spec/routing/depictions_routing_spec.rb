require "rails_helper"

RSpec.describe DepictionsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/depictions").to route_to("depictions#index")
    end

    it "routes to #new" do
      expect(:get => "/depictions/new").to route_to("depictions#new")
    end

    it "routes to #show" do
      expect(:get => "/depictions/1").to route_to("depictions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/depictions/1/edit").to route_to("depictions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/depictions").to route_to("depictions#create")
    end

    it "routes to #update" do
      expect(:put => "/depictions/1").to route_to("depictions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/depictions/1").to route_to("depictions#destroy", :id => "1")
    end

  end
end
