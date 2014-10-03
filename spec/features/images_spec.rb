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

  describe 'GET /images/list' do
    before do
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      # this is so that there is more than one page
      30.times { FactoryGirl.create(:valid_image) }
      visit '/images/list'
    end

    specify 'that it renders without error' do
      expect(page).to have_content 'Listing images'
    end
  end

  describe 'GET /images/n' do
    before {
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      3.times { FactoryGirl.create(:valid_image) }
      all_images = Image.all.map(&:id)
      # there *may* be a better way to do this, but this version *does* work
      visit "/images/#{all_images[1]}"
    }

    specify 'there is a \'previous\' link' do
      expect(page).to have_link('Previous')
    end

    specify 'there is a \'next\' link' do
      expect(page).to have_link('Next')
    end

  end

end

