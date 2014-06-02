require "spec_helper"

describe NotesController do
  describe "routing" do

    it "routes to #index" do
      get("/notes").should route_to("notes#index")
    end

    it "routes to #new" do
      get("/notes/new").should route_to("notes#new")
    end

    it "routes to #show" do
      get("/notes/1").should route_to("notes#show", :id => "1")
    end

    it "routes to #edit" do
      get("/notes/1/edit").should route_to("notes#edit", :id => "1")
    end

    it "routes to #create" do
      post("/notes").should route_to("notes#create")
    end

    it "routes to #update" do
      put("/notes/1").should route_to("notes#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/notes/1").should route_to("notes#destroy", :id => "1")
    end

  end
end
