require 'rails_helper'

describe 'Dashboard' do

  it_behaves_like 'a_login_required_controller' do
    let(:index_path) { dashboard_path }
    let(:page_index_name) { 'Dashboard' }
  end

  # subject { page }

  context 'when user is not signed in' do
    before { visit root_path }

    it 'should provide access to sign in' do
      expect(page).to have_selector('h1', 'Taxon Works')
      expect(page).to have_selector('form') do |form|
       expect(form).to have_selector('input[name=email]')
       expect(form).to have_selector('input[name=password]')
       expect(form).to have_selector('input[type=submit]', 'Sign in')
      end

      expect(page).to have_link('forgot password?')
      expect(page).to have_link('find out more')
    end

  end

  context 'when user is signed in' do
    before do
      sign_in_user
    end

    it 'should show user' 's dashboard' do
      expect(page).to have_selector('h1', 'Dashboard')
      expect(page).to have_selector('h2', 'Projects')

      # it 'should have user-specific information in horizontal_navbar'
      within(:css, 'ul.horizontal_navbar') {
        expect(page).to have_link("Account")
        expect(page).to have_link("Sign out")
        expect(page).to have_content("#{@user.email}")
        expect(page).not_to have_link("Project")
      }
    end

    context 'when click Sign out' do
      before { click_link "Sign out" }

      it 'should have sign out button' do
        expect(page).to have_button("Sign in")
      end
    end

    context 'when click Account' do
      before { visit dashboard_path
      click_link "Account" }

      it 'should have user name' do
        expect(page).to have_content("User #{@user.id}")
      end

      it 'should have Edit account link' do
        expect(page).to have_link("Edit account")
      end
    end
  end
end
