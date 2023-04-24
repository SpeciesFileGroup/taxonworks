require "rails_helper"

RSpec.describe ColdpProfilesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/coldp_profiles").to route_to("coldp_profiles#index")
    end

    it "routes to #new" do
      expect(get: "/coldp_profiles/new").to route_to("coldp_profiles#new")
    end

    it "routes to #show" do
      expect(get: "/coldp_profiles/1").to route_to("coldp_profiles#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/coldp_profiles/1/edit").to route_to("coldp_profiles#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/coldp_profiles").to route_to("coldp_profiles#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/coldp_profiles/1").to route_to("coldp_profiles#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/coldp_profiles/1").to route_to("coldp_profiles#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/coldp_profiles/1").to route_to("coldp_profiles#destroy", id: "1")
    end
  end
end
