require "rails_helper"

RSpec.describe GazetteersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/gazetteers").to route_to("gazetteers#index")
    end

    it "routes to #new" do
      expect(get: "/gazetteers/new").to route_to("gazetteers#new")
    end

    it "routes to #show" do
      expect(get: "/gazetteers/1").to route_to("gazetteers#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/gazetteers/1/edit").to route_to("gazetteers#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/gazetteers").to route_to("gazetteers#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/gazetteers/1").to route_to("gazetteers#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/gazetteers/1").to route_to("gazetteers#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/gazetteers/1").to route_to("gazetteers#destroy", id: "1")
    end
  end
end
