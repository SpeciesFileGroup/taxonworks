require 'rails_helper'

describe 'Quick mobile material task', type: :feature do
  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    specify 'the page loads and renders the Vue mount point' do
      visit quick_mobile_material_task_path

      expect(page.status_code).to eq(200)
      expect(page).to have_css('#quick_mobile_material_task')
    end
  end
end
