require 'rails_helper'

describe 'Project organizations task', type: :feature, group: :projects do
  let(:page_title) { 'Project organizations' }
  let(:index_path) { project_organizations_task_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    specify 'the task page renders' do
      visit index_path
      expect(page.status_code).to eq(200)
    end

    specify 'the vue app is mounted' do
      visit index_path
      expect(page).to have_css('#project_organizations_task', visible: :all)
    end
  end

end
