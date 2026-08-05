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

    context 'category filter' do
      # The filter JS (filterHub.js) binds by selector, and enforces the
      # one-at-a-time behaviour of the scope controls by clearing `.activated`
      # across `.navigation-controls-type .navigation-item`. Restyling must not
      # move those hooks.
      specify 'each scope control is a navigation-item inside navigation-controls-type' do
        %w{filters browse new}.each do |scope|
          expect(page).to have_css(
            "#filter .navigation-controls-type .navigation-item[data-filter-category='#{scope}']",
            visible: :all
          )
        end
      end

      specify 'the panel carries a card header' do
        expect(page).to have_css('#filter .filter-card > .tw-card-header .tw-card-title',
                                 text: 'Filters', visible: :all)
      end

      # It clears every filter, not just the search text, so it belongs to the
      # panel rather than to the input it used to sit beside.
      specify 'reset lives in the header actions, not the search row' do
        expect(page).to have_css(
          "#filter .tw-card-header .tw-card-header-actions .reset[data-filter-category='reset']",
          visible: :all
        )
        expect(page).to have_no_css('#filter .search-row .reset', visible: :all)
      end

      # The scope categories are only ever applied to task cards; nothing in
      # config/interface/hub/data.yml declares them. Rendering the group over a
      # list of data cards gives the user three controls whose only possible
      # effect is to empty the grid.
      specify 'the scope group renders over a list of task cards' do
        expect(page).to have_css('#filter .filter-scope', visible: :all)
      end

      specify 'the scope group is absent over a list of data cards' do
        visit hub_path(list: 'data')

        expect(page).to have_css('#filter', visible: :all)
        expect(page).to have_no_css('#filter .filter-scope', visible: :all)
      end

      specify 'the scope group is absent on favorites until a task is favorited' do
        visit hub_path(list: 'favorite')

        expect(page).to have_css('#filter', visible: :all)
        expect(page).to have_no_css('#filter .filter-scope', visible: :all)
      end

      specify 'the scope group returns on favorites once a task is favorited' do
        @user.add_page_to_favorites(
          name: UserTasks.hub_tasks.first.prefix,
          kind: 'tasks',
          project_id: @project.id
        )
        visit hub_path(list: 'favorite')

        expect(page).to have_css('#filter .filter-scope', visible: :all)
      end

      specify 'each category control keeps its count span' do
        UserTasks::CATEGORIES.each do |category|
          expect(page).to have_css(
            "#filter .flex-wrap-row .navigation-item[data-filter-category='#{category}'] .category-count",
            visible: :all
          )
        end
      end
    end

    context 'empty states' do
      # Both are rendered hidden and revealed by JS: `.no-tasks` by `.show`
      # (display: flex), the data sections by `.d-block` (display: block). The
      # markup has to keep those hooks on the outer element.
      specify 'the task carrousel has one, keyed by .no-tasks' do
        expect(page).to have_css('#task_carrousel .no-tasks .hub-empty-state-message',
                                 text: 'No tasks found', visible: :all)
      end

      specify 'each data section has one, keyed by data-attribute=empty' do
        visit hub_path(list: 'data')

        expect(page).to have_css(
          "#data_cards [data-section] [data-attribute='empty'] .hub-empty-state-message",
          text: 'None', visible: :all
        )
      end

      specify 'they use a paragraph, not a heading' do
        expect(page).to have_no_css('#task_carrousel .no-tasks h1', visible: :all)
        expect(page).to have_css('p.hub-empty-state-message', visible: :all)
      end
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
