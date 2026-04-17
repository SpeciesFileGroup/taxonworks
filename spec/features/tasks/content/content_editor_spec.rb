require 'rails_helper'

describe 'Content editor', type: :feature, group: :contents do
  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project}

    context 'when I visit the task page', js: true do
      before { visit content_editor_task_path }

      specify 'can create new topic' do
        expect(page).to have_button('Topic')
        click_button('Topic')

        expect(page).to have_button('Create new')
        click_button('Create new')

        find('input[placeholder="Name"]').set('Testing topic')
        find('textarea[placeholder="Definition"]').set('Testing, making sure this is long enough')
        click_button('Create')

        expect(page).to have_text('Testing topic -')
        expect(page).to have_button('Change Topic')
      end
    end
  end
end
