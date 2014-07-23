require "rails_helper"

describe LoanItemsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/loan_items")).to route_to("loan_items#index")
    end

    it "routes to #new" do
      expect(get("/loan_items/new")).to route_to("loan_items#new")
    end

    it "routes to #show" do
      expect(get("/loan_items/1")).to route_to("loan_items#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/loan_items/1/edit")).to route_to("loan_items#edit", :id => "1")
    end

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
