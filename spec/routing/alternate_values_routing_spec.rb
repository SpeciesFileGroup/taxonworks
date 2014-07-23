require "rails_helper"

describe AlternateValuesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/alternate_values")).to route_to("alternate_values#index")
    end

    it "routes to #new" do
      expect(get("/alternate_values/new")).to route_to("alternate_values#new")
    end

    it "routes to #show" do
      expect(get("/alternate_values/1")).to route_to("alternate_values#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/alternate_values/1/edit")).to route_to("alternate_values#edit", :id => "1")
    end

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
