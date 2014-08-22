require 'rails_helper'

describe 'Tags', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { tags_path }
    let(:page_index_name) { 'Tags' }
  end

  describe 'GET /tags' do
    before {
      sign_in_user_and_select_project
      visit tags_path
    }
    
    specify 'an index name is present' do
      expect(page).to have_content('Tags')
    end
    
  end

  describe 'GET /tags/list' do
    before do
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      # this is so that there are more than one page of tags
      # problem with Faker::Lorem.word forces this to 15, ATM
      15.times { FactoryGirl.create(:valid_tag) }
      visit '/tags/list'
    end

    specify 'that it renders without error' do
      expect(page).to have_content 'Listing Tags'
    end

  end

  describe 'GET /tags/n' do
    before {
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      3.times { FactoryGirl.create(:valid_tag) }
      all_tags = Tag.all.map(&:id)
      # there *may* be a better way to do this, but this version *does* work
      visit "/tags/#{all_tags[1]}"
    }

    specify 'there is a \'previous\' link' do
      expect(page).to have_link('Previous')
    end

    specify 'there is a \'next\' link' do
      expect(page).to have_link('Next')
    end

  end
end


