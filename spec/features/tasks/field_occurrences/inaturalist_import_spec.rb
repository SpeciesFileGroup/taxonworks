require 'rails_helper'

describe 'Task - iNaturalist import', type: :feature, group: :field_occurrences do

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    context 'when I visit the task page' do
      before { visit inaturalist_import_task_path }

      specify 'page loads without error' do
        expect(page).to have_text('iNaturalist import')
      end
    end
  end

end
