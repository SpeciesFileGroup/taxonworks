require 'spec_helper'

describe 'Dashboard' do

  it_behaves_like 'a_login_required_controller' do
     let(:index_path) { dashboard_path }
  end

  subject { page }

  context 'when user is not signed in' do
    before { visit root_path }

    it 'should provide access to sign in' do
      subject.should have_selector('h1', 'Taxon Works')
      subject.should have_selector('form') do |form|
       form.should have_selector('input[name=email]')
       form.should have_selector('input[name=password]')
       form.should have_selector('input[type=submit]', 'Sign in')
      end

      subject.should have_link('forgot password?')
      subject.should have_link('find out more')
    end

  end

  context 'when user is signed in' do
    before do
      sign_in_valid_user
    end

    it 'should show user\'s dashboard' do
      subject.should have_selector('h1', 'Dashboard')
      subject.should have_selector('h2', 'Projects')
    end

  end

end
