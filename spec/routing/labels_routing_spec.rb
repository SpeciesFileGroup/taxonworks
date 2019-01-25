require "rails_helper"

RSpec.describe LabelsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/labels").to route_to("labels#index")
    end

    it "routes to #new" do
      expect(:get => "/labels/new").to route_to("labels#new")
    end

    it "routes to #show" do
      expect(:get => "/labels/1").to route_to("labels#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/labels/1/edit").to route_to("labels#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/labels").to route_to("labels#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/labels/1").to route_to("labels#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/labels/1").to route_to("labels#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/labels/1").to route_to("labels#destroy", :id => "1")
    end

  end
end
