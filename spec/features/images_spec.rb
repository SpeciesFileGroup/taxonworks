require 'rails_helper'

describe "Images", :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { images_path }
    let(:page_index_name) { 'Images' }
  end

  describe 'GET /images' do
    before {
      sign_in_user_and_select_project
      visit images_path }

    specify 'a index name is present' do
      expect(page).to have_content('Images')
    end
  end

  context 'with some records created' do
    before {
    sign_in_user_and_select_project
     10.times { factory_girl_create_for_user_and_project(:valid_image, @user, @project) }
    }


  describe 'GET /images/list' do
    before {
      visit list_images_path
    }

    specify 'that it renders without error' do
      expect(page).to have_content 'Listing images'
    end
  end

  describe 'GET /images/n' do
    before {
      visit image_path(Image.second) 
    }

    specify 'there is a \'previous\' link' do
      expect(page).to have_link('Previous')
    end

    specify 'there is a \'next\' link' do
      expect(page).to have_link('Next')
    end

  end

end
end
