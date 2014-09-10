require 'rails_helper'

describe 'Hub', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { hub_path }
    let(:page_index_name) { 'Hub' }
  end 

  subject { page }

  describe '/hub' do
    before {
      sign_in_user_and_select_project
      visit hub_path
    }

    it 'should have a hub title' do
      expect(page).to have_selector('h1', text: 'Hub')
      expect(subject).to have_selector('h1', text: 'Hub')
    end

    context 'when user is a worker in this project' do
      specify 'only the worker tab is visible, and shown by default'
    end

    context '"tab" categories' do 

      context 'are orderable by a user (ordering is shared across projects at present(?))' do
        specify 'an "order tabs" link is present on the pages'
        specify 'when clicked, it takes you to a page hub#order_tabs'
        specify 'there the user can re-arrange their tabs'
      end

      context 'all tab' do
        specify 'renders all the tabs, one after another' do
          # check for headers
        end
      end

      context 'favorite tab' do
        context 'before a user has selected any favorite pages' do
          specify 'a notice describing how to add pages to this list is provided'
        end

        context 'after a user selects some favorite pages within a project' do # SEE ___ for what pages can be favourited (essentially only those that don't reference IDs (those are pinned) 
          specify 'a list of favorite pages is rendered'
          specify 'the list of favorite pages is restricted to those for this project'
        end
      end

      context 'recently visited tab' do
        context 'when a number of pages are visited' do
          specify 'data and task relates pages should be present'
          specify 'project and administration pages should not be present'
        end

        context 'after some time' do
          specify 'recent visits should disappear'
        end
      end 

      context 'data tab' do
        specify 'is broken down into core, supporting, and annotation categories' 
      end

      context 'shared tab' do
        specify 'is broken down into user defineable and applicaiton provided categories'
      end

      context 'worker tab' do
        specify 'is empty by default, with a little message explaining what it represents'
        context 'after a project administrator adds some pages' do
          specify 'links are provided here'
        end
      end
    end
  end
end
