require 'spec_helper'

describe "Identifiers" do
  describe "GET /identifiers" do
    before { visit identifiers_path }
    specify 'an index name is present' do
      expect(page).to have_content('Identifiers')
    end
  end
end







