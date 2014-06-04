require 'spec_helper'

describe "BiocurationClassifications" do
  describe "GET /biocuration_classifications" do
    before { visit biocuration_classifications_path }
    specify 'an index name is present' do
      expect(page).to have_content('Listing biocuration_classifications')
    end
  end
end
