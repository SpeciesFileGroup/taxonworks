require 'spec_helper'

describe "GeographicAreas" do
  describe "GET /geographic_areas" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get geographic_areas_path
      response.status.should be(200)
    end
  end
end
