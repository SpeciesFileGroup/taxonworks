require 'rails_helper'

describe 'Content editor' do
  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project}

    context 'when I visit the task page', js: true do
      before { visit index_editor_task_path }

      specify 'can create new topic' do
        click_button('Topic')
        click_button('Create new')
        expect(page).to have_text('New topic')
        fill_in 'Name', with: 'Testing topic'
        fill_in 'Definition', with: 'Testing, making sure this is long enough'
        click_button('Create')
        expect(page).to have_text('Testing topic was successfully created.')
      end
    end
  end
end
