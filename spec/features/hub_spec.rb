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

    context 'when user is a worker in this project' do
      # specify 'only the worker tab is visible, and shown by default'
    end

    context '"tab" categories' do

      context 'are orderable by a user (ordering is shared across projects at present(?))' do
        # specify 'an "order tabs" link is present on the pages'
        # specify 'when clicked, it takes you to a page hub#order_tabs'
        # specify 'there the user can re-arrange their tabs'
      end

      specify 'default tabs missing from a saved order are appended' do
        @user.update_attribute(:hub_tab_order, %w{data tasks favorite})
        visit hub_path
        expect(@user.reload.hub_tab_order).to eq(%w{data tasks favorite render})
        expect(page).to have_link('render', href: hub_path(list: 'render'))
      end

      context 'render tab' do
        before { visit hub_path(list: 'render') }

        specify 'has the Render section' do
          expect(page).to have_css('[data-section="Render"]')
          expect(page).to have_link('Compositions')
        end

        specify 'does not have data sections' do
          expect(page).to_not have_css('[data-section="Core"]')
        end
      end

      context 'data tab' do
        before { visit hub_path(list: 'data') }

        specify 'does not have the Render section' do
          expect(page).to have_css('[data-section="Core"]')
          expect(page).to_not have_css('[data-section="Render"]')
        end
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
