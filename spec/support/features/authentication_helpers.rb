module Features
  module AuthenticationHelpers

    def sign_up_with(email, password, password_confirmation)
      visit signup_path
      fill_in 'Email',            with: email
      fill_in 'Password',         with: password
      fill_in 'Password confirmation', with: password_confirmation
      click_button 'Create account'
    end

    def sign_in_with(email, password)
      visit signin_path
      fill_in 'Email',    with: email
      fill_in 'Password', with: password
      click_button 'Sign in'
    end

    def sign_in_valid_user
      existing_user = FactoryGirl.create(:valid_user) 
      visit signin_path
      sign_in_with(existing_user.email, existing_user.password)
    end

  end
end
