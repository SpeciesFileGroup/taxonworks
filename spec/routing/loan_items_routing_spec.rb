require "rails_helper"

describe LoanItemsController do
  describe "routing" do

    it "routes to #index" do
      get("/loan_items").should route_to("loan_items#index")
    end

    it "routes to #new" do
      get("/loan_items/new").should route_to("loan_items#new")
    end

    it "routes to #show" do
      get("/loan_items/1").should route_to("loan_items#show", :id => "1")
    end

    it "routes to #edit" do
      get("/loan_items/1/edit").should route_to("loan_items#edit", :id => "1")
    end

    it "routes to #create" do
      post("/loan_items").should route_to("loan_items#create")
    end

    it "routes to #update" do
      put("/loan_items/1").should route_to("loan_items#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/loan_items/1").should route_to("loan_items#destroy", :id => "1")
    end

  end
end
