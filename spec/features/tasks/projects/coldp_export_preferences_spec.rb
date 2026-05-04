require 'rails_helper'

describe 'ColDP export preferences task', type: :feature, group: :projects do
  let(:page_title) { 'ColDP export preferences' }
  let(:index_path) { project_coldp_export_preferences_task_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    context 'visiting the task page' do
      before { visit index_path }

      specify 'page renders without error' do
        expect(page).to have_content('ColDP export preferences')
      end
    end
  end
end
