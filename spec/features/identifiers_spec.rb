require 'rails_helper'

describe 'Identifiers', type: :feature do
  let(:page_title) { 'Identifiers' }
  let(:index_path) { identifiers_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project

      (1..3).each do |n|
        o = Otu.create(name: "O", by: @user, project: @project)
        Identifier::Local::CatalogNumber.create!(namespace: namespace, identifier_object: o, identifier: n, by: @user, project: @project)
      end
    }

    let(:namespace) { Namespace.create!(name: 'Matt Ids', short_name: "MID", by: @user) }

    describe 'GET /identifiers' do
      before {
        visit identifiers_path
      }

      it_behaves_like 'a_data_model_with_annotations_index'
    end

    describe 'GET /identifiers/list' do
      before { visit list_identifiers_path }

      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
    end

    context 'creating a new identifier' do
      before {
        specimen = factory_girl_create_for_user_and_project(:valid_specimen, @user, @project)
        visit collection_object_path(specimen)
      }

      specify 'can create a new local identifier', js: true do
        find('#show_annotate_dropdown').hover
        expect(page).to have_link("Add identifier")
        click_link('Add identifier') 
       
        expect(page).to have_content("New identifier for:")

        expect(page.has_field?('identifier_identifier', :type => 'text')).to be_truthy
        expect(page.has_field?('identifier_type', :type => 'select')).to be_truthy
        expect(page.has_field?('namespace_id_for_identifier', :type => 'text')).to be_truthy

        fill_in('identifier_identifier', with: '678876')
        select('Catalog number', from: 'identifier_type') 
        
        expect(page.has_field?('identifier_type', :with => 'Identifier::Local::CatalogNumber')).to be_truthy

        fill_autocomplete('namespace_id_for_identifier', with: namespace.name, select: namespace.id)

        click_button('Create Identifier')
        expect(page).to have_content("Identifier was successfully created.")
        expect(page).to have_content("MID 678876 (Catalog number)")
      end

      specify 'can create a new global identifier', js: true do
        find('#show_annotate_dropdown').hover
        click_link('Add identifier') 

        fill_in('identifier_identifier', with: '10.2105/AJPH.2009.160184')
        select('Doi', from: 'identifier_type') 
        expect(page.has_field?('identifier_type', :with => 'Identifier::Global::Doi')).to be_truthy
        fill_in('namespace_id_for_identifier', :with => '')

        click_button('Create Identifier')
        expect(page).to have_content("Identifier was successfully created.")
        expect(page).to have_content("10.2105/AJPH.2009.160184 (Doi)")
      end

    end
  end
end







