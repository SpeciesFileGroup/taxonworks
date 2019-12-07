require 'rails_helper'

describe 'New taxon name', type: :feature, group: :sources do

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project}

    context 'when I visit the task page', js: true do
      before { visit new_source_task_path }

      specify 'add a record' do
        select "article", :from => "type"
        fill_in "title", with: 'Qurious'
        click_button 'Save'
      end
    end
  end
end
