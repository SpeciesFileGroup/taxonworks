require 'rails_helper'

describe 'Namespaces', type: :feature do
  let(:page_title) { 'Namespaces' }
  let(:index_path) { namespaces_path }

  it_behaves_like 'a_login_required_controller'

  context 'signed in'  do
    before { sign_in_user_and_select_project }
    context 'with some records created' do
      before {
        3.times { factory_bot_create_for_user(:valid_namespace, @user) }
      }

      describe 'GET /Namespaces' do
        before {visit namespaces_path }
        it_behaves_like 'a_data_model_with_standard_index'
      end

      describe 'GET /namespaces/list' do
        before { visit list_namespaces_path }
        it_behaves_like 'a_data_model_with_standard_list_and_records_created'
      end

      describe 'GET /namespaces/n' do
        before { visit namespace_path(Namespace.second) }
        it_behaves_like 'a_data_model_with_standard_show'
      end

      context 'creating a new namespace', js: true do
        before { visit(namespaces_path) }

        specify 'adding the new namespace' do
          click_link('New')
          fill_in(:namespace_name, with: 'Things Pat Collected')
          fill_in(:namespace_short_name, with: 'tpd')
          click_button('Create')
          expect(page).to have_content("Namespace was successfully saved.")
        end
      end
    end
  end
end
