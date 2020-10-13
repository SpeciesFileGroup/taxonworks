require "rails_helper"

RSpec.describe DatasetRecordsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/import_datasets/1/dataset_records").to route_to("dataset_records#index", import_dataset_id: "1")
    end

    it "routes to #show" do
      expect(get: "/import_datasets/1/dataset_records/2").to route_to("dataset_records#show", import_dataset_id: "1", id: "2")
    end

    it "routes to #create" do
      expect(post: "/import_datasets/1/dataset_records").to route_to("dataset_records#create", import_dataset_id: "1")
    end

    it "routes to #update via PUT" do
      expect(put: "/import_datasets/1/dataset_records/2").to route_to("dataset_records#update", import_dataset_id: "1", id: "2")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/import_datasets/1/dataset_records/2").to route_to("dataset_records#update", import_dataset_id: "1", id: "2")
    end

    it "routes to #destroy" do
      expect(delete: "/import_datasets/1/dataset_records/2").to route_to("dataset_records#destroy", import_dataset_id: "1", id: "2")
    end

    it "routes to #autocomplete_data_fields" do
      expect(get: "/import_datasets/1/dataset_records/autocomplete_data_fields").to route_to("dataset_records#autocomplete_data_fields", import_dataset_id: "1")
    end
  end
end
