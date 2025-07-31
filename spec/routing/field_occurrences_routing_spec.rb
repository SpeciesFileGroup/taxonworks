require "rails_helper"

RSpec.describe FieldOccurrencesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/field_occurrences").to route_to("field_occurrences#index")
    end

    it "routes to #new" do
      expect(get: "/field_occurrences/new").to route_to("field_occurrences#new")
    end

    it "routes to #show" do
      expect(get: "/field_occurrences/1").to route_to("field_occurrences#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/field_occurrences/1/edit").to route_to("field_occurrences#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/field_occurrences").to route_to("field_occurrences#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/field_occurrences/1").to route_to("field_occurrences#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/field_occurrences/1").to route_to("field_occurrences#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/field_occurrences/1").to route_to("field_occurrences#destroy", id: "1")
    end
  end
end
