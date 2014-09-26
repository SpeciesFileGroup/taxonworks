require "rails_helper"

describe NotesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/notes")).to route_to("notes#index")
    end

    it "routes to #list" do
      expect(get("/notes/list")).to route_to("notes#list")
    end

    it "routes to #create" do
      expect(post("/notes")).to route_to("notes#create")
    end

    it "routes to #update" do
      expect(put("/notes/1")).to route_to("notes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/notes/1")).to route_to("notes#destroy", :id => "1")
    end

  end
end
