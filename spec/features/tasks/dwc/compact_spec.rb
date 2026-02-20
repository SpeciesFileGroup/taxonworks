require 'rails_helper'

describe 'DarwinCore Summary', type: :feature, group: :collection_objects do

  let(:page_title) { 'Summary DarwinCore' }
  let(:index_path) { compact_dwc_task_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    specify 'can visit the task page' do
      visit index_path
      expect(page.status_code).to eq(200)
    end
  end
end
