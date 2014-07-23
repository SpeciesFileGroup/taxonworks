require "rails_helper"

describe RangedLotCategoriesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/ranged_lot_categories")).to route_to("ranged_lot_categories#index")
    end

    it "routes to #new" do
      expect(get("/ranged_lot_categories/new")).to route_to("ranged_lot_categories#new")
    end

    it "routes to #show" do
      expect(get("/ranged_lot_categories/1")).to route_to("ranged_lot_categories#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/ranged_lot_categories/1/edit")).to route_to("ranged_lot_categories#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/ranged_lot_categories")).to route_to("ranged_lot_categories#create")
    end

    it "routes to #update" do
      expect(put("/ranged_lot_categories/1")).to route_to("ranged_lot_categories#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/ranged_lot_categories/1")).to route_to("ranged_lot_categories#destroy", :id => "1")
    end

  end
end
