require 'rails_helper'

RSpec.describe "TypeMaterials", :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { type_materials_path }
    let(:page_index_name) { 'Type Materials' }
  end

  describe 'GET /type_materials' do
    before {
      sign_in_user_and_select_project
      visit type_materials_path }

    specify 'a index name is present' do
      expect(page).to have_content('Type Materials')
    end
  end

  describe 'GET /type_materials/list' do
    before do
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      # this is so that there is more than one page
      30.times { FactoryGirl.create(:valid_type_material) }
      visit '/type_materials/list'
    end

    specify 'that it renders without error' do
      expect(page).to have_content 'Listing type materials'
    end
  end

  describe 'GET /type_materials/n' do
    before {
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      3.times { FactoryGirl.create(:valid_type_material) }
      all_type_materials = TypeMaterial.all.map(&:id)
      # there *may* be a better way to do this, but this version *does* work
      visit "/type_materials/#{all_type_materials[1]}"
    }

    specify 'there is a \'previous\' link' do
      expect(page).to have_link('Previous')
    end

    specify 'there is a \'next\' link' do
      expect(page).to have_link('Next')
    end

  end

end
