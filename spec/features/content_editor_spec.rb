require 'rails_helper'

describe 'Content editor' do
  let(:index_path) { '/tasks/content/editor/index' }
  it_behaves_like 'a_login_required_controller'

  context 'testing new topic' do
    before {
      echo                           = Capybara.default_max_wait_time
      Capybara.default_max_wait_time = 15
      sign_in_user_and_select_project
      visit '/tasks/content/editor/index'
      Capybara.default_max_wait_time = echo
    }
    after {
      click_link('Sign out')
    }

    specify 'can create new topic', js: true do
      click_button('Topic')
      click_button('New')
      expect(page).to have_content("New topic")
      fill_in 'Name', with: "Testing topic"
      fill_in 'Definition', with: "Yeah! Its working!"
      click_button('Create')
    end
  end
end


