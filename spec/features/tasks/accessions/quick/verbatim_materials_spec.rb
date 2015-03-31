require 'rails_helper'
#include FormHelper

describe 'Quick verbatim material', type: :feature, group: :sources do

  context 'when signed in and a project is selected' do
    before {
      sign_in_user_and_select_project # logged in and project selected
    }
    specify 'basic new quick verbatim material' do
      visit quick_verbatim_material_task_path   # when I visit the quick_verbatim_material_task_path
      fill_in 'collection_object_buffered_collecting_event', with: 'Here, by me!' # fill out the collecting event field with "Here, by me!"
      fill_in 'collection_objects_object1_total', with: '1' # fill out the total field with "1"
      click_button 'Create' # click the 'Create'
      expect(page).to have_content('Added records')
    end

  end
end
