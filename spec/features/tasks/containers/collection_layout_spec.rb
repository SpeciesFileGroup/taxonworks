require 'rails_helper'

describe 'Collection layout task', type: :feature, group: :containers do

  let(:index_path) { index_collection_layout_task_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    specify 'can visit the task page without a 404' do
      visit index_path
      expect(page.status_code).to eq(200)
    end
  end

end
