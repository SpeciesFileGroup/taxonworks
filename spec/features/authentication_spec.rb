require 'spec_helper'

describe 'Authentication' do

  subject { page }

  before { 
    visit signup_path 
  }

  #   context 'when user enters valid information' do

  #     before do
  #       sign_in_administrator
  #       sign_up_with('user@signup.com', 'password', 'password')
  #       @signup_user = User.find_by_email('user@signup.com')
  #     end

  #     after { User.find_by_email('user@signup.com').destroy rescue nil }

  #     it 'should create user account and provide feedback' do
  #       subject.should have_content 'Thanks for signing up and welcome to TaxonWorks!'
  #       subject.should have_content "Signed in as user #{@signup_user.id}"
  #       subject.should have_link('Sign out', href: signout_path)
  #       subject.should_not have_link('Sign in', href: signin_path)
  #       subject.should_not have_link('Create account', href: signup_path)
  #     end
  #   end

  #   context 'when user enters invalid information' do

  #     it 'should not create account and should provide feedback' do
  #       sign_up_with('', '', '')
  #       subject.should have_title('Create account | TaxonWorks')
  #       subject.should have_selector('.field_with_errors #user_email')
  #       subject.should have_selector('.field_with_errors #user_password')
  #       subject.should have_link('Sign in', href: signin_path)
  #       subject.should_not have_link('Sign out', href: signout_path)
  #     end

  #   end
  # end

  describe '/signin' do
    context 'when credentials match existing user' do

      before { @existing_user = FactoryGirl.create(:valid_user) }

      it 'should sign user in' do
        sign_in_with(@existing_user.email, @existing_user.password)

        subject.should have_link('Account') # TODO, add href
        subject.should_not have_link('Sign out', href: signin_path)

        subject.should have_content "Dashboard" 
        subject.should have_content "Projects" 
      end
    end

    context 'when credentials do not match existing user' do
      it 'should not sign user in' do
        sign_in_with('', '')
        subject.should have_title('Sign in | TaxonWorks')
        subject.should have_button('Sign in')
        subject.should_not have_link('Sign out', href: signout_path)
        subject.should_not have_content 'Signed in as user'
        subject.should_not have_link('Account')
      end
    end
  end

  describe '/signout' do
    before do
      sign_in_valid_user
    end

    it 'should log user out' do
      click_link 'Sign out'
      subject.should have_button('Sign in')
      subject.should_not have_link('Sign out', href: signout_path)
      subject.should_not have_content 'Signed in as user'
      subject.should_not have_content('Your account')
    end
  end

end
