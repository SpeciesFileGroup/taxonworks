require "rails_helper"

RSpec.describe TypeMaterialsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/type_materials").to route_to("type_materials#index")
    end

    it "routes to #list" do
      expect(get("/type_materials/list")).to route_to("type_materials#list")
    end

    it "routes to #new" do
      expect(:get => "/type_materials/new").to route_to("type_materials#new")
    end

    it "routes to #show" do
      expect(:get => "/type_materials/1").to route_to("type_materials#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/type_materials/1/edit").to route_to("type_materials#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/type_materials").to route_to("type_materials#create")
    end

    it "routes to #update" do
      expect(:put => "/type_materials/1").to route_to("type_materials#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/type_materials/1").to route_to("type_materials#destroy", :id => "1")
    end

  end
end
