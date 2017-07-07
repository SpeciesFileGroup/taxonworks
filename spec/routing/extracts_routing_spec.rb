require "rails_helper"

RSpec.describe ExtractsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/extracts").to route_to("extracts#index")
    end

    it "routes to #new" do
      expect(:get => "/extracts/new").to route_to("extracts#new")
    end

    it "routes to #show" do
      expect(:get => "/extracts/1").to route_to("extracts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/extracts/1/edit").to route_to("extracts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/extracts").to route_to("extracts#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/extracts/1").to route_to("extracts#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/extracts/1").to route_to("extracts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/extracts/1").to route_to("extracts#destroy", :id => "1")
    end

  end
end
