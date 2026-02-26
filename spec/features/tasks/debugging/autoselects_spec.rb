require 'rails_helper'

describe 'Autoselect playground task', type: :feature, group: :debugging do

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    context 'when I visit the task page' do
      before { visit index_autoselects_task_path }

      specify 'page loads without 404' do
        expect(page).to have_content('Autoselect')
      end
    end
  end

end
