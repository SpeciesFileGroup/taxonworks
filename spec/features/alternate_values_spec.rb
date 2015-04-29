require 'rails_helper'

describe "AlternateValues", :type => :feature do
  let(:index_path) { alternate_values_path }
  let(:page_index_name) { 'alternate values' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project

      k = Keyword.create!(name: 'Dictionary', definition: "Book with words", by: @user, project: @project)

      ['D.', 'Dict.', 'Di.'].each do |n|
        AlternateValue::Abbreviation.create!(alternate_value_object: k, value: n, alternate_value_object_attribute: :name, by: @user, project: @project)
      end
    }

    describe 'GET /alternate_values' do
      before {
        visit alternate_values_path }

      it_behaves_like 'a_data_model_with_annotations_index'
    end

    describe 'GET /alternate_values/list' do
      before { visit list_alternate_values_path }

      it_behaves_like 'a_data_model_with_standard_list'
    end

    context 'create an alternate value' do
      specify 'for Source::Bibtex', js: true do
=begin
    with a Source::BibTeX created (containing at least title)
    when I show that record
       then there is a link "Add alternate value"
         when I click that link
            and I select "title" from Alternate value object attribute
            and I fill out value
            and Type has "abbreviation" selected
            then when I click "Create Alternate value"
                I see the message "Alternate value was successfully created."
                   I see the alternate value rendered under Annotations/Alternate value in the show
=end
        # create a Source::Bibtex record
        src_bibtex = factory_girl_create_for_user(:soft_valid_bibtex_source_article, @user)
        src_bibtex.save!
        visit (source_path(src_bibtex))
        expect(page).to have_link('Add alternate value')
        expect(page.has_content?('Annotations')).to be_falsey
        expect(page.has_content?('Alternate values')).to be_falsey
        click_link('Add alternate value')
        fill_in('Value', with: 'Alternate Title')
        select('title', from: 'alternate_value_alternate_value_object_attribute')
        select('abbreviation', from: 'Type')
        click_button('Create Alternate value')
        expect(page).to have_content('Alternate value was successfully created.')
        expect(page.has_content?('Annotations')).to be_truthy
        expect(page.has_content?('Alternate values')).to be_truthy
        expect(page).to have_content('Alternate Title, abbreviation of "I am a soft valid article" (on \'title\')')
      end
    end
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
