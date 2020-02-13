require 'rails_helper'

describe 'Sources', type: :feature, group: :sources do
  #Capybara.default_wait_time = 15  # slows down Capybara enough to see what's happening on the form
  let(:page_title) { 'Sources' }
  let(:index_path) { sources_path }

  it_behaves_like 'a_login_required_controller'

  context 'signed in as user, with some records created' do
    before do
      sign_in_user_and_select_project
      5.times { factory_bot_create_for_user(:valid_source, @user) }
    end

    describe 'GET /sources' do
      before { visit sources_path }

      it_behaves_like 'a_data_model_with_standard_index'
    end

    describe 'GET /sources/list' do
      before { visit list_sources_path }
      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
    end

    describe 'GET /sources/n' do
      before { visit source_path Source.second }
      it_behaves_like 'a_data_model_with_standard_show'
    end
  end
end
