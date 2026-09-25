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
      expect(page).to have_selector('.hub_project_name', text: "Dashboard for #{@user.name}")
      expect(page).to have_selector('.tw-card-title', text: 'Projects')

      # it 'should have user-specific information in horizontal_navbar'
      within(:css, '#session_nav') {
        expect(page).to have_link('Account')
        expect(page).to have_link('Sign out')
        expect(page).to have_content("#{@user.name}")
        expect(page).not_to have_link('Project')
      }
    end

    context 'projects panel' do
      it 'shows no filter for few projects' do
        within('.panel-projects') do
          expect(page).to have_selector('.project-item', text: 'My Project')
          expect(page).not_to have_selector('.project-filter-input')
        end
      end

      context 'with many projects', js: true do
        before do
          %w{Aphid Bee Cicada Dragonfly Earwig Firefly Grasshopper Hornet}.each do |n|
            p = Project.create!(name: n, creator: @administrator, updater: @administrator, without_root_taxon_name: true)
            p.project_members.create!(creator: @administrator, updater: @administrator, user: @user)
          end
          visit dashboard_path
        end

        it 'filters projects by name' do
          within('.panel-projects') do
            fill_in(placeholder: 'Filter projects...', with: 'fire')
            expect(page).to have_selector('.project-item', text: 'Firefly')
            expect(page).not_to have_selector('.project-item', text: 'Aphid')
            expect(page).not_to have_selector('.project-filter-empty')
          end
        end

        it 'shows an empty message when nothing matches' do
          within('.panel-projects') do
            fill_in(placeholder: 'Filter projects...', with: 'zzz')
            expect(page).not_to have_selector('.project-item')
            expect(page).to have_selector('.project-filter-empty', text: 'No projects match')
          end
        end
      end
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
        expect(page).to have_link('Edit')
      end
    end
  end
end
