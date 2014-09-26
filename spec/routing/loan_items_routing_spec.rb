require "rails_helper"

describe LoanItemsController, :type => :routing do
  describe "routing" do

    it "routes to #create" do
      expect(post("/loan_items")).to route_to("loan_items#create")
    end

    it "routes to #update" do
      expect(put("/loan_items/1")).to route_to("loan_items#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/loan_items/1")).to route_to("loan_items#destroy", :id => "1")
    end

  end
end
