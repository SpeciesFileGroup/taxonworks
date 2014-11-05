require 'rails_helper'

RSpec.describe "TypeMaterials", :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { type_materials_path }
    let(:page_index_name) { 'Type Materials' }
  end

  context 'when signed in an a project is selected' do
    before {
      sign_in_user_and_select_project
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
  end
end
