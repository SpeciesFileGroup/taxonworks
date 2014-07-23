require "rails_helper"

describe BiocurationClassificationsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/biocuration_classifications")).to route_to("biocuration_classifications#index")
    end

    it "routes to #new" do
      expect(get("/biocuration_classifications/new")).to route_to("biocuration_classifications#new")
    end

    it "routes to #show" do
      expect(get("/biocuration_classifications/1")).to route_to("biocuration_classifications#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/biocuration_classifications/1/edit")).to route_to("biocuration_classifications#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/biocuration_classifications")).to route_to("biocuration_classifications#create")
    end

    it "routes to #update" do
      expect(put("/biocuration_classifications/1")).to route_to("biocuration_classifications#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/biocuration_classifications/1")).to route_to("biocuration_classifications#destroy", :id => "1")
    end

  end
end
