require 'rails_helper'

RSpec.describe "TypeMaterials", :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { type_materials_path }
    let(:page_index_name) { 'Type Materials' }
  end

  context 'when signed in and a project is selected' do
    before {
      sign_in_user_and_select_project # logged in and project selected
    }

    context 'with some records created' do
      let!(:o) { factory_girl_create_for_user_and_project(:valid_otu, @user, @project) }
      let!(:s) { factory_girl_create_for_user_and_project(:valid_specimen, @user, @project) } 
      before do
        10.times {
          FactoryGirl.create(:valid_type_material,
                             otu: o, 
                             material: s, 
                             type: 'paratype',
                             project: @project,
                             creator: @user,
                             updater: @user
                            )
        }

        describe 'GET /type_materials' do
          before {
            visit type_materials_path }
          specify 'a index name is present' do
            expect(page).to have_content('Type Materials')
          end
        end

        describe 'GET /type_materials/list' do
          before { visit type_materials_path}
          specify 'that it renders without error' do
            expect(page).to have_content 'Listing type materials'
          end
        end

        describe 'GET /type_materials/n' do
          before {
            visit type_material_path(TypeMaterial.second)
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

    context 'creating a new type_materials' do
      let(:p) {FactoryGirl.create(:root_taxon_name,
                                  user_project_attributes(@user, @project).merge(source: nil)) }
      #  - a root taxon name is created
      specify 'the type_materials_path has a new link' do
        visit type_materials_path # when I visit the type_material_path
        expect(page).to have_link('New') # it has a new link
      end
      context 'testing the new type_materials form' do
      before {
        @family  = FactoryGirl.create(:valid_taxon_name)
          #  - a family 'Aidae' with parent root is created  (valid taxon factory default)
        @genus  = FactoryGirl.create(:iczn_genus, name: 'Bus', parent: @family)
          #  - a genus 'Bus' with parent 'Aidae' is created
        @species = FactoryGirl.create(:iczn_species, name: 'bus', parent: @genus)
          #  - a species 'bus' with parent 'Bus' is created
        @namespace = FactoryGirl.create(:namespace, name: 'INHS long name', short_name: 'INHSIC')
          #  - a namespace short name 'INHSIC' is created
        @specimen = FactoryGirl.create(:valid_specimen)    #  - a specimen is created
        @specimen.identifiers <<  Identifier.new(type:'Identifier::Local::CatalogNumber',
                                                 namespace: @namespace,
                                                 identifier: '1234')
   #  - an identifier with Namespace 'INHSIC' and identifier '1234' attached to specimen is created
        @specimen.save!
      }
      pending 'filling out the form', js: true do
        click_link('New') # when I click the new link

        fill_autocomplete('protonym_id_for_type_material', with: 'bus') # I fill out the name field with "bus"
        # I click 'Bus bus (species)' from drop down list
        fill_autocomplete('biological_object_id_for_type_material', with: 'INHSIC 1234')
        # I fill out the Material field with 'INHSIC 1234'
        #      and I click on the only record returned*
        select('paratype', from: 'type_material_type_type') # select 'paratype' from the dropdown
        click_button 'Create Type material' # click the 'Create type material' button
        # then I get the message "Type material (paratype) for Aus bus was successfully created"
        expect(page).to have_content('Type material (paratype) for Aus bus was successfully created')
      end
    end
    end
  end
end
