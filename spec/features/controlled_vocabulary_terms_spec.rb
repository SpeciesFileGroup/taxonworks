require 'rails_helper'

describe 'ControlledVocabularyTerms', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { controlled_vocabulary_terms_path }
    let(:page_index_name) { 'Controlled Vocabulary Terms' }
  end

  context 'signed in with a project selected' do
    before { sign_in_user_and_select_project }

    describe 'GET /controlled_vocabulary_terms' do
      before {
        visit controlled_vocabulary_terms_path
      }

      specify 'an index name is present' do
        expect(page).to have_content('Controlled Vocabulary Terms')
      end
    end

    context 'with some records created' do
      let(:p) { FactoryGirl.create(:root_taxon_name, user_project_attributes(@user, @project).merge(source: nil)) }
      before {
        5.times {
          FactoryGirl.create(:valid_controlled_vocabulary_term, user_project_attributes(@user, @project))
        }
      }

      describe 'GET /controlled_vocabulary_terms/list' do
        before do
          visit list_controlled_vocabulary_terms_path
        end

        specify 'it renders list without error' do
          expect(page).to have_content 'Listing Controlled Vocabulary Terms'
        end
      end

      describe 'GET /controlled_vocabulary_terms/n' do
        before {
          visit controlled_vocabulary_term_path(ControlledVocabularyTerm.second)
        }

        specify 'there is a "previous" link' do
          expect(page).to have_link('Previous')
        end

        specify 'there is a "next" link' do
          expect(page).to have_link('Next')
        end
      end
    end

    specify 'controlled_vocabulary_terms_path should have a new link' do
      visit controlled_vocabulary_terms_path
      expect(page).to have_link('New') # it has a new link

    end
    specify 'adding a new controlled vocabulary term' do
      visit controlled_vocabulary_terms_path
      click_link('New') # when I click the new link

      select('Topic', from: 'controlled_vocabulary_term_type') # I select 'Topic' from the Type dropdown
      fill_in('Name', with: 'tests')   # I fill in the name field with "tests"
      fill_in('Definition', with: 'This is a definition.') # I fill in the definition field with "This is a definition."

      click_button('Create Controlled vocabulary term') # I click the 'Create Controlled vocabulary term' button

      # then I get the message "Topic 'tests' was successfully created"
      expect(page).to have_content("Topic 'tests' was successfully created")
    end
 end
end
