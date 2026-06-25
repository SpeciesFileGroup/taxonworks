require 'rails_helper'

describe 'Type material dashboard', type: :feature, group: [:collection_objects, :nomenclature] do

  let(:page_title) { 'Type material dashboard' }
  let(:index_path) { type_material_dashboard_task_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    specify 'can visit the task page' do
      visit index_path
      expect(page.status_code).to eq(200)
    end
  end
end
