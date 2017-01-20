require 'rails_helper'

describe 'Contents', type: :feature do
  let(:index_path) { contents_path }
  let(:page_title) { 'Contents' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'when signed in an a project is selected' do
    before {
      sign_in_user_and_select_project
    }
    after {
      click_link('Sign out')
    }

    context 'with some records created' do
      let!(:o) { factory_girl_create_for_user_and_project(:valid_otu, @user, @project) }
      let!(:t) { factory_girl_create_for_user_and_project(:valid_topic, @user, @project) }
      before do
        10.times {
          FactoryGirl.create(:valid_content,
                             otu:     o,
                             topic:   t,
                             project: @project,
                             creator: @user,
                             updater: @user
                            )
        }
      end

      describe 'GET /contents' do
        before { visit contents_path }
        it_behaves_like 'a_data_model_with_standard_index'
      end

      describe 'GET /contents/list' do
        before { visit list_contents_path }
        it_behaves_like 'a_data_model_with_standard_list_and_records_created'
      end

      describe 'GET /contents/n' do
        before {
          visit content_path(Content.second)
        }

        it_behaves_like 'a_data_model_with_standard_show'
      end
    end
  end
end
