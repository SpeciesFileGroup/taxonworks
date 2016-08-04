require "rails_helper"

RSpec.describe MatrixColumnsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/matrix_columns").to route_to("matrix_columns#index")
    end

    it "routes to #new" do
      expect(:get => "/matrix_columns/new").to route_to("matrix_columns#new")
    end

    it "routes to #show" do
      expect(:get => "/matrix_columns/1").to route_to("matrix_columns#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/matrix_columns/1/edit").to route_to("matrix_columns#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/matrix_columns").to route_to("matrix_columns#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/matrix_columns/1").to route_to("matrix_columns#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/matrix_columns/1").to route_to("matrix_columns#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/matrix_columns/1").to route_to("matrix_columns#destroy", :id => "1")
    end

  end
end
