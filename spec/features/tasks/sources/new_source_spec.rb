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

      context 'serials' do
        let!(:serial) { Serial.create!(name: 'Journal stuff and things', by: @user) }


        specify 'add a record' do
          select "article", :from => "type"
          fill_in "title", with: 'Qurious'
          fill_in "serials-autocomplete", with: "Journal stuff and things"
          find('li', text: 'Journal stuff and things').hover.click 
          click_button 'Save'
          expect(page).to_not have_text('New record')
          expect(page).to have_text('Remove from project')
          expect(Source.last.serial).to eq(serial)
        end
      end

    end
  end
end
