require 'spec_helper'

describe "Peoples" do
  describe "GET /people" do
    before { visit people_path }
    specify 'an index name is present' do
      expect(page).to have_content('Listing people')
    end
  end
end

