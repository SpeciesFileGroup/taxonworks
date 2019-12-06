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
      let!(:root) { @project.send(:create_root_taxon_name) } 

      before { visit new_taxon_name_task_path }

      specify 'add a name' do
        fill_in "taxon-name", with: 'Qurious'
        page.find('#parent-name input').fill_in(with: 'Root')
        click_link 'Root'

        #fill_autocomplete('[parent-name.input]', with: 'Root', select: @project.root_taxon_name.id)
        click_button 'Create'
        expect(page).to have_text('Qurious')
      end
    end
  end
end

