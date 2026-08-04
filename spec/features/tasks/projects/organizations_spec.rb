require 'rails_helper'

describe 'Project organizations task', type: :feature, group: :projects do
  let(:index_path) { project_organizations_task_path }

  context 'as a project administrator' do
    before { sign_in_project_administrator_and_select_project }

    specify 'the task page renders' do
      visit index_path
      expect(page.status_code).to eq(200)
    end

    specify 'the vue app is mounted' do
      visit index_path
      expect(page).to have_css('#project_organizations_task', visible: :all)
    end

    specify 'the link is in the Configuration box of the project page' do
      visit project_path(@project)
      expect(page).to have_link('Organizations', href: index_path)
    end
  end

  context 'as a project member who is not an administrator' do
    before { sign_in_user_and_select_project }

    specify 'the task is not accessible' do
      visit index_path
      expect(page).to have_content('Please sign in as a project administrator or administrator.')
    end

    specify 'the link is not on the project page' do
      visit project_path(@project)
      expect(page).not_to have_link('Organizations', href: index_path)
    end
  end

end
