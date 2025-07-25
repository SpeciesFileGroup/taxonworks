require 'rails_helper'

describe 'New collecting event', type: :feature, group: :collecting_events do

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project}

    context 'when I visit the task page', js: true do
      before { visit new_collecting_event_task_path }

      specify 'create a new collecting event' do
        fill_in 'verbatim_label', with: 'This is a label.\nAnd a second line.'
        click_button 'Save'
     
        expect(page).to have_content('Collecting event was successfully saved.')
      end
    end
  end
end

