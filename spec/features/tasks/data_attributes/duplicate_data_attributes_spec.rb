require 'rails_helper'

describe 'Duplicate data attributes task', type: :feature, group: :data_attributes do
  let(:page_title) { 'Duplicate data attributes' }
  let(:index_path) { index_duplicate_data_attributes_task_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'when signed in and a project is selected', js: true do
    before { sign_in_user_and_select_project }

    context 'visiting the task page' do
      before { visit index_path }

      specify 'page renders without error' do
        expect(page).to have_content('Duplicate data attributes')
      end

      specify 'shows message when no filter provided' do
        expect(page).to have_content('This task is accessed via the radial linker')
      end
    end
  end
end
