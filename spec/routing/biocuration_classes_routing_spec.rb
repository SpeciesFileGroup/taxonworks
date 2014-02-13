require "spec_helper"

describe BiocurationClassesController do
  describe "routing" do

    it "routes to #index" do
      get("/biocuration_classes").should route_to("biocuration_classes#index")
    end

    it "routes to #new" do
      get("/biocuration_classes/new").should route_to("biocuration_classes#new")
    end

    it "routes to #show" do
      get("/biocuration_classes/1").should route_to("biocuration_classes#show", :id => "1")
    end

    it "routes to #edit" do
      get("/biocuration_classes/1/edit").should route_to("biocuration_classes#edit", :id => "1")
    end

    it "routes to #create" do
      post("/biocuration_classes").should route_to("biocuration_classes#create")
    end

    it "routes to #update" do
      put("/biocuration_classes/1").should route_to("biocuration_classes#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/biocuration_classes/1").should route_to("biocuration_classes#destroy", :id => "1")
    end

  end
end
