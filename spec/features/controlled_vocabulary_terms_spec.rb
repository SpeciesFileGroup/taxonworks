require 'rails_helper'

describe 'ControlledVocabularyTerms', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { controlled_vocabulary_terms_path }
    let(:page_index_name) { 'Controlled Vocabulary Terms' }
  end

  describe 'GET /controlled_vocabulary_terms' do
    before {
      sign_in_user_and_select_project
      visit controlled_vocabulary_terms_path }

    specify 'an index name is present' do
      expect(page).to have_content('Controlled Vocabulary Terms')
    end
  end

  describe 'GET /controlled_vocabulary_terms/list' do
    before do
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      # this is so that there is more than one page
      30.times { FactoryGirl.create(:valid_controlled_vocabulary_term) }
      visit '/controlled_vocabulary_terms/list'
    end

    specify 'that it renders without error' do
      expect(page).to have_content 'Listing Controlled Vocabulary Terms'
    end
  end

  describe 'GET /controlled_vocabulary_terms/n' do
    before {
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      3.times { FactoryGirl.create(:valid_controlled_vocabulary_term) }
      all_controlled_vocabulary_terms = ControlledVocabularyTerm.all.map(&:id)
      # there *may* be a better way to do this, but this version *does* work
      visit "/controlled_vocabulary_terms/#{all_controlled_vocabulary_terms[1]}"
    }

    specify 'there is a \'previous\' link' do
      expect(page).to have_link('Previous')
    end

    specify 'there is a \'next\' link' do
      expect(page).to have_link('Next')
    end
  end

end


