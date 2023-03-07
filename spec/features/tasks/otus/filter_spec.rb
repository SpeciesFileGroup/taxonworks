require 'rails_helper'

describe 'Filter OTUs', type: :feature, group: :otus, js: true do

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project}

    context 'when I visit the task page' do
      before { visit filter_otus_task_path }

      let!(:otu) { Otu.create(name: 'Foo Bar', by: @user, project: @project) }

      specify 'find a OTU' do
        fill_in name: 'name', with: 'Foo'

        click_button 'Filter'
        expect(page).to have_text('Foo Bar')
      end
    end
  end
end
