require 'rails_helper'

describe 'Authentication', :type => :feature do

  subject { page }

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

      before { @valid_user = User.find(1) }

      it 'should sign user in' do
        sign_in_with(@valid_user.email, TEST_USER_PASSWORD)

        expect(subject).to have_link('Account') # TODO, add href
        expect(subject).not_to have_link('Sign out', href: signin_path)

        expect(subject).to have_content "Dashboard" 
        expect(subject).to have_content "Projects" 
      end
    end

    context 'when credentials do not match existing user' do
      it 'should not sign user in' do
        sign_in_with('', '')
        expect(subject).to have_title('Sign in | TaxonWorks')
        expect(subject).to have_button('Sign in')
        expect(subject).not_to have_link('Sign out', href: signout_path)
        expect(subject).not_to have_content 'Signed in as user'
        expect(subject).not_to have_link('Account')
      end
    end
  end

  describe '/signout' do
    before do
      sign_in_valid_user
    end

    it 'should log user out' do
      click_link 'Sign out'
      expect(subject).to have_button('Sign in')
      expect(subject).not_to have_link('Sign out', href: signout_path)
      expect(subject).not_to have_content 'Signed in as user'
      expect(subject).not_to have_content('Your account')
    end
 
  end 
end
