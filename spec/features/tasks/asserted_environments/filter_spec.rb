require 'rails_helper'

describe 'Filter asserted environments task', type: :feature do
  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    specify 'the page loads and renders the Vue mount point' do
      visit filter_asserted_environments_task_path

      expect(page.status_code).to eq(200)
      expect(page).to have_css('#vue-filter-asserted-environments')
    end
  end
end
