require 'spec_helper'

describe 'Dashboard' do

  subject { page }

  context 'when user is not signed in' do
    before { visit root_path }

    it 'should provide access to sign in or create account' do
      subject.should have_selector('h1', 'Sign in')
      subject.should have_selector('form input[type=submit]', 'Sign in')
      click_link('Create account')
      subject.should have_selector('h1', 'Create account')
      subject.should have_selector('form input[type=submit]', 'Create account')
    end

  end

  context 'when user is signed in' do
    before do
      @existing_user = FactoryGirl.create(:valid_user)
      sign_in_with(@existing_user.email, @existing_user.password)
    end

    it 'should show user\'s dashboard' do
      subject.should have_selector('h1', 'Your dashboard')
    end

  end

end
