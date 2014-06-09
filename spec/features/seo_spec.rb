# AN EXAMPLE ONLY, concept in testing, not fully adopted
require 'spec_helper'

describe 'Search Engine Optimisation' do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  subject { page }

  describe 'navigation links and titles' do

    it 'should be unique and contain targeted keywords' do
      visit root_path # will redirect to sign in
      click_link 'Create account'
      subject.should have_title(/\ACreate account/)
      subject.should have_selector('h1', 'Create account')
      click_link 'Sign in'
      subject.should have_title(/\ASign in/)
      subject.should have_selector('h1', 'Sign in')
    end

  end

  describe 'meta description' do
    it 'should be unique and contain targeted keywords' do
      pending('waiting on descriptions to be added')
    end
  end

  describe 'meta keywords' do
    it 'should be unique and contain targeted keywords' do
      pending('waiting on keywords to be added')
    end
  end

end
