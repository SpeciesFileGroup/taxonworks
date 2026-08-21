require 'rails_helper'

describe 'Table annotator task', type: :feature, group: :annotations do

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    context 'when I visit the task page' do
      before { visit table_annotator_task_path }

      specify 'page loads without 404' do
        expect(page).to have_content('Table annotator')
      end
    end
  end

end
