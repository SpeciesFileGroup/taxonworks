require 'rails_helper'

describe 'Quick verbatim material', type: :feature  do

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }
    specify 'basic new quick verbatim material' do
      visit quick_verbatim_material_task_path
      fill_in 'collection_object_buffered_collecting_event', with: 'Here, by me!'
      fill_in 'collection_objects_object1_total', with: '1'
      click_button 'Create'
      expect(page).to have_content('Added records')
    end

  end
end
