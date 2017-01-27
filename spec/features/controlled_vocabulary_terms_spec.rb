require 'rails_helper'

describe 'ControlledVocabularyTerms', :type => :feature do
  let(:page_title) { 'Controlled vocabulary terms' }
  let(:index_path) { controlled_vocabulary_terms_path }

  it_behaves_like 'a_login_required_and_project_selected_controller' do
  end

  context 'signed in as a user, with some records created' do
    let(:p) { FactoryGirl.create(:root_taxon_name, user_project_attributes(@user, @project).merge(source: nil)) }
    before {
      sign_in_user_and_select_project
      5.times {
        FactoryGirl.create(:valid_controlled_vocabulary_term, user_project_attributes(@user, @project))
      }
    }
    after {
      click_link('sign_out')
    }

    describe 'GET /controlled_vocabulary_terms' do
      before {
        visit controlled_vocabulary_terms_path
      }

      it_behaves_like 'a_data_model_with_standard_index'
    end

    describe 'GET /controlled_vocabulary_terms/list' do
      before do
        visit list_controlled_vocabulary_terms_path
      end

      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
    end

    describe 'GET /controlled_vocabulary_terms/n' do
      before {
        visit controlled_vocabulary_term_path(ControlledVocabularyTerm.second)
      }

      it_behaves_like 'a_data_model_with_standard_show'
    end
  end

  context 'creating a new controlled vocabulary term' do
    before {
      echo                           = Capybara.default_max_wait_time
      Capybara.default_max_wait_time = 15 # slows down Capybara enough to see what's happening on the form
      sign_in_user_and_select_project
      visit controlled_vocabulary_terms_path
      Capybara.default_max_wait_time = echo
    }
    after {
      click_link('sign_out')
    }

    specify 'adding a new controlled vocabulary term' do
      visit controlled_vocabulary_terms_path
      click_link('New') # when I click the new link

      select('Topic', from: 'controlled_vocabulary_term_type') # I select 'Topic' from the Type dropdown
      fill_in('Name', with: 'tests') # I fill in the name field with "tests"
      fill_in('Definition', with: 'This is a definition.') # I fill in the definition field with "This is a definition."

      click_button('Create Controlled vocabulary term') # I click the 'Create Controlled vocabulary term' button

      # then I get the message "Topic 'tests' was successfully created"
      expect(page).to have_content("Topic 'tests' was successfully created")
    end

    # Enable js to start using the selenium driver since the autocomplete box in Adding a tag requires it to test properly
    # NOTE: In order for Selenium 2.53.4 to work you need Firefox version 46.0.1 and lower installed
    context 'no controlled vocabulary terms made yet', js: true do
      context 'create controlled vocabulary term of type keyword' do
        before {
          visit controlled_vocabulary_terms_path
          click_link('New') # when I click the new link

          select('Keyword', from: 'controlled_vocabulary_term_type') # I select 'Keyword' from the Type dropdown
          fill_in('Name', with: 'TestKeyword') # I fill in the name field with 'TestKeyword'
          fill_in('Definition', with: 'TestKeyword definition') # I fill in the definition field with 'TestKeyword definition'

          click_button('Create Controlled vocabulary term') # I click the 'Create Controlled vocabulary term' button
        }

        specify 'should be able to see "Tagged Objects"' do
          # Click on the 'Report' header
          find('span', text: 'Report').click

          # I click the 'Tagged Objects' link under the 'Report' header
          click_link('Tagged Objects')

          # Then I get a page showing 'Objects with keyword "TestKeyword"'
          expect(page).to have_content('Objects with keyword "TestKeyword"')
        end

        context 'use newly created keyword as a tag' do
          # Create an otu
          before {
            visit otus_path
            click_link('New')
            fill_in 'Name', with: 'OtusTestName'
            click_button 'Create Otu'
          }

          specify 'tag the otu with newly created keyword' do
            # Click on 'Annotate' header to show 'Add Tag' link
            find('span', text: 'Annotate').click
            click_link('Add tag')

            # Fill in the tag info
            fill_in 'keyword_id_for_controlled_vocabulary_term', with: 'TestKeyword'
            find('a', text: "TestKeyword: TestKeyword definition").click
            click_button 'Create Tag'

            # Should have 'TestKeyword' under 'Tag' in the 'Annotations' box
            expect(page).to have_content('TestKeyword')

            # Go back to the 'TestKeyword' cvt
            visit controlled_vocabulary_terms_path
            click_link('TestKeyword')

            # Go to the 'Tagged Objects' link
            find('span', text: 'Report').click
            click_link('Tagged Objects')

            # Page should now list 'OtusTestName' under the 'Otu' category
            expect(page).to have_content('Otu (1)')
            expect(page).to have_content('OtusTestName')
          end
        end
      end
    end
  end
end
