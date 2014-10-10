require 'rails_helper'

describe 'TaxonNames', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { taxon_names_path }
    let(:page_index_name) { 'Taxon Names' }
  end

  describe 'GET /taxon_names' do
    before {
      sign_in_user_and_select_project
      visit taxon_names_path }

    specify 'an index name is present' do
      expect(page).to have_content('Taxon Names')
    end
  end

  context 'signed in as a user, with some records created' do
    let(:p) { FactoryGirl.create(:root_taxon_name, user_project_attributes(@user, @project).merge( source: nil) ) }
    before {
      sign_in_user_and_select_project
      5.times {
          FactoryGirl.create(:iczn_family, user_project_attributes(@user, @project).merge(parent: p, source: nil) )
      }
    }
    
    describe 'GET /taxon_names/list' do
      before do
        visit list_taxon_names_path 
      end

      specify 'that it renders without error' do
        expect(page).to have_content 'Listing Taxon Names'
      end
    end

    describe 'GET /taxon_names/n' do
      before {
        visit taxon_name_path(TaxonName.second)
      }

      specify 'there is a \'previous\' link' do
        expect(page).to have_link('Previous')
      end

      specify 'there is a \'next\' link' do
        expect(page).to have_link('Next')
      end
    end
  end
end





