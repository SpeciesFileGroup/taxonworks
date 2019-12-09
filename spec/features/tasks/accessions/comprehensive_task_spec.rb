require 'rails_helper'

describe 'Task - Comprehensive digitization', type: :feature, group: :collection_objects do

  before do
    ActionController::Base.allow_forgery_protection = true
  end

  after do
    ActionController::Base.allow_forgery_protection = false
  end

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project}

    # all vue.js, so js: true
    context 'when I visit the task page', js: true do
      before { visit comprehensive_collection_object_task_path}

      specify 'starts with a new record' do
        expect(page).to have_text('New record')
      end

      specify 'clicking save saves' do
        click_button 'Save'
        expect(page).to have_text('no identifier assigned')
      end

      context 'adds catalog numbers' do
        let!(:n) { Namespace.create!(name: 'Ill Nat Hist Survey', short_name: 'INHS', by: @user) }

        specify 'adds catalog numbers' do

          page.find('#catalog-number-namespace input').fill_in(with: 'INHS')

          find('li', text: 'INHS ... TODO').hover.click 

          fill_in "catalog-number-identifier", with: '1234'
          click_button 'Save'

          expect(page).to have_text('INHS 1234')
        end

      end

    end
  end
end
