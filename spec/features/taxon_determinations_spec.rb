require 'spec_helper'

describe 'TaxonDeterminations' do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /taxon_determinations' do
    before { visit taxon_determinations_path }
    specify 'an index name is present' do
      expect(page).to have_content('Taxon Determinations')
    end
  end
end



