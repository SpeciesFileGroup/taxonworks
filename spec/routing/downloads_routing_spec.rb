require "rails_helper"

RSpec.describe DownloadsController, type: :routing, group: [:downloads] do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/downloads").to route_to("downloads#index")
    end

    it "routes to #list" do
      expect(:get => "/downloads/list").to route_to("downloads#list")
    end

    it "routes to #show" do
      expect(:get => "/downloads/1").to route_to("downloads#show", :id => "1")
    end

    it "routes to #file" do
      expect(:get => "/downloads/1/file").to route_to("downloads#file", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/downloads/1").to route_to("downloads#destroy", :id => "1")
    end
  end
end
