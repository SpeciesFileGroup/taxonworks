require 'rails_helper'

describe 'Hub', type: :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { hub_path }
    let(:page_title) { 'Hub' }
  end

  subject { page }

  describe '/hub' do
    before {
      sign_in_user_and_select_project
      visit hub_path
    }

    it 'should have hub highlighting' do
      expect(page).to have_css('.hub_link.on_hub')
    end

    context 'when user is a worker in this project' do
      # specify 'only the worker tab is visible, and shown by default'
    end

    context '"tab" categories' do

      context 'are orderable by a user (ordering is shared across projects at present(?))' do
        # specify 'an "order tabs" link is present on the pages'
        # specify 'when clicked, it takes you to a page hub#order_tabs'
        # specify 'there the user can re-arrange their tabs'
      end

      context 'favorite tab' do
        context 'before a user has selected any favorite pages' do
          # specify 'a notice describing how to add pages to this list is provided'
        end

        context 'after a user selects some favorite pages within a project' do # SEE ___ for what pages can be favorited (essentially only those that don't reference IDs (those are pinned) 
          # specify 'a list of favorite pages is rendered'
          # specify 'the list of favorite pages is restricted to those for this project'
        end
      end
    end

  end
end
