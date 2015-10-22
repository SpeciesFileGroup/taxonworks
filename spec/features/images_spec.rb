require 'rails_helper'

describe "Images", :type => :feature do
  let(:index_path) { images_path }
  let(:page_index_name) { 'images' }

  it_behaves_like 'a_login_required_and_project_selected_controller' do
  end

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project
      10.times { factory_girl_create_for_user_and_project(:valid_image, @user, @project) }
    }

    describe 'GET /images' do
      before { visit images_path }

      it_behaves_like 'a_data_model_with_standard_index'
    end

    describe 'GET /images/list' do
      before { visit list_images_path }

      it_behaves_like 'a_data_model_with_standard_list'
    end

    describe 'GET /images/n' do
      before { visit image_path(Image.second) }

      it_behaves_like 'a_data_model_with_standard_show'
    end

    describe 'GET /api/v1/images/{id}' do
      #TODO: Intentionally failing to remember to implement this test
      it 'Returns a successful JSON response' do
        visit '/api/v1/images/1'
        expect(JSON.parse(page.body)['success']).to be_true
      end
    end
  end
end
