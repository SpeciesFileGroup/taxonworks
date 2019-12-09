require 'rails_helper'

describe 'New source task', type: :feature, group: :sources do

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project}

    # all vue.js, so js: true
    context 'when I visit the task page', js: true do
      before { visit new_source_task_path}

      specify 'defaults to BibTeX' do
        expect(page.find('label', exact_text:  'Title')).to be_truthy
      end
    end
  end
end
