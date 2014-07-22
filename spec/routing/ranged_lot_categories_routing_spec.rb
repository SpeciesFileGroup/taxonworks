require "rails_helper"

describe RangedLotCategoriesController do
  describe "routing" do

    it "routes to #index" do
      get("/ranged_lot_categories").should route_to("ranged_lot_categories#index")
    end

    it "routes to #new" do
      get("/ranged_lot_categories/new").should route_to("ranged_lot_categories#new")
    end

    it "routes to #show" do
      get("/ranged_lot_categories/1").should route_to("ranged_lot_categories#show", :id => "1")
    end

    it "routes to #edit" do
      get("/ranged_lot_categories/1/edit").should route_to("ranged_lot_categories#edit", :id => "1")
    end

    it "routes to #create" do
      post("/ranged_lot_categories").should route_to("ranged_lot_categories#create")
    end

    it "routes to #update" do
      put("/ranged_lot_categories/1").should route_to("ranged_lot_categories#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/ranged_lot_categories/1").should route_to("ranged_lot_categories#destroy", :id => "1")
    end

  end
end
