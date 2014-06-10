require 'spec_helper'

describe 'ControlledVocabularyTerms', base_class: ControlledVocabularyTerm do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /controlled_vocabulary_terms' do
    before { 
      sign_in_valid_user_and_select_project 
      visit controlled_vocabulary_terms_path }
    specify 'an index name is present' do
      expect(page).to have_content('Controlled Vocabulary Terms')
    end
  end
end


