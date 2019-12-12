require 'rails_helper'

describe 'Find sources', type: :feature, group: :sources do

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project}

    context 'when I visit the task page' do
      before { visit find_sources_task_path}

      let!(:source) { FactoryBot.create(:valid_source_bibtex, title: 'Qurious', year: 1999, by: @user) } 

      specify 'find a source' do
        fill_in 'query_term', with: 'Qurious' 
        click_button 'Find'
        expect(page).to have_text('1999')
      end
    end
  end
end
