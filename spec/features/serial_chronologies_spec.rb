require 'spec_helper'

describe "SerialChronologies" do
  describe "GET /serial_chronologies" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get serial_chronologies_path
      response.status.should be(200)
    end
  end
end
