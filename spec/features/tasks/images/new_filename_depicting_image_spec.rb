require 'rails_helper'

describe 'New filename depicting image', type: :feature, group: :images do

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    specify 'the task page is reachable' do
      visit new_filename_depicting_image_task_path
      expect(page.status_code).to eq(200)
      expect(page).to have_css('#new_filename_depicting_image_task')
    end
  end
end
