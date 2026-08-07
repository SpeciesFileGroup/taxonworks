require "rails_helper"

RSpec.describe LeadsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/leads").to route_to("leads#index")
    end

    it "routes to #new" do
      expect(get: "/leads/new").to route_to("leads#new")
    end

    it "routes to #show" do
      expect(get: "/leads/1").to route_to("leads#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/leads/1/edit").to route_to("leads#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/leads").to route_to("leads#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/leads/1").to route_to("leads#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/leads/1").to route_to("leads#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/leads/1").to route_to("leads#destroy", id: "1")
    end
  end
end
