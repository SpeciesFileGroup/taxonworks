require "rails_helper"

describe BiocurationClassificationsController, :type => :routing do
  describe "routing" do

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
