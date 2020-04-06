require "rails_helper"

RSpec.describe DatasetRecordsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/dataset_records").to route_to("dataset_records#index")
    end

    it "routes to #new" do
      expect(get: "/dataset_records/new").to route_to("dataset_records#new")
    end

    it "routes to #show" do
      expect(get: "/dataset_records/1").to route_to("dataset_records#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/dataset_records/1/edit").to route_to("dataset_records#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/dataset_records").to route_to("dataset_records#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/dataset_records/1").to route_to("dataset_records#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/dataset_records/1").to route_to("dataset_records#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/dataset_records/1").to route_to("dataset_records#destroy", id: "1")
    end
  end
end
