require "rails_helper"

describe AlternateValuesController, :type => :routing do
  describe "routing" do

    it "routes to #create" do
      expect(post("/alternate_values")).to route_to("alternate_values#create")
    end

    it "routes to #update" do
      expect(put("/alternate_values/1")).to route_to("alternate_values#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/alternate_values/1")).to route_to("alternate_values#destroy", :id => "1")
    end

  end
end
