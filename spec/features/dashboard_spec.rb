require 'rails_helper'

describe 'Dashboard', :type => :feature do

  it_behaves_like 'a_login_required_controller' do
     let(:index_path) { dashboard_path }
     let(:page_index_name) { 'Dashboard' }
  end

  subject { page }

  context 'when user is not signed in' do
    before { visit root_path }

    it 'should provide access to sign in' do
      expect(subject).to have_selector('h1', 'Taxon Works')
      expect(subject).to have_selector('form') do |form|
       expect(form).to have_selector('input[name=email]')
       expect(form).to have_selector('input[name=password]')
       expect(form).to have_selector('input[type=submit]', 'Sign in')
      end

      expect(subject).to have_link('forgot password?')
      expect(subject).to have_link('find out more')
    end

  end

  context 'when user is signed in' do
    before do
      sign_in_user
    end

    it 'should show user\'s dashboard' do
      expect(subject).to have_selector('h1', 'Dashboard')
      expect(subject).to have_selector('h2', 'Projects')
    end

  end

end
