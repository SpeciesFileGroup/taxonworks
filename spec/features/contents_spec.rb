require 'rails_helper'

describe 'Contents', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { contents_path }
    let(:page_index_name) { 'Contents' }
  end

  describe 'GET /contents' do
    before {
      sign_in_user_and_select_project
      visit contents_path }

    specify 'an index name is present' do
      expect(page).to have_content('Contents')
    end

  end

  describe 'GET /contents/list' do
    before do
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      # this is so that there are more than one page of contents
      # problem with Faker::Lorem.word forces this to 2, ATM
      30.times { FactoryGirl.create(:valid_content) }
      visit '/contents/list'
    end

    specify 'that it renders without error' do
      expect(page).to have_content 'Listing Contents'
    end

  end

  describe 'GET /contents/n' do
    before {
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      3.times { FactoryGirl.create(:valid_content) }
      all_contents = Content.all.map(&:id)
      # there *may* be a better way to do this, but this version *does* work
      # TODO: @mjy pending 'correction of the 'content_tag' name conflict'
      # visit "/contents/#{all_contents[1]}"
    }

    specify 'there is a \'previous\' link' do
      pending 'correction of the \'content_tag\' name conflict'
      expect(page).to have_link('Previous')
    end

    specify 'there is a \'next\' link' do
      pending 'correction of the \'content_tag\' name conflict'
      expect(page).to have_link('Next')
    end

  end
end
