require 'spec_helper'

describe "BiocurationClasses" do
  describe "GET /biocuration_classes" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get biocuration_classes_path
      response.status.should be(200)
    end
  end
end
