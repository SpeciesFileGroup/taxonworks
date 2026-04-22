require 'rails_helper'

describe 'Content editor', type: :feature, group: :contents do
  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project}

    context 'when I visit the task page', js: true do
      before { visit content_editor_task_path }

      specify 'can create new topic' do
        click_button('Topic')
        expect(page).to have_text('Select Topic')

        # SmartSelector fires an API call on mount. Wait for it to finish
        # before clicking 'Create new' — the DOM re-render on response can
        # swallow the click.
        expect(page).to have_button('Create new')
        expect(page).not_to have_css('.vue-box-spinner')

        click_button('Create new')
        expect(page).to have_text('New topic')

        fill_in 'Name', with: 'Testing topic'
        fill_in 'Definition', with: 'Testing, making sure this is long enough'
        click_button('Create')

        expect(page).to have_text('Testing topic was successfully created.')
        expect(page).to have_button('Change Topic')
      end
    end
  end
end
