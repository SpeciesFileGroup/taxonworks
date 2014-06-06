require 'spec_helper'

describe 'Georeferences' do
  describe 'GET /georeferences' do
    before { visit georeferences_path }
    specify 'an index name is present' do
      expect(page).to have_content('Georeferences')
    end
  end
end






