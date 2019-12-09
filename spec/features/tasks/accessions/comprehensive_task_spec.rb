require 'rails_helper'

describe 'Task - Comprehensive digitization', type: :feature, group: :collection_objects do

  # identifier-field, namespace-autocomplete
  #  .co-total-count
  # verbatim-locality, start-date-year, determination-otu, determination-add-button

  # within all('.page-header')[0] do
  # ...
  # end

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

      context 'catalog numbers' do
        let!(:n) { Namespace.create!(name: 'Ill Nat Hist Survey', short_name: 'INHS', by: @user) }

        specify 'adds catalog numbers' do
          page.find('#namespace-autocomplete input').fill_in(with: 'INHS')

          find('li', text: 'INHS Ill Nat Hist Survey').hover.click 

          fill_in "identifier-field", with: '1234'
          click_button 'Save'

          expect(page).to_not have_text('New record')
          expect(page).to_not have_text('no identifier assigned')
          expect(page).to have_text('INHS 1234')
        end
      end

      specify 'adds collecting events' do
        fill_in "verbatim-locality", with: 'Somewhere over the rainbow'
        click_button 'Save'
        expect(page).to have_text('Sequential uses: 1')
      end

      context 'taxon determinations' do
        let!(:o) { Otu.create!(name: 'Foo', by: @user, project: @project) } 

        specify 'adds taxon determinations' do
          page.find('#determination-otu input').fill_in(with: 'Foo')

          find('li', text: 'Foo').hover.click 
          click_button 'determination-add-button'
          page.find('body').send_keys([OS.mac? ? :control : :alt, 's'])
          expect(page).to have_text('determined as Foo')
        end
      end
    end
  end
end
