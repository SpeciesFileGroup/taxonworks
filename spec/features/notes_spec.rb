require 'spec_helper'

describe "Notes" do
  describe "GET /Notes" do
    before { visit notes_path }
    specify 'an index name is present' do
      expect(page).to have_content('Listing notes')
    end
  end
end
