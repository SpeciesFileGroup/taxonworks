require "rails_helper"

describe LoansController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/loans")).to route_to("loans#index")
    end

    it "routes to #list" do
      expect(get("/loans/list")).to route_to("loans#list")
    end

    it "routes to #new" do
      expect(get("/loans/new")).to route_to("loans#new")
    end

    it "routes to #show" do
      expect(get("/loans/1")).to route_to("loans#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/loans/1/edit")).to route_to("loans#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/loans")).to route_to("loans#create")
    end

    it "routes to #update" do
      expect(put("/loans/1")).to route_to("loans#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/loans/1")).to route_to("loans#destroy", :id => "1")
    end

  end
end
