require 'rails_helper'
# require 'support/shared_contexts/shared_geo'

# TODO: rewrite for new filter
describe 'tasks/collection_objects/filter', type: :feature, group: [:geo, :collection_objects, :shared_geo] do

  context 'with properly built collection of objects', js: true do
    let(:page_title) { 'Filter collection objects' }
    let(:index_path) { collection_objects_filter_task_path }

    it_behaves_like 'a_login_required_and_project_selected_controller'

    context 'signed in as a user' do
      before { sign_in_user_and_select_project }
    end
  end
end
