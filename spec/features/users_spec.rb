require 'spec_helper'


#
# TODO: These need to be refactored to properly identified desired functionality.
#       Leave alone for now (mjy).
#
describe 'Users', base_class: User do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  subject { page }

  describe '/users' do

    before do
      sign_in_valid_user
      @existing_user = User.find(1) # FactoryGirl.create(:valid_user)
      visit users_path
    end

    it 'should list users' do
      subject.should have_selector('h1', text: 'Users')
      subject.should have_content("#{@existing_user.email}")
    end

  end

  describe '/users/:id' do
    before {
      sign_in_valid_user
      @existing_user = User.find(1)
      visit user_path(@existing_user)
    }

    it 'should show a user\'s profile' do
      subject.should have_selector('h1', text: "User #{@existing_user.id}")
      subject.should have_title("User #{@existing_user.id} | TaxonWorks")
    end
  end

  describe '/users/:id/edit' do
    before do
      @existing_user = FactoryGirl.create(:valid_user)
      visit edit_user_path(@existing_user)
    end

    it 'should let user edit their account information' do
      txt = "Edit user #{@existing_user.id}"
      subject.should have_selector('h1', txt)
      subject.should have_title("#{txt} | TaxonWorks")
      fill_in 'Email', with: 'edit_user_modified@example.com'
      fill_in 'Password', with: @existing_user.password
      fill_in 'Password confirmation', with: @existing_user.password_confirmation
      click_button 'Update User'
      subject.should have_selector('.alert--success', 'Your changes have been saved.')
    end

    it 'should let user delete their account with confirmation step' do #, js: true
      pending('waiting on install of javascript testing framework')
      # click_button 'Delete your account'
      # TODO: To test Javascript dialogue we need to use another Capybara
      #       driver (e.g. Selenium) or alternative tool (e.g. Cucumber)
      # page.driver.browser.accept_js_confirms # e.g. for webkit driver
      # page.driver.browser.switch_to.alert.accept # e.g. for selenium driver
      # pending subject.should have_selector('.alert--success', 'Your account has been deleted.')
    end
  end

end
