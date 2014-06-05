require 'spec_helper'

describe "OtuPageLayouts" do
  describe "GET /otu_page_layouts" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get otu_page_layouts_path
      response.status.should be(200)
    end
  end
end
