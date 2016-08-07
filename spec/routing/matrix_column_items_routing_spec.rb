require "rails_helper"

RSpec.describe MatrixColumnItemsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/matrix_column_items").to route_to("matrix_column_items#index")
    end

    it "routes to #new" do
      expect(:get => "/matrix_column_items/new").to route_to("matrix_column_items#new")
    end

    it "routes to #show" do
      expect(:get => "/matrix_column_items/1").to route_to("matrix_column_items#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/matrix_column_items/1/edit").to route_to("matrix_column_items#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/matrix_column_items").to route_to("matrix_column_items#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/matrix_column_items/1").to route_to("matrix_column_items#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/matrix_column_items/1").to route_to("matrix_column_items#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/matrix_column_items/1").to route_to("matrix_column_items#destroy", :id => "1")
    end

  end
end
