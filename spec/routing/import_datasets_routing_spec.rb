require "rails_helper"

RSpec.describe ImportDatasetsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/import_datasets").to route_to("import_datasets#index")
    end

    it "routes to #new" do
      expect(get: "/import_datasets/new").to route_to("import_datasets#new")
    end

    it "routes to #show" do
      expect(get: "/import_datasets/1").to route_to("import_datasets#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/import_datasets/1/edit").to route_to("import_datasets#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/import_datasets").to route_to("import_datasets#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/import_datasets/1").to route_to("import_datasets#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/import_datasets/1").to route_to("import_datasets#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/import_datasets/1").to route_to("import_datasets#destroy", id: "1")
    end
  end
end
