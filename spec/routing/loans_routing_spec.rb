require "spec_helper"

describe LoansController do
  describe "routing" do

    it "routes to #index" do
      get("/loans").should route_to("loans#index")
    end

    it "routes to #new" do
      get("/loans/new").should route_to("loans#new")
    end

    it "routes to #show" do
      get("/loans/1").should route_to("loans#show", :id => "1")
    end

    it "routes to #edit" do
      get("/loans/1/edit").should route_to("loans#edit", :id => "1")
    end

    it "routes to #create" do
      post("/loans").should route_to("loans#create")
    end

    it "routes to #update" do
      put("/loans/1").should route_to("loans#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/loans/1").should route_to("loans#destroy", :id => "1")
    end

  end
end
