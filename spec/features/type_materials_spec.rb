require 'rails_helper'

RSpec.describe "TypeMaterials", :type => :feature do
  # Capybara.default_wait_time = 15


  let(:page_title) { 'Type materials' }
  let(:index_path) { type_materials_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'when signed in and a project is selected' do
    before {
      sign_in_user_and_select_project
    }

    let!(:root) { factory_girl_create_for_user_and_project(:root_taxon_name, @user, @project) }

    context 'with some records created' do

      let!(:p) { Protonym.create!(name: 'aus', rank_class: Ranks.lookup(:iczn, 'species'), parent: root, by: @user, project: project) } 
      let!(:s) { factory_girl_create_for_user_and_project(:valid_specimen, @user, @project) }
      before do
        10.times {
          FactoryGirl.create(:valid_type_material,
                             material: s,
                             protonym: p,
                             type: 'paratype',
                             project: @project,
                             creator: @user,
                             updater: @user
                            )
        }

        describe 'GET /type_materials' do
          before { visit type_materials_path }

          it_behaves_like 'a_data_model_with_standard_index'
        end

        describe 'GET /type_materials/list' do
          before { visit list_type_materials_path }

          it_behaves_like 'a_data_model_with_standard_list_and_records_created'
        end

        describe 'GET /type_materials/n' do
          before {
            visit type_material_path(TypeMaterial.second)
          }

          it_behaves_like 'a_data_model_with_standard_show'
        end
      end
    end

    context 'creating a new type_materials' do
      context 'testing the new type_materials form' do
        #  - a namespace short name 'INHSIC' is created
        let(:namesp) { FactoryGirl.create(:namespace, {creator: @user, updater: @user,
                                                       name: 'INHSIC', short_name: 'INHSIC',
                                                       verbatim_short_name: 'INHSIC'}) }

        #  - a specimen is created
        let(:specimen) { FactoryGirl.create(:valid_specimen, user_project_attributes(@user, @project)) }

        specify 'filling out the form', js: true do

          f = Protonym.create!(name: 'Aaidae', rank_class: Ranks.lookup(:iczn, 'family'),
                               parent: root,
                               by: @user, project: @project)

          g = Protonym.create!(name: 'Cus', rank_class: Ranks.lookup(:iczn, 'Genus'),
                               parent: f,
                               by: @user, project: @project)

          #  - a species 'bus' with parent 'Cus' is created
          sp = Protonym.create!(name: 'bus', rank_class: Ranks.lookup(:iczn, 'Species'),
                                parent: g,
                                by: @user, project: @project)

          ident = Identifier::Local::CatalogNumber.create!(identifier_object: specimen,
                                                           identifier: '1234',
                                                           namespace_id: namesp.id,
                                                           by: @user, project: @project)

          #  - an identifier with Namespace 'INHSIC' and identifier '1234' attached to specimen is created
          expect(ident.cached).to eq('INHSIC 1234')

          visit type_materials_path

          click_link('New') 

          # I fill out the name field with "bus"
          # I click 'Bus bus (species)' from drop down list
          # NOTES: need the full name (genus & species) and I'm not getting the species name set correctly.
          fill_autocomplete('protonym_id_for_type_material', with: 'Cus bus', select: sp.id)

          # NOTES: still not finding the correct record.
          # I fill out the Material field with 'INHSIC 1234'
          #      and I click on the only record returned*
          fill_autocomplete('biological_object_id_for_type_material', with: 'INHSIC 1234', select: specimen.id )

          select('paratype', from: 'type_material_type_type') # select 'paratype' from the dropdown
          click_button 'Create Type material' # click the 'Create type material' button
          # then I get the message "Type material (paratype) for Aus bus was successfully created"
          expect(page).to have_content('Type material (paratype) for Cus bus was successfully created.')
        end
      end
    end
  end
end
