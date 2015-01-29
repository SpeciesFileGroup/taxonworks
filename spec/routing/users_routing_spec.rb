require "rails_helper"

describe UsersController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/users")).to route_to("users#index")
    end

#   it "routes to #new" do
#     get("/users/new").should route_to("users#new")
#   end

    it "routes to #show" do
      expect(get("/users/1")).to route_to("users#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/users/1/edit")).to route_to("users#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/users")).to route_to("users#create")
    end

    it "routes to #update" do
      expect(put("/users/1")).to route_to("users#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/users/1")).to route_to("users#destroy", :id => "1")
    end
    
    it "routes to #forgot_password" do
      expect(get("/forgot_password")).to route_to("users#forgot_password")
    end
    
    it "routes to #send_password_reset" do
      expect(post("/send_password_reset")).to route_to("users#send_password_reset")
    end
    
    it "routes to #password_reset" do
      expect(get("/password_reset/TOKEN")).to route_to("users#password_reset", :token => 'TOKEN')
    end
    
    it "routes to #set_password" do
      expect(patch("/set_password/TOKEN")).to route_to("users#set_password", :token => 'TOKEN')
    end

  end
end
