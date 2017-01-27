require 'rails_helper'

describe "AlternateValues", type: :feature do
  let(:index_path) { alternate_values_path }
  let(:page_title) { 'Alternate values' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user' do
    before {
      sign_in_user_and_select_project

    }
    context 'with some record created' do

      before {

        k = Keyword.create!(name: 'Dictionary', definition: "Book with words", by: @user, project: @project)

        ['D.', 'Dict.', 'Di.'].each do |n|
          AlternateValue::Abbreviation.create!(alternate_value_object: k, value: n, alternate_value_object_attribute: :name, by: @user)
        end
      }

      describe 'GET /alternate_values' do
        before { visit alternate_values_path }

        it_behaves_like 'a_data_model_with_annotations_index'
      end

      describe 'GET /alternate_values/list' do
        before { visit list_alternate_values_path }

        it_behaves_like 'a_data_model_with_standard_list_and_records_created'
      end

      context 'create an alternate value for a community object (Source::Bibtex)' do
        let(:src_bibtex) { factory_girl_create_for_user(:soft_valid_bibtex_source_article, @user) }
        #  with a Source::BibTeX created (containing at least title)

        specify 'community visible' do
          # created source has no alternate values
          expect(src_bibtex.alternate_valued?).to be_falsey

          #  when I show that record
          visit source_path(src_bibtex)

          # then there is a link "Add alternate value"
          expect(page).to have_link('Add alternate value')
          expect(page.has_content?('Annotations')).to be_falsey
          expect(page.has_content?('Alternate values')).to be_falsey

          # when I click that link      
          click_link('Add alternate value')

          # I should see a checkbox allowing the user to create it within the project
          expect(find_field('project_members_only').checked?).to be_falsey

          # and I select "title" from Alternate value object attribute
          select('title', from: 'alternate_value_alternate_value_object_attribute')

          # spec/features/alternate_values_spec.rb
          fill_in('Value', with: 'Alternate Title')

          # and Type has "abbreviation" selected
          select('abbreviation', from: 'Type')

          # then when I click "Create Alternate value"
          click_button('Create Alternate value')

          #        I see the message "Alternate value was successfully created."
          #        I see the alternate value rendered under Annotations/Alternate value in the show
          expect(page).to have_content('Alternate value was successfully created.')
          expect(page.has_content?('Annotations')).to be_truthy
          expect(page.has_content?('Alternate values')).to be_truthy
          expect(page).to have_content('Alternate Title, abbreviation of "I am a soft valid article" (on \'title\')')

          # check that the alt. value created has a project_id of 0
          expect(src_bibtex.alternate_valued?).to be_truthy
          alt_v = src_bibtex.alternate_values[0]
          expect(alt_v.project_id).to be_nil

          #TODO check visible by different user
        end
        # pending 'project only visible'
      end

      # pending 'create an alternate value for a project object (controlled vocabulary)' do
      #   k2 = Keyword.create!(name: 'testkey', definition: 'testing keyword', by: @user, project: @project)
      #   #  when I show that record
      #   visit controlled_vocabulary_term_path(:id => k2.id)
      #
      #   # then there is a link "Add alternate value"
      #   expect(page).to have_link('Add alternate value')
      #   expect(page.has_content?('Annotations')).to be_falsey
      #   expect(page.has_content?('Alternate values')).to be_falsey
      #
      #   # when I click that link
      #   click_link('Add alternate value')
      #
      #   # I should NOT see a checkbox allowing the user to create it within the project
      #   # expect(find_field('project_members_only').visible?).to be_falsey
      #
      #   # and I select "name" from Alternate value object attribute
      #   select('name', from: 'alternate_value_alternate_value_object_attribute')
      #
      #   # spec/features/alternate_values_spec.rb
      #   fill_in('Value', with: 'KeyTest')
      #
      #   # and Type has 'alternate spelling' selected
      #   select('alternate spelling', from: 'Type')
      #
      #   # then when I click "Create Alternate value"
      #   click_button('Create Alternate value')
      #
      #   #        I see the message "Alternate value was successfully created."
      #   #          I see the alternate value rendered under Annotations/Alternate value in the show
      #   expect(page).to have_content('Alternate value was successfully created.')
      #   expect(page.has_content?('Annotations')).to be_truthy
      #   expect(page.has_content?('Alternate values')).to be_truthy
      #   expect(page).to have_content('KeyTest, alternate spelling of "testkey" (on \'name\')')
      #
      # end
    end

    context 'resource routes' do
      #  before { 
      #    sign_in_user_and_select_project
      #  }

      # The scenario for creating alternate values has not been developed. 
      # It must handle these three calls for logged in/not logged in users.
      # It may be that these features are ultimately tested in a task.
      describe 'POST /create' do
      end

      describe 'PATCH /update' do
      end

      describe 'DELETE /destroy' do
      end

      describe 'the partial form rendered in context of NEW/EDIT on some other page' do
      end
    end

  end
end
