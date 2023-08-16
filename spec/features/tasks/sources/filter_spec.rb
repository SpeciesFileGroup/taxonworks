require 'rails_helper'

describe 'Filter sources', type: :feature, group: :sources, js: true do

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project}

    context 'when I visit the task page' do
      before { visit filter_sources_task_path}

      let!(:source) { FactoryBot.create(:valid_source_bibtex, title: 'Qurious', year: 1999, by: @user) }

      specify 'find a source' do
        fill_in name: 'query_term', with: 'Qurious'
        choose 'in_project', option: false

        click_button 'Filter'
        expect(page).to have_text('1999')
      end
    end
  end
end
