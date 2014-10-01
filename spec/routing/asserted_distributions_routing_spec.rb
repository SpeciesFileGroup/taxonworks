require "rails_helper"

RSpec.describe AssertedDistributionsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/asserted_distributions").to route_to("asserted_distributions#index")
    end

    it "routes to #list" do
      expect(get("/asserted_distributions/list")).to route_to("asserted_distributions#list")
    end

    it "routes to #new" do
      expect(:get => "/asserted_distributions/new").to route_to("asserted_distributions#new")
    end

    it "routes to #show" do
      expect(:get => "/asserted_distributions/1").to route_to("asserted_distributions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/asserted_distributions/1/edit").to route_to("asserted_distributions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/asserted_distributions").to route_to("asserted_distributions#create")
    end

    it "routes to #update" do
      expect(:put => "/asserted_distributions/1").to route_to("asserted_distributions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/asserted_distributions/1").to route_to("asserted_distributions#destroy", :id => "1")
    end

  end
end
