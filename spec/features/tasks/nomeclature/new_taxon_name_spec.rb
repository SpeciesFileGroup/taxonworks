require 'rails_helper'

describe 'New taxon name', type: :feature, group: :nomenclature do
  before do
    ActionController::Base.allow_forgery_protection = true
  end

  after do
    ActionController::Base.allow_forgery_protection = false
  end

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project}

    context 'when I visit the task page', js: true do
      before { visit new_taxon_name_task_path }

      specify 'add a name' do
        fill_in "taxon-name", with: 'Qurious' 
        click_button 'Save'
        expect(page).to have_text('1999')
      end
    end
  end
end

