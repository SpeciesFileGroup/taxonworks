require 'spec_helper'

describe "ControlledVocabularyTerms", base_class: ControlledVocabularyTerm do

  it_behaves_like 'a_login_required_and_project_selected_controller'
  
  describe "GET /controlled_vocabulary_terms" do
    before { visit controlled_vocabulary_terms_path }
    specify 'an index name is present' do
      expect(page).to have_content('Listing controlled_vocabulary_terms')
    end
  end
end


