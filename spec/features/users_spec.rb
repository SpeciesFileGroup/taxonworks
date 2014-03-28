require 'spec_helper'

describe 'Users' do

  subject { page }

  describe '/users' do

    before do
      @existing_user = FactoryGirl.create(:valid_user)
      visit users_path
    end

    it 'should list users' do
      subject.should have_selector('h1', 'Users')
      subject.should have_content("User #{@existing_user.id}")
    end

  end

  describe '/users/:id' do
    before do
      @existing_user = FactoryGirl.create(:valid_user)
      visit user_path(@existing_user)
    end

    it 'should show a user\'s profile' do
      subject.should have_selector('h1', "User #{@existing_user.id}")
      subject.should have_title("User #{@existing_user.id} | TaxonWorks")
    end

  end

  describe '/users/:id/edit' do

    before do
      @existing_user = FactoryGirl.create(:valid_user)
      visit edit_user_path(@existing_user)
    end

    it 'should let user edit their account information' do
      subject.should have_selector('h1', "Edit user #{@existing_user.id}")
      subject.should have_title("Edit user #{@existing_user.id} | TaxonWorks")
      fill_in 'Email', with: 'edit_user_modified@example.com'
      fill_in 'Password', with: @existing_user.password
      fill_in 'Password confirmation', with: @existing_user.password_confirmation
      click_button 'Save changes'
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
