require 'rails_helper'

describe 'Hub', :type => :feature do

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

      context 'all tab' do
        specify 'renders all the tabs, one after another' do
          # check for headers
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

      context 'recently visited tab' do
        context 'when a number of pages are visited' do
          # specify 'data and task relates pages should be present'
          # specify 'project and administration pages should not be present'
        end

        context 'after some time' do
          # specify 'recent visits should disappear'
        end
      end

      context 'data tab' do
        # specify 'is broken down into core, supporting, and annotation categories'
      end

      context 'shared tab' do
        # specify 'is broken down into user defineable and application provided categories'
      end

      context 'worker tab' do
        # specify 'is empty by default, with a little message explaining what it represents'
        context 'after a project administrator adds some pages' do
          # specify 'links are provided here'
        end
      end
    end

  end

  describe 'recent tracking' do
=begin
   With three otus created named "a", "b", "c" (create in order)
     when I visit /otus
        then I see three recent objects
             when I click on the one named "a"
                 and I click next 2x
                     then when I visit the hub
                        and I click 'recent'
                            then I see 4 links
                               (3 for each otu, one for Otus)
=end

    xspecify 'should see recent links' do
      sign_in_user_and_select_project
      otu1 = Otu.new(name: 'a', by: @user, project: @project)
      otu1.save!
      otu2 = Otu.new(name: 'b', by: @user, project: @project)
      otu2.save!
      otu3 = Otu.new(name: 'c', by: @user, project: @project)
      otu3.save!

      visit otus_path
      expect(page).to have_link('a')
      expect(page).to have_link('b')
      expect(page).to have_link('c')
      click_link('a')
      expect(page).to have_content('Name: a')
      expect(page).to have_link('Next')
      click_link('Next')
      expect(page).to have_content('Name: b')
      expect(page).to have_link('Next')
      click_link('Next')
      expect(page).to have_content('Name: c')

      visit hub_path
      click_link('recent')
      expect(page).to have_link('a [Otu]')
      expect(page).to have_link('b [Otu]')
      expect(page).to have_link('c [Otu]')
      expect(page).to have_link('Otus')
     end
  end
end
