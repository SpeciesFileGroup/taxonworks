require 'rails_helper'

describe 'Cite key task', type: :feature do
  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    specify 'the page loads and renders the Vue mount point' do
      visit cite_key_task_path

      expect(page.status_code).to eq(200)
      expect(page).to have_css('#cite_key_task')
    end
  end
end
