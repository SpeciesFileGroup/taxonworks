require "rails_helper"

describe CrashTestController, :type => :routing do
  describe "routing" do
    context "when in production" do
      # before { Rails.stub_chain(:env, :production?) { true } }
      it "is not routable", skip: "config/routes.rb evaluated too early. Re-evaluation possible?" do
        expect(get("/crash_test")).to_not be_routable
      end
    end

    context "when not in production" do
      it "routes to #index" do
        expect(get("/crash_test")).to route_to("crash_test#index")
      end
    end
    
  end

end
