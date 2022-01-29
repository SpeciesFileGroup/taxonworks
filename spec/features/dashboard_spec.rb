require 'rails_helper'

describe 'Dashboard' do

  it_behaves_like 'a_login_required_controller' do
    let(:index_path) { dashboard_path }
    let(:page_title) { 'Dashboard' }
  end

  context 'when user is not signed in' do
    before { visit root_path }

    it 'should provide access to sign in' do
      expect(page).to have_selector('h3', text: 'Sign in to start your session')
      expect(page).to have_selector('form') { |form|
        expect(form).to have_selector('input[name="session[email]"]')
        expect(form).to have_selector('input[name="session[password]"]')
        expect(form).to have_selector('input[type="submit"][value="Sign in"]')
      }

      expect(page).to have_link('Forgot password?')
      expect(page).to have_link('Find out more')
    end
  end

  context 'when user is signed in' do
    before do
      sign_in_user
    end

    it 'should show user' 's dashboard' do
      expect(page).to have_selector('h1', text: "Dashboard for #{@user.name}")
      expect(page).to have_selector('.panel .title', text: 'Projects')

      # it 'should have user-specific information in horizontal_navbar'
      within(:css, '#session_nav ul.horizontal_navbar') {
        expect(page).to have_link('Account')
        expect(page).to have_link('Sign out')
        expect(page).to have_content("#{@user.name}")
        expect(page).not_to have_link('Project')
      }
    end

    context 'when click Sign out', js: true do
      before { click_link 'Sign out' }

      it 'should have sign out button' do
        expect(page).to have_button('Sign in')
      end
    end

    # Redundate with sessions features ultimately
    context 'when click Account' do
      before {
        visit dashboard_path
        click_link 'Account'
      }

      it 'should have user name' do
        expect(page).to have_content("#{@user.name}")
      end

      it 'should have Edit account link' do
        expect(page).to have_button('Edit')
      end
    end
  end
end
