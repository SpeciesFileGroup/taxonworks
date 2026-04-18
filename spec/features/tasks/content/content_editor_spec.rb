require 'rails_helper'

describe 'Content editor', type: :feature, group: :contents do
  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project}

    context 'when I visit the task page', js: true do
      before { visit content_editor_task_path }

      specify 'can create new topic' do
        click_button('Topic')

        # SmartSelector fires an API call on mount (isLoading=true shows .vue-box-spinner).
        # Wait for it to complete before clicking 'Create new', otherwise the DOM
        # re-render when the response arrives can swallow the click event.
        expect(page).to have_button('Create new')
        expect(page).not_to have_css('.vue-box-spinner')

        click_button('Create new')

        # VModal's <Transition name="modal"> applies modal-enter-from (opacity:0)
        # for two nested requestAnimationFrame ticks before the modal is visible.
        # In headless Firefox, WebDriver polling locks the content-process JS
        # thread and starves RAF callbacks. Ruby-side sleep is the only way to
        # give the browser a poll-free window to run those frames.
        sleep 0.3

        find('input[placeholder="Name"]').set('Testing topic')
        find('textarea[placeholder="Definition"]').set('Testing, making sure this is long enough')
        click_button('Create')

        expect(page).to have_text('Testing topic -')
        expect(page).to have_button('Change Topic')
      end
    end
  end
end
