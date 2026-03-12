require "rails_helper"

RSpec.describe AnatomicalPartsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/anatomical_parts").to route_to("anatomical_parts#index")
    end

    it "routes to #new" do
      expect(get: "/anatomical_parts/new").to route_to("anatomical_parts#new")
    end

    it "routes to #show" do
      expect(get: "/anatomical_parts/1").to route_to("anatomical_parts#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/anatomical_parts/1/edit").to route_to("anatomical_parts#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/anatomical_parts").to route_to("anatomical_parts#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/anatomical_parts/1").to route_to("anatomical_parts#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/anatomical_parts/1").to route_to("anatomical_parts#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/anatomical_parts/1").to route_to("anatomical_parts#destroy", id: "1")
    end
  end
end
