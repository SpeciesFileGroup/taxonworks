require "rails_helper"

RSpec.describe GeneAttributesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/gene_attributes").to route_to("gene_attributes#index")
    end

    it "routes to #new" do
      expect(:get => "/gene_attributes/new").to route_to("gene_attributes#new")
    end

    it "routes to #show" do
      expect(:get => "/gene_attributes/1").to route_to("gene_attributes#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/gene_attributes/1/edit").to route_to("gene_attributes#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/gene_attributes").to route_to("gene_attributes#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/gene_attributes/1").to route_to("gene_attributes#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/gene_attributes/1").to route_to("gene_attributes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/gene_attributes/1").to route_to("gene_attributes#destroy", :id => "1")
    end

  end
end
