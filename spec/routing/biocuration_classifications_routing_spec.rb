require "rails_helper"

describe BiocurationClassificationsController do
  describe "routing" do

    it "routes to #index" do
      get("/biocuration_classifications").should route_to("biocuration_classifications#index")
    end

    it "routes to #new" do
      get("/biocuration_classifications/new").should route_to("biocuration_classifications#new")
    end

    it "routes to #show" do
      get("/biocuration_classifications/1").should route_to("biocuration_classifications#show", :id => "1")
    end

    it "routes to #edit" do
      get("/biocuration_classifications/1/edit").should route_to("biocuration_classifications#edit", :id => "1")
    end

    it "routes to #create" do
      post("/biocuration_classifications").should route_to("biocuration_classifications#create")
    end

    it "routes to #update" do
      put("/biocuration_classifications/1").should route_to("biocuration_classifications#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/biocuration_classifications/1").should route_to("biocuration_classifications#destroy", :id => "1")
    end

  end
end
