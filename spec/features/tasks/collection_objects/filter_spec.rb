require 'rails_helper'
# require 'support/shared_contexts/shared_geo'

describe 'Filter collection objects', type: :feature, group: [:geo, :collection_objects, :shared_geo], js: true do

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    context 'when I visit the task page' do
      before { visit filter_collection_objects_task_path }
     
      specify 'find task title' do
        expect(page).to have_text('Filter collection objects')
      end
    end
  end
end