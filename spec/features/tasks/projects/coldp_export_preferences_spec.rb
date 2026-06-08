require 'rails_helper'

describe 'ColDP export preferences task', type: :feature, group: :projects do
  let(:page_title) { 'Coldp export preferences' }
  let(:index_path) { project_coldp_export_preferences_task_path }

  context 'when signed in as a project administrator' do
    before { sign_in_project_administrator_and_select_project }

    context 'visiting the task page' do
      before { visit index_path }

      specify 'page renders without error' do
        expect(page).to have_content(page_title)
      end
    end
  end
end
