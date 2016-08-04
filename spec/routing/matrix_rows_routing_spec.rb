require "rails_helper"

RSpec.describe MatrixRowsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/matrix_rows").to route_to("matrix_rows#index")
    end

    it "routes to #new" do
      expect(:get => "/matrix_rows/new").to route_to("matrix_rows#new")
    end

    it "routes to #show" do
      expect(:get => "/matrix_rows/1").to route_to("matrix_rows#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/matrix_rows/1/edit").to route_to("matrix_rows#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/matrix_rows").to route_to("matrix_rows#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/matrix_rows/1").to route_to("matrix_rows#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/matrix_rows/1").to route_to("matrix_rows#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/matrix_rows/1").to route_to("matrix_rows#destroy", :id => "1")
    end

  end
end
