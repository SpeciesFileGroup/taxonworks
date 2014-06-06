require 'spec_helper'

describe "AlternateValues" do
  describe "GET /alternate_values" do
    before { visit alternate_values_path }
    specify 'an index name is present' do
      expect(page).to have_content('Alternate Values')
    end
  end
end
